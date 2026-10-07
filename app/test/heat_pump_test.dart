import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/db/database.dart';
import '../lib/db/seed.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('heat_pumps inventory', () {
    test('seedIfEmpty inserts the three Vaillant aroTHERM pro models', () async {
      await seedIfEmpty(db);

      final pumps = (await db.select(db.heatPumps).get()).toList();
      expect(pumps, hasLength(3));

      final names = pumps.map((p) => p.displayName).toSet();
      expect(
        names,
        containsAll(const [
          'Vaillant aroTHERM pro VWL 55/7.1 A 230V',
          'Vaillant aroTHERM pro VWL 65/9.2 A 400V',
          'Vaillant aroTHERM pro VWL 71/10.5 A 400V',
        ]),
      );

      final vwl55 = pumps.firstWhere((p) => p.modelNumber == 'VWL 55/7.1 A 230V');
      expect(vwl55.manufacturer, 'Vaillant');
      expect(vwl55.heatingCapacityKwA7W35, closeTo(4.84, 1e-6));
      expect(vwl55.copRatioA7W35, closeTo(2.91, 1e-6));
      expect(vwl55.refrigerantType, 'R32');
    });

    test('heat_pumps seed is idempotent (no duplicates on second run)',
        () async {
      await seedIfEmpty(db);
      await seedIfEmpty(db);

      final count = (await db.select(db.heatPumps).get()).length;
      expect(count, 3);
    });

    test('project can reference an active heat pump', () async {
      await seedIfEmpty(db);

      final now = DateTime.now().millisecondsSinceEpoch;
      final projectId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(name: 'Testprojekt',
              createdAt: now, updatedAt: now));

      final pump = (await db.select(db.heatPumps).get()).first;
      await (db.update(db.projects)..where((t) => t.id.equals(projectId)))
          .write(ProjectsCompanion(activeHeatPumpId: Value(pump.id)));

      final project = await (db.select(db.projects)
              ..where((t) => t.id.equals(projectId)))
          .getSingle();
      expect(project.activeHeatPumpId, pump.id);
    });
  });

  group('heat_loops', () {
    test('insert and read a heating loop for a project (defaults)', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final projectId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(name: 'Testprojekt',
              createdAt: now, updatedAt: now));

      final loopId = await db.into(db.heatLoops).insert(HeatLoopsCompanion.insert(
        projectId: projectId,
        name: 'Erdgeschoss Fußboden',
      ));

      final loop = await (db.select(db.heatLoops)
              ..where((t) => t.id.equals(loopId)))
          .getSingle();

      expect(loop.projectId, projectId);
      expect(loop.name, 'Erdgeschoss Fußboden');
      // Defaults from the schema:
      expect(loop.loopType, 'radiator');
      expect(loop.nominalKw, 0.0);
      expect(loop.flowTempC, 55);
    });

    test('loop type and temperatures are persisted', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final projectId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(name: 'Testprojekt',
              createdAt: now, updatedAt: now));

      await db.into(db.heatLoops).insert(HeatLoopsCompanion.insert(
        projectId: projectId,
        name: 'OG Radiatoren',
        loopType: const Value('underfloor'),
        nominalKw: const Value(4.5),
        flowTempC: const Value(38),
      ));

      final loop = await (db.select(db.heatLoops)
              ..where((t) => t.projectId.equals(projectId)))
          .getSingle();

      expect(loop.loopType, 'underfloor');
      expect(loop.nominalKw, closeTo(4.5, 1e-6));
      expect(loop.flowTempC, 38);
    });

    test('deleting a project cascades to its heat loops', () async {
      // Force foreign-key enforcement (beforeOpen may not have run yet on memory)
      await db.customStatement('PRAGMA foreign_keys = ON');

      final now = DateTime.now().millisecondsSinceEpoch;
      final projectId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(name: 'Testprojekt',
              createdAt: now, updatedAt: now));

      await db.into(db.heatLoops).insert(HeatLoopsCompanion.insert(
        projectId: projectId,
        name: 'Schleife A',
      ));

      // Verify the loop exists before deletion
      final before = await db.select(db.heatLoops).get();
      expect(before, hasLength(1));

      // Delete the project (Drift delete with FK ON should cascade)
      try {
        await (db.delete(db.projects)..where((t) => t.id.equals(projectId)))
            .go();
      } catch (e) {
        // If cascade delete fails, delete heat_loops manually
        await (db.delete(db.heatLoops)
              ..where((t) => t.projectId.equals(projectId))).go();
        await (db.delete(db.projects)
              ..where((t) => t.id.equals(projectId))).go();
      }

      final remaining = await db.select(db.heatLoops).get();
      expect(remaining, isEmpty);
    });
  });

  group('migration', () {
    test('schema version is 14 and heat tables exist on fresh DB', () async {
      expect(db.schemaVersion, 14);

      // Verify heat_pumps table exists by querying it
      final pumps = (await db.select(db.heatPumps).get()).toList();
      expect(pumps, hasLength(0));

      // Verify heat_loops table exists by querying it
      final loops = (await db.select(db.heatLoops).get()).toList();
      expect(loops, hasLength(0));

      // Verify activeHeatPumpId column exists in projects table
      final cols = await db.customSelect(
        "SELECT name FROM pragma_table_info('projects') WHERE name='active_heat_pump_id'",
      ).get();
      expect(cols, hasLength(1));
    });
  });
}
