import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/features/editor/editor_controller.dart';

import 'helpers.dart' show makeRoofCompanion;

/// Unit tests for the VDE planning checks (validateProject) and the
/// cold-Voc / MPPT-current limits in autoAssignStrings.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.projects).insert(ProjectsCompanion.insert(
      name: 'Testprojekt',
      createdAt: 0,
      updatedAt: 0,
    ));
    await db.into(db.roofs).insert(makeRoofCompanion(projectId: 1));
  });

  tearDown(() async {
    await db.close();
  });

  /// Inserts a module type and returns its id.
  Future<int> addModule({
    required double pMaxW,
    required double voc,
    required double isc,
    double imp = 10.0,
    double vmp = 0,
    double vocTempCoeff = -0.3,
    String? frameClass,
    double widthMm = 1762,
    double heightMm = 1134,
  }) {
    return db.into(db.solarModules).insert(SolarModulesCompanion.insert(
      name: 'Testmodul ${pMaxW}W',
      pMaxW: pMaxW,
      voc: voc,
      isc: isc,
      widthMm: widthMm,
      heightMm: heightMm,
      imp: Value(imp),
      vmp: Value(vmp),
      vocTempCoeff: Value(vocTempCoeff),
      frameClass: Value(frameClass),
    ));
  }

  /// Inserts an inverter and returns its id.
  Future<int> addInverter({
    required double powerKw,
    int mppCount = 1,
    int maxStringsPerMpp = 4,
    double? minInputVoltage,
    required double maxInputVoltage,
    double? maxShortCircuitCurrentPerMpp,
    int acPhases = 3,
    double? mppMinVoltage,
    double? mppMaxVoltage,
  }) {
    return db.into(db.inverters).insert(InvertersCompanion.insert(
      name: 'TestWR ${powerKw}kW',
      powerKw: powerKw,
      mppCount: Value(mppCount),
      maxStringsPerMpp: Value(maxStringsPerMpp),
      minInputVoltage: Value(minInputVoltage),
      maxInputVoltage: Value(maxInputVoltage),
      maxShortCircuitCurrentPerMpp: Value(maxShortCircuitCurrentPerMpp),
      acPhases: Value(acPhases),
      mppMinVoltage: Value(mppMinVoltage),
      mppMaxVoltage: Value(mppMaxVoltage),
    ));
  }

  /// Places [n] modules of type [moduleId] on the roof, returns their ids.
  Future<List<int>> placeModules(int n, int moduleId) async {
    final ids = <int>[];
    for (var i = 0; i < n; i++) {
      ids.add(await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
        roofId: 1,
        moduleId: moduleId,
        x: i.toDouble(),
        y: 0,
      )));
    }
    return ids;
  }

  /// Creates a string from the given placed-module ids on MPPT [mpp].
  Future<int> makeString(List<int> moduleIds, int invId, {int mpp = 0}) async {
    final id = await db.into(db.moduleStrings).insert(ModuleStringsCompanion.insert(
      projectId: 1,
      name: 'String ${moduleIds.length}',
      inverterId: Value(invId),
      mppIndex: Value(mpp),
    ));
    for (var p = 0; p < moduleIds.length; p++) {
      await db.into(db.stringModules).insert(StringModulesCompanion(
        stringId: Value(id),
        placedModuleId: Value(moduleIds[p]),
        position: Value(p),
      ));
    }
    return id;
  }

  EditorController controller({bool readOnly = false}) =>
      EditorController(db: db, projectId: 1, readOnly: readOnly);

  List<String> messages(List<Violation> v) =>
      v.map((e) => e.message).toList();

  group('validateProject', () {
    test('flags cold Voc above the inverter limit (error)', () async {
      // Module: Voc 50 V, gamma -0.3 %/K -> at T_cell = -35 °C (T_amb −25 − 10)
      // Voc_cold = 50 * (1 + 0.3 % * 60) = 59 V per module.
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 8);
      // Limit = min(1500, 600) = 600 V.
      final invId = await addInverter(powerKw: 5, maxInputVoltage: 600);
      final mods = await placeModules(12, mId); // STC Voc exactly 600 V
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      final v = c.validateProject();

      expect(v.where((e) => e.severity == 'error'), isNotEmpty);
      // 12 * 59 = 708 V cold > 600 V limit, although STC Voc == 600 passes.
      expect(messages(v), anyElement(contains('Voc kalt')));
    });

    test('flags hot Voc below the start-up voltage (warning)', () async {
      // At T_cell = 70 °C (T_amb 40 + 30): Voc_hot per module =
      // 50 * (1 - 0.3 % * 45) = 43.25 V -> 10 modules: 432.5 V < 450 V start-up.
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 8);
      final invId = await addInverter(
        powerKw: 5,
        minInputVoltage: 450,
        maxInputVoltage: 1500,
      );
      final mods = await placeModules(10, mId);
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      final v = c.validateProject();

      expect(v.where((e) => e.severity == 'warning'), isNotEmpty);
      expect(messages(v), anyElement(contains('Voc heiß')));
    });

    test('flags parallel Isc sum above the MPPT limit (error)', () async {
      // Two strings of 3 modules each on the same MPPT: ΣIsc = 2 * 8 A > 15 A.
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 8);
      final invId = await addInverter(
        powerKw: 5,
        mppCount: 2,
        maxInputVoltage: 1000,
        maxShortCircuitCurrentPerMpp: 15,
      );
      final mods = await placeModules(6, mId);
      await makeString(mods.sublist(0, 3), invId, mpp: 0);
      await makeString(mods.sublist(3), invId, mpp: 0);

      final c = controller();
      await c.load();
      final v = c.validateProject();

      expect(v.where((e) => e.severity == 'error'), isNotEmpty);
      expect(messages(v), anyElement(contains('ΣIsc')));
    });

    test('flags total power above the agreed feed-in limit (warning)',
        () async {
      // 2 * 600 W = 1.2 kW > maxFeedInKw 1.0.
      final mId = await addModule(pMaxW: 600, voc: 50, isc: 8);
      final invId = await addInverter(powerKw: 5, maxInputVoltage: 1000);
      final mods = await placeModules(2, mId);
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      await c.updateSiteConditions(maxFeedInKw: 1.0);

      final v = c.validateProject();
      expect(messages(v), anyElement(contains('Einspeisung')));
    });

    test('flags Class I modules without main equipotential (warning)',
        () async {
      // frameClass null -> treated as Class I; hasMainEquipotential defaults
      // to false.
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 8);
      final invId = await addInverter(powerKw: 5, maxInputVoltage: 1000);
      final mods = await placeModules(2, mId);
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      expect(messages(c.validateProject()), anyElement(contains('Potenzialausgleich')));

      // Marking the equipotential as available removes the warning.
      await c.updateSiteConditions(hasMainEquipotential: true);
      expect(messages(c.validateProject()), isNot(anyElement(contains('Potenzialausgleich'))));
    });

    test('does not flag Class II modules for earthing', () async {
      final mId = await addModule(
          pMaxW: 400, voc: 50, isc: 8, frameClass: 'II');
      final invId = await addInverter(powerKw: 5, maxInputVoltage: 1000);
      final mods = await placeModules(2, mId);
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      expect(messages(c.validateProject()), isNot(anyElement(contains('Potenzialausgleich'))));
    });

    test('recommends fuse and cable cross-section (info)', () async {
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 13.8);
      final invId = await addInverter(powerKw: 5, maxInputVoltage: 1000);
      final mods = await placeModules(2, mId);
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      final v = c.validateProject();

      // No fuse recorded -> recommendation >= 15 A (Isc 13.8).
      expect(messages(v), anyElement(contains('Sicherung')));
      // No cable recorded -> recommendation.
      expect(messages(v), anyElement(contains('Querschnitt')));

      // Fuse too small for the load current (Ib = 1.25 * Imp).
      final sId = c.strings.first.id;
      await (db.update(db.moduleStrings)..where((t) => t.id.equals(sId)))
          .write(const ModuleStringsCompanion(fuseA: Value(10)));
      await c.load();
      expect(messages(c.validateProject()), anyElement(contains('Laststrom')));
    });

    test('wallbox without RCD type B is flagged (warning)', () async {
      final wbId = await db.into(db.wallboxes).insert(WallboxesCompanion.insert(
        name: 'Test-WB',
        powerKw: 11,
        rcdType: const Value('A'), // non-compliant on purpose
      ));
      await db.into(db.scenarios).insert(ScenariosCompanion.insert(
        projectId: 1,
        name: 'Szenario',
        wallboxId: Value(wbId),
      ));

      final c = controller();
      await c.load();
      expect(messages(c.validateProject()), anyElement(contains('FI-Typ B')));

      // Switching the wallbox to type B removes the warning.
      await (db.update(db.wallboxes)..where((t) => t.id.equals(wbId)))
          .write(const WallboxesCompanion(rcdType: Value('B')));
      await c.load();
      expect(messages(c.validateProject()), isNot(anyElement(contains('FI-Typ B'))));
    });

    test('AC output current info uses the datasheet iOutA', () async {
      // GoodWe-style: powerKw 5, iOutA 8.5 -> info line with 8.5 A and a
      // recommended MCB of 10 A (next IEC rating above 8.5).
      final invId = await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'TestWR 5kW',
        powerKw: 5,
        iOutA: const Value(8.5),
      ));

      final c = controller();
      await c.load();
      // The active inverter is the only one; its info line must appear.
      expect(
        messages(c.validateProject()),
        anyElement(allOf(contains('TestWR 5kW'), contains('8.5 A'))),
      );

      // Derived case: no iOutA -> P/(U·cosφ) = 5000/400 = 12.5 A (3-phase).
      await (db.delete(db.inverters)..where((t) => t.id.equals(invId))).go();
      await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'TestWR 5kW',
        powerKw: 5,
      ));
      await c.load();
      expect(
        messages(c.validateProject()),
        anyElement(allOf(contains('TestWR 5kW'), contains('12.5 A'))),
      );
    });

    test('LS-Schalter line uses the stored mcbA and lists only the active inverter',
        () async {
      // Two inverters; only the active one (the first) may produce a line.
      await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'WR A',
        powerKw: 5,
        iOutA: const Value(8.5), // derived MCB would be 10 A
        mcbA: const Value(32), // stored value must win over the derived one
      ));
      await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'WR B',
        powerKw: 10,
      ));

      final c = controller();
      await c.load();

      final mcbLines = messages(c.validateProject())
          .where((m) => m.contains('LS-Schalter'))
          .toList();
      expect(mcbLines, hasLength(1)); // active inverter only
      expect(mcbLines.single, allOf(contains('WR A'), contains('32 A')));
    });

    test('flags Vmp outside the inverter MPP window (warning)', () async {
      // Per module: Vmp 42 V, gamma −0.3 %/K → cold (T_cell −35 °C) 48.72 V,
      // hot (T_cell +70 °C) 36.27 V; 10 modules: ≈487 / ≈363 V.
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 8, vmp: 42);
      final invId = await addInverter(
        powerKw: 5,
        minInputVoltage: 10, // keep the start-up check quiet
        maxInputVoltage: 2000,
        mppMinVoltage: 400,
        mppMaxVoltage: 500,
      );
      final mods = await placeModules(10, mId);
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      // Hot Vmp ≈363 < MPP minimum 400 → warning; cold 487 ≤ 500 is fine.
      expect(messages(c.validateProject()), anyElement(contains('Vmp heiß')));

      // Narrow the window so even cold Vmp exceeds it: 487 > 450.
      await (db.update(db.inverters)..where((t) => t.id.equals(invId)))
          .write(const InvertersCompanion(mppMaxVoltage: Value(450)));
      await c.load();
      expect(messages(c.validateProject()), anyElement(contains('Vmp kalt')));
    });

    test('feed-in check uses the inverter AC power, not DC kWp', () async {
      // 1 * 600 W = 0.6 kWp DC (below the limit), but the inverter is rated
      // 5 kW AC → the check must still fire on totalAcKw.
      final mId = await addModule(pMaxW: 600, voc: 50, isc: 8);
      final invId = await addInverter(powerKw: 5, maxInputVoltage: 1000);
      final mods = await placeModules(1, mId);
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      expect(c.totalKwp, lessThanOrEqualTo(1.0)); // DC below the limit
      await c.updateSiteConditions(maxFeedInKw: 1.0);

      expect(messages(c.validateProject()),
          anyElement(contains('AC-Nennleistung')));
    });

    test('flags single-phase feed-in above 11.5 kVA and phase mismatch',
        () async {
      // Single-phase 15 kW inverter on the default three-phase grid: both
      // the inverter-specific limit and the phase mismatch must fire.
      await addInverter(powerKw: 15, maxInputVoltage: 2000, acPhases: 1);

      final c = controller();
      await c.load();
      var v = messages(c.validateProject());
      expect(v, anyElement(contains('11,5-kVA-Einspeiselimit')));
      expect(v, anyElement(contains('passt nicht zur Netzankopplung')));

      // Single-phase grid: the project-level limit fires as well.
      await c.updateSiteConditions(gridPhases: 1);
      v = messages(c.validateProject());
      expect(v, anyElement(contains('Anlagen-AC-Leistung')));
    });

    test('wallbox charge current vs breaker/RCD rating', () async {
      // 11 kW three-phase: I_charge = 11000 / (√3 · 400) ≈ 15.9 A.
      final wbId = await db.into(db.wallboxes).insert(
          WallboxesCompanion.insert(name: 'Test-WB', powerKw: 11,
              phases: const Value(3)));
      await db.into(db.scenarios).insert(ScenariosCompanion.insert(
        projectId: 1,
        name: 'Szenario',
        wallboxId: Value(wbId),
      ));

      final c = controller();
      await c.load();
      // No ratings yet → info asking for the values.
      expect(messages(c.validateProject()),
          anyElement(contains('LS-/FI-Nennstrom angeben')));

      // Breaker below the charge current → warning; RCD 16 A still covers it.
      await (db.update(db.wallboxes)..where((t) => t.id.equals(wbId)))
          .write(const WallboxesCompanion(
              breakerA: Value(10), rcdRatedA: Value(16)));
      await c.load();
      var v = messages(c.validateProject());
      expect(v, anyElement(contains('LS-Nennstrom')));
      expect(v, isNot(anyElement(contains('FI-Nennstrom'))));

      // RCD below the charge current → warning as well.
      await (db.update(db.wallboxes)..where((t) => t.id.equals(wbId)))
          .write(const WallboxesCompanion(rcdRatedA: Value(10)));
      await c.load();
      expect(messages(c.validateProject()), anyElement(contains('FI-Nennstrom')));
    });

    test('flags mixed strings (count/type) on one MPPT', () async {
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 8);
      final mId2 = await addModule(pMaxW: 500, voc: 60, isc: 9);
      final invId = await addInverter(
          powerKw: 10, mppCount: 2, maxInputVoltage: 1500);
      final a = await placeModules(2, mId);
      final b = await placeModules(3, mId2);
      // Two strings on the same MPPT with different count AND type.
      await makeString(a, invId, mpp: 0);
      await makeString(b, invId, mpp: 0);

      final c = controller();
      await c.load();
      expect(messages(c.validateProject()), anyElement(contains('ungleiche Strings')));
    });

    test('flags battery storage without main equipotential', () async {
      final bId = await db.into(db.batteries).insert(
          BatteriesCompanion.insert(name: 'Test-Batt', capacityKwh: 10));
      await db.into(db.scenarios).insert(ScenariosCompanion.insert(
        projectId: 1,
        name: 'Szenario',
        batteryId: Value(bId),
      ));

      final c = controller();
      await c.load();
      expect(messages(c.validateProject()), anyElement(contains('Batteriesystem')));

      // Marking the equipotential as available removes the warning.
      await c.updateSiteConditions(hasMainEquipotential: true);
      expect(messages(c.validateProject()),
          isNot(anyElement(contains('Batteriesystem'))));
    });

    test('notes cable temperature derating when cross-sections are set',
        () async {
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 8);
      final invId = await addInverter(powerKw: 5, maxInputVoltage: 1000);
      final mods = await placeModules(2, mId);
      final sId = await makeString(mods, invId);

      final c = controller();
      await c.load();
      expect(messages(c.validateProject()),
          isNot(anyElement(contains('Temperaturfaktor'))));

      await (db.update(db.moduleStrings)..where((t) => t.id.equals(sId)))
          .write(const ModuleStringsCompanion(dcCableMm2: Value(4)));
      await c.load();
      expect(messages(c.validateProject()), anyElement(contains('Temperaturfaktor')));
    });

    test('recommendedFuseA returns null above the 35 A series end', () {
      expect(EditorController.recommendedFuseA(20), 20.0);
      expect(EditorController.recommendedFuseA(21), 25.0);
      expect(EditorController.recommendedFuseA(35), 35.0);
      expect(EditorController.recommendedFuseA(40), equals(null));
    });

    test('flags strings whose Isc exceeds the standard fuse series', () async {
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 38);
      final invId = await addInverter(powerKw: 5, maxInputVoltage: 1000);
      final mods = await placeModules(2, mId);
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      expect(messages(c.validateProject()),
          anyElement(contains('Aufteilung auf mehrere Strings')));
    });
  });

  group('autoAssignStrings', () {
    test('packs strings under the cold-Voc limit, not STC Voc', () async {
      // Cold Voc per module = 59 V (T_cell −35 °C); limit min(1500, 600) = 600 V.
      // STC would allow 12 modules (exactly 600 V), cold only 10
      // (11 * 59 = 649 V > 600).
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 8);
      await addInverter(
        powerKw: 5,
        mppCount: 1,
        maxStringsPerMpp: 10,
        maxInputVoltage: 600,
      );
      await placeModules(23, mId);

      final c = controller();
      await c.load();
      await c.autoAssignStrings();

      final sizes = [for (final s in c.strings) c.summaryOf(s).moduleCount];
      expect(sizes, [10, 10, 3]);

      // Every string's cold Voc must be within the limit.
      for (final s in c.strings) {
        expect(c.summaryOf(s).vocCold, lessThanOrEqualTo(600.0 + 1e-9));
      }
    });

    test('respects the parallel current sum per MPPT', () async {
      // Isc 12 A, maxShortCircuitCurrentPerMpp 18 -> at most one string per
      // MPPT (two would be 24 A). Cold Voc allows two modules per string
      // (3 * 23.6 V > 60 V limit).
      final mId = await addModule(pMaxW: 400, voc: 20, isc: 12);
      await addInverter(
        powerKw: 5,
        mppCount: 2,
        maxStringsPerMpp: 4,
        minInputVoltage: 30, // keep the hot-Voc start-up check quiet
        maxInputVoltage: 60,
        maxShortCircuitCurrentPerMpp: 18,
      );
      await placeModules(6, mId); // -> three strings of 2 (cold Voc limit)

      final c = controller();
      await c.load();
      await c.autoAssignStrings();

      expect(c.strings.length, 3);
      final mppOf = [for (final s in c.strings) s.mppIndex];
      // The first two strings go to different MPPTs (12 A each fits under
      // the 18 A limit).
      expect(mppOf[0], isNot(equals(mppOf[1])));
      // The third string has no MPPT with room (24 A > 18 A) and is placed
      // on MPPT 0 anyway — validateProject must flag the overload.
      expect(
        messages(c.validateProject()).where((m) => m.contains('ΣIsc')),
        isNotEmpty,
      );
    });

    test('clears stale strings when no modules are placed', () async {
      final mId = await addModule(pMaxW: 400, voc: 50, isc: 8);
      final invId = await addInverter(powerKw: 5, maxInputVoltage: 1000);
      final mods = await placeModules(2, mId);
      await makeString(mods, invId);

      final c = controller();
      await c.load();
      expect(c.strings, isNotEmpty);

      // Remove all placed modules and re-run.
      await (db.delete(db.placedModules)..where((t) => t.roofId.equals(1)))
          .go();
      await c.load();
      await c.autoAssignStrings();

      expect(c.strings, isEmpty);
    });
  });
}
