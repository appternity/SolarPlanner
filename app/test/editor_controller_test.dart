import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;
import 'package:solar_planner/core/geo.dart' show Pt, BBox, pointInPolygon;
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/db/tables.dart' show RoofType, TileMaterial;
import 'package:solar_planner/features/editor/editor_controller.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late EditorController c;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.projects).insert(ProjectsCompanion.insert(
      name: 'Testprojekt',
      createdAt: 0,
      updatedAt: 0,
    ));





    c = EditorController(db: db, projectId: 1, readOnly: false);
    await c.load();
  });

  tearDown(() async {
    await db.close();
  });

  group('addRoof', () {
    test('creates a roof with correct geometry and details', () async {
      final result = RoofFormResult(
        name: 'Neues Dach',
        lengthM: 12.0,
        widthM: 6.0,
        pitchDeg: 35.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterWidthCm: 6.0,
        rafterDepthCm: 20.0,
        rafterSpacingCm: 60.0,
        battenThicknessCm: 2.5,
        rafterStraight: true,
        hasCounterBatten: false,
        tilesVisibleWidth: 20,
        tilesVisibleHeight: 8,
        tileOverlapCm: 4.5,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: true,
        hasInsulation: true,
        insulationThicknessCm: 18.0,
      );

      await c.addRoof(result);

      expect(c.roofs.length, 1);
      final roof = c.roofs.first;
      expect(roof.name, 'Neues Dach');
      expect(roof.lengthM, 12.0);
      expect(roof.widthM, 6.0);
      expect(roof.pitchDeg, 35.0);
      expect(roof.azimuthDeg, 180.0);
      expect(roof.type, 'pitched');
      expect(roof.rafterWidthCm, 6.0);
      expect(roof.tilesVisibleWidth, 20);

      // Verify it was persisted to the DB.
      final dbRoofs = await db.roofsOf(1);
      expect(dbRoofs.length, 1);
      expect(dbRoofs.first.name, 'Neues Dach');

      // The roof should be selected after adding.
      expect(c.selectedRoofId, roof.id);
    });

    test('places the new roof to the right of existing objects', () async {
      // Add a first roof.
      await c.addRoof(RoofFormResult(
        name: 'Dach 1',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      // Add a second roof – it should be placed to the right.
      await c.addRoof(RoofFormResult(
        name: 'Dach 2',
        lengthM: 8.0,
        widthM: 4.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      expect(c.roofs.length, 2);
      final roof1 = c.roofs.firstWhere((r) => r.name == 'Dach 1');
      final roof2 = c.roofs.firstWhere((r) => r.name == 'Dach 2');

      // Roof 2 should be placed to the right of roof 1 (not overlapping).
      final poly1 = Pt.decode(roof1.polygon);
      final poly2 = Pt.decode(roof2.polygon);
      final box1 = BBox.of(poly1);
      final box2 = BBox.of(poly2);
      // The center of roof 2 should be to the right of the center of roof 1.
      expect(box2.center.x, greaterThan(box1.center.x));
      // They should not overlap in x.
      expect(box2.minX, greaterThanOrEqualTo(box1.maxX - 0.1));
    });

    test('is a no-op in read-only mode', () async {
      c = EditorController(db: db, projectId: 1, readOnly: true);
      await c.load();

      await c.addRoof(RoofFormResult(
        name: 'Sollte nicht gehen',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      expect(c.roofs.isEmpty, isTrue);
    });
  });

  group('updateRoof', () {
    test('updates name, pitch and azimuth but not geometry or type', () async {
      // Create a roof first.
      await c.addRoof(RoofFormResult(
        name: 'Altes Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      final roofId = c.roofs.first.id;
      final oldPolygon = c.roofs.first.polygon;

      // Edit: change name, pitch, azimuth.
      await c.updateRoof(roofId, RoofFormResult(
        name: 'Neuer Name',
        pitchDeg: 40.0,
        azimuthDeg: 90,
        rafterStraight: false,
        hasCounterBatten: true,
        tileMaterial: TileMaterial.concrete,
        hasSpareTiles: true,
        hasInsulation: true,
        insulationThicknessCm: 20.0,
      ));

      final updated = c.roofById(roofId)!;
      expect(updated.name, 'Neuer Name');
      expect(updated.pitchDeg, 40.0);
      expect(updated.azimuthDeg, 90.0);

      // Geometry and type must be unchanged.
      expect(updated.polygon, oldPolygon);
      expect(updated.lengthM, 10.0);
      expect(updated.widthM, 5.0);
      expect(updated.type, 'pitched');

      // Detail fields updated.
      expect(updated.rafterStraight, false);
      expect(updated.hasCounterBatten, true);
      expect(updated.tileMaterial, 'concrete');
      expect(updated.hasSpareTiles, true);
      expect(updated.insulationThicknessCm, 20.0);

      // Verify in DB.
      final dbRoof = (await db.roofsOf(1)).first;
      expect(dbRoof.name, 'Neuer Name');
    });

    test('persists module margin/gap overrides on edit (cm → m)', () async {
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 6.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      final roofId = c.roofs.first.id;

      // Edit with margin 15 cm and gap 3 cm.
      await c.updateRoof(roofId, RoofFormResult(
        name: 'Dach',
        pitchDeg: 30.0,
        azimuthDeg: 180,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
        moduleMarginCm: 15.0,
        moduleGapCm: 3.0,
      ));

      // In-memory value converted to meters.
      final updated = c.roofById(roofId)!;
      expect(updated.moduleMarginM, closeTo(0.15, 1e-9));
      expect(updated.moduleGapM, closeTo(0.03, 1e-9));

      // And it must actually be in the database (the reported bug was that
      // these were silently dropped on edit).
      final dbRoof = (await db.roofsOf(1)).first;
      expect(dbRoof.moduleMarginM, closeTo(0.15, 1e-9));
      expect(dbRoof.moduleGapM, closeTo(0.03, 1e-9));
    });

    test('is a no-op in read-only mode', () async {
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      c = EditorController(db: db, projectId: 1, readOnly: true);
      await c.load();

      final roofId = c.roofs.first.id;
      await c.updateRoof(roofId, RoofFormResult(
        name: 'Geändert?',
        pitchDeg: 45.0,
        azimuthDeg: 180,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      expect(c.roofById(roofId)!.name, 'Dach');
    });

    test('every editable field round-trips through the DB', () async {
      // Start from a roof with all detail fields empty/null.
      await c.addRoof(RoofFormResult(
        name: 'Start',
        lengthM: 10.0,
        widthM: 6.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      final roofId = c.roofs.first.id;

      // Edit: set EVERY editable field to a distinct, non-default value.
      await c.updateRoof(roofId, RoofFormResult(
        name: 'Alle Felder',
        pitchDeg: 35.0,
        azimuthDeg: 120,
        // Flachdach fields (stored even on a pitched roof; they are columns).
        flatBaseHeightCm: 12.0,
        flatAttikaHeightCm: 34.0,
        flatAttikaWidthCm: 25.0,
        // Steildach fields.
        rafterWidthCm: 6.0,
        rafterDepthCm: 14.0,
        rafterSpacingCm: 60.0,
        battenThicknessCm: 2.5,
        rafterStraight: false,
        hasCounterBatten: true,
        tilesVisibleWidth: 12,
        tilesVisibleHeight: 8,
        tileOverlapCm: 9.0,
        tileMaterial: TileMaterial.concrete,
        hasSpareTiles: true,
        hasInsulation: true,
        insulationThicknessCm: 18.0,
        // Module layout (cm in the form, stored as meters).
        moduleMarginCm: 15.0,
        moduleGapCm: 3.0,
      ));

      // Re-read from the database (not just in-memory state) to prove each
      // value was actually persisted.
      final dbRoof = (await db.roofsOf(1)).firstWhere((r) => r.id == roofId);

      expect(dbRoof.name, 'Alle Felder');
      expect(dbRoof.pitchDeg, closeTo(35.0, 1e-9));
      expect(dbRoof.azimuthDeg, closeTo(120.0, 1e-9));
      expect(dbRoof.flatBaseHeightCm, closeTo(12.0, 1e-9));
      expect(dbRoof.flatAttikaHeightCm, closeTo(34.0, 1e-9));
      expect(dbRoof.flatAttikaWidthCm, closeTo(25.0, 1e-9));
      expect(dbRoof.rafterWidthCm, closeTo(6.0, 1e-9));
      expect(dbRoof.rafterDepthCm, closeTo(14.0, 1e-9));
      expect(dbRoof.rafterSpacingCm, closeTo(60.0, 1e-9));
      expect(dbRoof.battenThicknessCm, closeTo(2.5, 1e-9));
      expect(dbRoof.rafterStraight, false);
      expect(dbRoof.hasCounterBatten, true);
      expect(dbRoof.tilesVisibleWidth, 12);
      expect(dbRoof.tilesVisibleHeight, 8);
      expect(dbRoof.tileOverlapCm, closeTo(9.0, 1e-9));
      expect(dbRoof.tileMaterial, 'concrete');
      expect(dbRoof.hasSpareTiles, true);
      expect(dbRoof.hasInsulation, true);
      expect(dbRoof.insulationThicknessCm, closeTo(18.0, 1e-9));
      expect(dbRoof.moduleMarginM, closeTo(0.15, 1e-9));
      expect(dbRoof.moduleGapM, closeTo(0.03, 1e-9));

      // Geometry and type must remain fixed (not editable in edit mode).
      expect(dbRoof.lengthM, 10.0);
      expect(dbRoof.widthM, 6.0);
      expect(dbRoof.type, 'pitched');
    });

    test('clearing a previously-set field persists null', () async {
      // Set a value, then clear it back to empty -> must persist as null.
      await c.addRoof(RoofFormResult(
        name: 'Start',
        lengthM: 10.0,
        widthM: 6.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      final roofId = c.roofs.first.id;

      await c.updateRoof(roofId, RoofFormResult(
        name: 'Start',
        pitchDeg: 30.0,
        azimuthDeg: 180,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
        rafterWidthCm: 6.0,
      ));
      var dbRoof = (await db.roofsOf(1)).firstWhere((r) => r.id == roofId);
      expect(dbRoof.rafterWidthCm, closeTo(6.0, 1e-9));

      // Now clear it (null) -> must be written back as NULL, not left at 6.
      await c.updateRoof(roofId, RoofFormResult(
        name: 'Start',
        pitchDeg: 30.0,
        azimuthDeg: 180,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      dbRoof = (await db.roofsOf(1)).firstWhere((r) => r.id == roofId);
      expect(dbRoof.rafterWidthCm, isNull,
          reason: 'clearing a field must persist NULL');
    });
  });

  group('deleteRoof', () {
    test('removes the roof and its placed modules from the DB', () async {
      await c.addRoof(RoofFormResult(
        name: 'Zu löschen',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      final roofId = c.roofs.first.id;
      expect(c.roofs.length, 1);

      await c.deleteRoof(roofId);

      expect(c.roofs.isEmpty, isTrue);
      expect(await db.roofsOf(1), isEmpty);

      // Selection should be cleared.
      expect(c.selectedRoofId, isNull);
    });

    test('is a no-op in read-only mode', () async {
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      c = EditorController(db: db, projectId: 1, readOnly: true);
      await c.load();

      final roofId = c.roofs.first.id;
      await c.deleteRoof(roofId);

      expect(c.roofs.length, 1);
    });
  });

  group('autoFillRoof', () {
    test('aligns panels to the roof heading, not the world grid', () async {
      // Provide a module type so autoFill has something to place.
      await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
        name: 'Testmodul',
        pMaxW: 400,
        voc: 38.0,
        isc: 12.0,
        widthMm: 1762,
        heightMm: 1134,
      ));

      // East-facing roof (azimuth 90°): ridge runs north-south, so panels
      // must be rotated ~±90°, not axis-aligned (rotation 0).
      await c.addRoof(RoofFormResult(
        name: 'Osthang',
        lengthM: 10.0,
        widthM: 6.0,
        pitchDeg: 30.0,
        azimuthDeg: 90,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      final roofId = c.roofs.first.id;
      await c.autoFillRoof(roofId);

      final panels = c.placed.where((pm) => pm.roofId == roofId).toList();
      expect(panels, isNotEmpty);

      // Every panel must carry the roof's heading rotation (≈ ±90° for an
      // east-facing ridge), not the world-grid default of 0.
      final expected = panels.first.rotationDeg;
      expect(expected.abs(), closeTo(90.0, 1e-6));
      for (final pm in panels) {
        expect(pm.rotationDeg, closeTo(expected, 1e-9));
      }
    });

    test('is a no-op in read-only mode', () async {
      await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
        name: 'Testmodul',
        pMaxW: 400,
        voc: 38.0,
        isc: 12.0,
        widthMm: 1762,
        heightMm: 1134,
      ));

      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      c = EditorController(db: db, projectId: 1, readOnly: true);
      await c.load();

      final roofId = c.roofs.first.id;
      await c.autoFillRoof(roofId);

      expect(c.placed.where((pm) => pm.roofId == roofId), isEmpty);
    });

    test('keeps panels within the edge margin (no overhang)', () async {
      await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
        name: 'Testmodul',
        pMaxW: 400,
        voc: 38.0,
        isc: 12.0,
        widthMm: 1762,
        heightMm: 1134,
      ));

      // South-facing pitched roof, axis-aligned (azimuth 180°).
      await c.addRoof(RoofFormResult(
        name: 'Suedhang',
        lengthM: 10.0,
        widthM: 6.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      final roofId = c.roofs.first.id;
      await c.autoFillRoof(roofId);

      final panels =
          c.placed.where((pm) => pm.roofId == roofId).toList();
      expect(panels, isNotEmpty);

      final poly = Pt.decode(c.roofs.first.polygon);
      // Every panel corner must lie inside the roof polygon (no overhang),
      // which is guaranteed by the >= one-tile-row edge margin.
      for (final pm in panels) {
        final rad = pm.rotationDeg * math.pi / 180;
        const w = 1.762, h = 1.134;
        final cosR = math.cos(rad), sinR = math.sin(rad);
        for (final (lx, ly) in [
          (-w / 2, -h / 2),
          (w / 2, -h / 2),
          (-w / 2, h / 2),
          (w / 2, h / 2)
        ]) {
          final cx = pm.x + lx * cosR - ly * sinR;
          final cy = pm.y + lx * sinR + ly * cosR;
          expect(pointInPolygon(Pt(cx, cy), poly), isTrue,
              reason: 'panel corner must stay on the roof');
        }
      }
    });

    test('per-roof margin/gap overrides change the layout', () async {
      await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
        name: 'Testmodul',
        pMaxW: 400,
        voc: 38.0,
        isc: 12.0,
        widthMm: 1762,
        heightMm: 1134,
      ));

      // Same roof twice; the second uses a much larger edge margin, so it
      // must fit fewer panels than the default-margin roof.
      Future<int> fill({double? margin, double? gap}) async {
        await c.addRoof(RoofFormResult(
          name: 'Dach',
          lengthM: 10.0,
          widthM: 6.0,
          pitchDeg: 30.0,
          azimuthDeg: 180,
          type: RoofType.pitched,
          rafterStraight: true,
          hasCounterBatten: false,
          tileMaterial: TileMaterial.clay,
          hasSpareTiles: false,
          hasInsulation: false,
          moduleMarginCm: margin != null ? margin * 100 : null,
          moduleGapCm: gap != null ? gap * 100 : null,
        ));
        final id = c.roofs.last.id;
        await c.autoFillRoof(id);
        return c.placed.where((pm) => pm.roofId == id).length;
      }

      final defaultCount = await fill();
      // 1 m edge margin on a 6 m wide roof leaves only ~4 m usable, so the
      // count must drop well below the default.
      final tightCount = await fill(margin: 1.0);

      expect(defaultCount, greaterThan(0));
      expect(tightCount, lessThan(defaultCount),
          reason: 'a larger edge margin must fit fewer panels');
    });
  });

  group('assignSelectedToActiveString', () {
    test('does not throw when assigning the same module twice (UNIQUE)',
        () async {
      // Inverter + a placed module on a roof.
      await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'Inv',
        powerKw: 10.0,
      ));
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      final roofId = c.roofs.first.id;
      await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
        roofId: roofId,
        moduleId: 1,
        x: 0.5,
        y: 0.5,
      ));

      c = EditorController(db: db, projectId: 1, readOnly: false);
      await c.load();

      final pm = c.placed.first;
      c.selectedPlacedId = pm.id;

      // First assignment creates a string + membership.
      await c.assignSelectedToActiveString();
      // Second assignment of the same module to the same string must be a
      // no-op, NOT throw UNIQUE constraint failed.
      await c.assignSelectedToActiveString();

      final memberships = await db.select(db.stringModules).get();
      expect(memberships.where((m) => m.placedModuleId == pm.id), hasLength(1));
    });

    test('moves a module from one string to another', () async {
      await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'Inv',
        powerKw: 10.0,
      ));
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      final roofId = c.roofs.first.id;
      await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
        roofId: roofId,
        moduleId: 1,
        x: 0.5,
        y: 0.5,
      ));

      c = EditorController(db: db, projectId: 1, readOnly: false);
      await c.load();

      final pm = c.placed.first;
      c.selectedPlacedId = pm.id;

      // Assign to MPPT 0 (creates string A).
      c.activeMppIndex = 0;
      await c.assignSelectedToActiveString();

      // Assign to MPPT 1 (creates string B); module must move, not duplicate.
      c.activeMppIndex = 1;
      await c.assignSelectedToActiveString();

      final memberships = await db.select(db.stringModules).get();
      expect(memberships.where((m) => m.placedModuleId == pm.id), hasLength(1));
    });
  });

  group('active selection persistence', () {
    test(
        'setActiveInverter persists the choice and keeps existing string assignments',
        () async {
      await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'Inv A',
        powerKw: 5.0,
      )); // id 1
      await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'Inv B',
        powerKw: 10.0,
      )); // id 2
      await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
        name: 'Modul',
        pMaxW: 400,
        voc: 38.0,
        isc: 12.0,
        widthMm: 1762,
        heightMm: 1134,
      ));

      // Place a couple of modules on a roof and build strings with inverter A.
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      final roofId = c.roofs.first.id;
      await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
          roofId: roofId, moduleId: 1, x: 0.5, y: 0.5));
      await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
          roofId: roofId, moduleId: 1, x: 2.5, y: 0.5));
      await c.load(); // refresh in-memory placed list
      // Select inverter A and build strings against it.
      await c.setActiveInverter(1);
      await c.autoAssignStrings();
      final stringsBefore = c.strings.length;
      expect(stringsBefore, greaterThan(0));

      // Switch to the second inverter: must persist but NOT rebuild strings.
      await c.setActiveInverter(2);

      final proj = await (db.select(db.projects)
            ..where((t) => t.id.equals(1)))
          .getSingle();
      expect(proj.activeInverterId, 2);

      // Existing string assignments are preserved (not auto-rebuilt).
      expect(c.strings.length, stringsBefore);

      // A fresh controller must restore the persisted inverter.
      final c2 = EditorController(db: db, projectId: 1, readOnly: false);
      await c2.load();
      expect(c2.activeInverterId, 2);
    });

    test('setActiveModuleType re-types placed modules and keeps string assignments',
        () async {
      await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
        name: 'Modul A',
        pMaxW: 400,
        voc: 38.0,
        isc: 12.0,
        widthMm: 1762,
        heightMm: 1134,
      )); // id 1
      await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
        name: 'Modul B',
        pMaxW: 450,
        voc: 39.0,
        isc: 14.0,
        widthMm: 1762,
        heightMm: 1134,
      )); // id 2

      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      final roofId = c.roofs.first.id;
      await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
          roofId: roofId, moduleId: 1, x: 0.5, y: 0.5));
      await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
          roofId: roofId, moduleId: 1, x: 2.5, y: 0.5));
      await c.load();

      // Build a string with module A so we can verify the assignment survives.
      await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'Inv',
        powerKw: 10.0,
      ));
      await c.load(); // refresh in-memory inverters list
      await c.setActiveInverter(1);
      await c.autoAssignStrings();
      final stringsBefore = c.strings.length;
      expect(stringsBefore, greaterThan(0));

      // Switch to module B: placed modules must be re-typed, kWp + Voc update,
      // but the string assignment (which module is in which string) survives.
      await c.setActiveModuleType(2);

      // All placed modules now carry module type 2.
      for (final pm in c.placed) {
        expect(pm.moduleId, 2);
      }

      // kWp reflects the new (higher) module power: 2 x 450 W = 0.9 kWp.
      expect(c.totalKwp, closeTo(0.9, 1e-6));

      // String count is unchanged (assignments preserved).
      expect(c.strings.length, stringsBefore);

      // The persisted choice is stored on the project.
      final proj = await (db.select(db.projects)
            ..where((t) => t.id.equals(1)))
          .getSingle();
      expect(proj.activeModuleTypeId, 2);

      // A fresh controller restores the persisted module type.
      final c2 = EditorController(db: db, projectId: 1, readOnly: false);
      await c2.load();
      expect(c2.activeModuleTypeId, 2);
    });

    test('is a no-op in read-only mode', () async {
      await db.into(db.inverters).insert(InvertersCompanion.insert(
        name: 'Inv',
        powerKw: 10.0,
      ));
      c = EditorController(db: db, projectId: 1, readOnly: true);
      await c.load();

      await c.setActiveInverter(1);

      final proj = await (db.select(db.projects)
            ..where((t) => t.id.equals(1)))
          .getSingle();
      expect(proj.activeInverterId, isNull);
    });
  });

  group('load', () {
    test('loads roofs, obstacles and placed modules for the project', () async {
      // Insert data directly.
      await db.into(db.roofs).insert(makeRoofCompanion(
        projectId: 1,
        name: 'Südhang',
      ));

      c = EditorController(db: db, projectId: 1, readOnly: false);
      await c.load();

      expect(c.roofs.length, 1);
      expect(c.roofs.first.name, 'Südhang');
    });

    test('only loads data for the given project', () async {
      // Project 1 and 2.
      await db.into(db.projects).insert(ProjectsCompanion.insert(
        name: 'Projekt 2',
        createdAt: 0,
        updatedAt: 0,
      ));

      await db.into(db.roofs).insert(makeRoofCompanion(
        projectId: 1, name: 'Dach P1'));
      await db.into(db.roofs).insert(makeRoofCompanion(
        projectId: 2, name: 'Dach P2'));

      c = EditorController(db: db, projectId: 1, readOnly: false);
      await c.load();

      expect(c.roofs.length, 1);
      expect(c.roofs.first.name, 'Dach P1');
    });
  });

  group('selection', () {
    test('selectAt picks the roof under a point', () async {
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      // The roof is placed at x >= 2 (gap + width/2), y around 0.
      // Click in the middle of it.
      final poly = Pt.decode(c.roofs.first.polygon);
      final box = BBox.of(poly);
      c.selectAt(box.center);

      expect(c.selectedRoofId, c.roofs.first.id);
    });

    test('selectAt clears selection when clicking empty space', () async {
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));

      c.selectedRoofId = c.roofs.first.id;
      // Click far away.
      c.selectAt(Pt(1000, 1000));

      expect(c.selectedRoofId, isNull);
    });
  });

  group('move', () {
    Future<(int, int)> setupRoofWithModule() async {
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      final roofId = c.roofs.first.id;
      await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
        roofId: roofId,
        moduleId: 1,
        x: 5.0,
        y: 0.0,
      ));
      c = EditorController(db: db, projectId: 1, readOnly: false);
      await c.load();
      return (roofId, c.placed.first.id);
    }

    test('moving a roof moves its assigned modules along', () async {
      final (roofId, moduleId) = await setupRoofWithModule();

      final roofBefore = Pt.decode(c.roofs.first.polygon);
      final modBefore = c.placed.first;

      // Simulate a drag with several incremental updates (as the gesture
      // reports them). The module must stay glued to the roof — i.e. its final
      // offset from the roof corner equals its original offset, not a drifted
      // one. A single update would hide the accumulation bug.
      final hit = HitResult(HitKind.roof, roofId);
      c.beginMove(hit);
      final start = Pt(0, 0); // fixed drag origin; updateMove uses from→to
      for (final step in [Pt(1, 0.5), Pt(2, 1.0), Pt(3, 2)]) {
        c.updateMove(start, step);
      }
      await c.endMove();

      final roofAfter = Pt.decode(c.roofs.first.polygon);
      final modAfter = c.placed.where((m) => m.id == moduleId).first;

      // Roof moved by (3, 2).
      expect(roofAfter[0].x - roofBefore[0].x, closeTo(3.0, 1e-9));
      expect(roofAfter[0].y - roofBefore[0].y, closeTo(2.0, 1e-9));
      // Module moved by the same total delta (no drift from repeated updates).
      expect(modAfter.x - modBefore.x, closeTo(3.0, 1e-9));
      expect(modAfter.y - modBefore.y, closeTo(2.0, 1e-9));
      // The module's offset relative to the roof corner is preserved.
      expect(modAfter.x - roofAfter[0].x,
          closeTo(modBefore.x - roofBefore[0].x, 1e-9));
      expect(modAfter.y - roofAfter[0].y,
          closeTo(modBefore.y - roofBefore[0].y, 1e-9));

      // Persisted in DB.
      final dbMod = await (db.select(db.placedModules)
            ..where((t) => t.id.equals(moduleId)))
          .getSingle();
      expect(dbMod.x, closeTo(modBefore.x + 3.0, 1e-9));
      expect(dbMod.y, closeTo(modBefore.y + 2.0, 1e-9));
    });

    test('moving a module does NOT move the roof', () async {
      final (roofId, moduleId) = await setupRoofWithModule();

      final roofBefore = Pt.decode(c.roofs.first.polygon);
      final modBefore = c.placed.first;

      // Simulate a drag on the module.
      final hit = HitResult(HitKind.module, moduleId);
      c.beginMove(hit);
      final start = Pt(0, 0);
      c.updateMove(start, Pt(-1.5, 4));
      await c.endMove();

      final roofAfter = Pt.decode(c.roofs.first.polygon);
      final modAfter = c.placed.where((m) => m.id == moduleId).first;

      // Module moved.
      expect(modAfter.x - modBefore.x, closeTo(-1.5, 1e-9));
      expect(modAfter.y - modBefore.y, closeTo(4.0, 1e-9));
      // Roof unchanged.
      for (var i = 0; i < roofBefore.length; i++) {
        expect(roofAfter[i].x, closeTo(roofBefore[i].x, 1e-9));
        expect(roofAfter[i].y, closeTo(roofBefore[i].y, 1e-9));
      }
    });

    test('moving an obstacle does not affect roofs or modules', () async {
      await c.addRoof(RoofFormResult(
        name: 'Dach',
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      final roofId = c.roofs.first.id;
      await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
        roofId: roofId,
        moduleId: 1,
        x: 5.0,
        y: 0.0,
      ));
      await db.into(db.obstacles).insert(ObstaclesCompanion.insert(
        projectId: 1,
        kind: 'chimney',
        polygon: Pt.encode([Pt(0, 0), Pt(1, 0), Pt(1, 1), Pt(0, 1)]),
        heightM: 2.5,
      ));

      c = EditorController(db: db, projectId: 1, readOnly: false);
      await c.load();

      final roofBefore = Pt.decode(c.roofs.first.polygon);
      final modBefore = c.placed.first;
      final obsId = c.obstacles.first.id;

      final hit = HitResult(HitKind.obstacle, obsId);
      c.beginMove(hit);
      c.updateMove(Pt(0, 0), Pt(2, -1));
      await c.endMove();

      final roofAfter = Pt.decode(c.roofs.first.polygon);
      final modAfter = c.placed.where((m) => m.id == modBefore.id).first;

      // Roof and module unchanged.
      for (var i = 0; i < roofBefore.length; i++) {
        expect(roofAfter[i].x, closeTo(roofBefore[i].x, 1e-9));
        expect(roofAfter[i].y, closeTo(roofBefore[i].y, 1e-9));
      }
      expect(modAfter.x, closeTo(modBefore.x, 1e-9));
      expect(modAfter.y, closeTo(modBefore.y, 1e-9));
    });
  });

  group('migration', () {
    test(
        'v2 -> v4 adds module margin/gap (roofs) and active selection (projects) columns',
        () async {
      // Write a v2 database to a temp file, then reopen it with AppDatabase
      // so onUpgrade (2 -> 4) runs and adds the v3 + v4 columns.
      final dir = Directory.systemTemp.createTempSync('sp_mig');
      final file = File('${dir.path}/db.sqlite')..createSync();

      const v2Roofs = '''CREATE TABLE roofs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_id INTEGER NOT NULL, name TEXT NOT NULL,
            polygon TEXT NOT NULL, length_m REAL NOT NULL DEFAULT 0,
            width_m REAL NOT NULL DEFAULT 0, pitch_deg REAL NOT NULL DEFAULT 30,
            azimuth_deg REAL NOT NULL DEFAULT 180, type TEXT NOT NULL DEFAULT 'pitched',
            flat_base_height_cm REAL, flat_attika_height_cm REAL,
            flat_attika_width_cm REAL, rafter_width_cm REAL, rafter_depth_cm REAL,
            rafter_spacing_cm REAL, batten_thickness_cm REAL,
            rafter_straight INTEGER NOT NULL DEFAULT 1,
            has_counter_batten INTEGER NOT NULL DEFAULT 0,
            tiles_visible_width INTEGER, tiles_visible_height INTEGER,
            tile_overlap_cm REAL, tile_material TEXT NOT NULL DEFAULT 'clay',
            has_spare_tiles INTEGER NOT NULL DEFAULT 0,
            has_insulation INTEGER NOT NULL DEFAULT 0, insulation_thickness_cm REAL
          )''';
      const v2Projects = '''CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
            address TEXT NOT NULL DEFAULT '', latitude REAL NOT NULL DEFAULT 51.0,
            longitude REAL NOT NULL DEFAULT 10.0, created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )''';
      // Seed a v2 database (no module_margin_m / gap, no active selection)
      // using raw sqlite3.
      final dbFile = file.path;
      final conn = sqlite3.open(dbFile);
      try {
        conn.execute('PRAGMA user_version = 2');
        conn.execute(v2Projects);
        conn.execute(v2Roofs);
        conn
            .execute("INSERT INTO roofs (project_id, name, polygon) VALUES (1, 'Alt', '[]')");
      } finally {
        conn.close();
      }

      // Open with AppDatabase -> triggers onUpgrade (from 2 to 4).
      final db3 = AppDatabase(NativeDatabase(File(dbFile)));
      final roofCols = await db3
          .customSelect("SELECT name FROM pragma_table_info('roofs')")
          .get();
      final roofNames = roofCols.map((r) => r.data['name'] as String).toSet();
      expect(roofNames, contains('module_margin_m'));
      expect(roofNames, contains('module_gap_m'));

      final projCols = await db3
          .customSelect("SELECT name FROM pragma_table_info('projects')")
          .get();
      final projNames = projCols.map((r) => r.data['name'] as String).toSet();
      expect(projNames, contains('active_module_type_id'));
      expect(projNames, contains('active_inverter_id'));

      // The pre-existing row survives the migration.
      final rows = await db3.customSelect('SELECT name FROM roofs').get();
      expect(rows.map((r) => r.data['name'] as String), contains('Alt'));

      await db3.close();
      dir.deleteSync(recursive: true);
    });

    test('v5 -> v6 adds mcb_a and backfills it from the datasheet values',
        () async {
      final dir = Directory.systemTemp.createTempSync('sp_mig_v6');
      final file = File('${dir.path}/db.sqlite')..createSync();

      const v5Inverters = '''CREATE TABLE inverters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
            power_kw REAL NOT NULL, mpp_count INTEGER NOT NULL DEFAULT 1,
            max_strings_per_mpp INTEGER NOT NULL DEFAULT 1,
            min_input_voltage REAL, max_input_voltage REAL,
            max_input_current_per_mpp REAL, max_short_circuit_current_per_mpp REAL,
            ac_phases INTEGER NOT NULL DEFAULT 3, dc_voltage_class TEXT,
            i_out_a REAL, is_hybrid INTEGER NOT NULL DEFAULT 0
          )''';
      final conn = sqlite3.open(file.path);
      try {
        conn.execute('PRAGMA user_version = 5');
        conn.execute(v5Inverters);
        // Datasheet value -> MCB 10 A (next IEC rating above 8.5).
        conn.execute(
            "INSERT INTO inverters (name, power_kw, i_out_a) VALUES ('A', 5.0, 8.5)");
        // No i_out_a -> derived P/(U·cosφ) = 5000/400 = 12.5 A -> MCB 16 A.
        conn.execute(
            "INSERT INTO inverters (name, power_kw) VALUES ('B', 5.0)");
      } finally {
        conn.close();
      }

      final db6 = AppDatabase(NativeDatabase(File(file.path)));
      try {
        final cols = await db6
            .customSelect("SELECT name FROM pragma_table_info('inverters')")
            .get();
        expect(cols.map((r) => r.data['name'] as String), contains('mcb_a'));

        final rows = await db6
            .customSelect('SELECT name, mcb_a FROM inverters ORDER BY name')
            .get();
        final byName = {for (final r in rows)
          r.data['name'] as String: r.data['mcb_a']};
        expect(byName['A'], 10);
        expect(byName['B'], 16);
      } finally {
        await db6.close();
        dir.deleteSync(recursive: true);
      }
    });

    test('v6 -> v7 normalizes t_ambient_min_c to the fixed −25 °C', () async {
      final dir = Directory.systemTemp.createTempSync('sp_mig_v7');
      final file = File('${dir.path}/db.sqlite')..createSync();

      const v6Projects = '''CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
            address TEXT NOT NULL DEFAULT '', latitude REAL NOT NULL DEFAULT 51.0,
            longitude REAL NOT NULL DEFAULT 10.0, created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL, active_module_type_id INTEGER,
            active_inverter_id INTEGER, t_ambient_min_c REAL NOT NULL DEFAULT 5,
            t_ambient_max_c REAL NOT NULL DEFAULT 40, grid_phases INTEGER NOT NULL DEFAULT 3,
            max_feed_in_kw REAL, has_main_equipotential INTEGER NOT NULL DEFAULT 0,
            is_bolted_mounting INTEGER NOT NULL DEFAULT 1
          )''';
      final conn = sqlite3.open(file.path);
      try {
        conn.execute('PRAGMA user_version = 6');
        conn.execute(v6Projects);
        // Old default (5 °C) from before T_min became a fixed constant.
        conn.execute(
            "INSERT INTO projects (name, created_at, updated_at) VALUES ('Alt', 0, 0)");
      } finally {
        conn.close();
      }

      final db7 = AppDatabase(NativeDatabase(File(file.path)));
      try {
        final row = await db7
            .customSelect('SELECT t_ambient_min_c FROM projects')
            .getSingle();
        expect(row.data['t_ambient_min_c'], -25.0);
      } finally {
        await db7.close();
        dir.deleteSync(recursive: true);
      }
    });

    test('v7 -> v8 adds MPP window (inverters) and breaker/RCD ratings (wallboxes)',
        () async {
      final dir = Directory.systemTemp.createTempSync('sp_mig_v8');
      final file = File('${dir.path}/db.sqlite')..createSync();

      const v7Inverters = '''CREATE TABLE inverters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
            power_kw REAL NOT NULL, mpp_count INTEGER NOT NULL DEFAULT 1,
            max_strings_per_mpp INTEGER NOT NULL DEFAULT 1,
            min_input_voltage REAL, max_input_voltage REAL,
            max_input_current_per_mpp REAL, max_short_circuit_current_per_mpp REAL,
            ac_phases INTEGER NOT NULL DEFAULT 3, dc_voltage_class TEXT,
            i_out_a REAL, mcb_a INTEGER, is_hybrid INTEGER NOT NULL DEFAULT 0
          )''';
      const v7Wallboxes = '''CREATE TABLE wallboxes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
            power_kw REAL NOT NULL, phases INTEGER NOT NULL DEFAULT 3,
            rcd_type TEXT NOT NULL DEFAULT 'B'
          )''';
      final conn = sqlite3.open(file.path);
      try {
        conn.execute('PRAGMA user_version = 7');
        conn.execute(v7Inverters);
        conn.execute(v7Wallboxes);
      } finally {
        conn.close();
      }

      final db8 = AppDatabase(NativeDatabase(File(file.path)));
      try {
        final invCols = await db8
            .customSelect("SELECT name FROM pragma_table_info('inverters')")
            .get();
        final invNames = invCols.map((r) => r.data['name'] as String).toSet();
        expect(invNames, contains('mpp_min_voltage'));
        expect(invNames, contains('mpp_max_voltage'));
        expect(invNames, contains('q_kvar'));

        final wbCols = await db8
            .customSelect("SELECT name FROM pragma_table_info('wallboxes')")
            .get();
        final wbNames = wbCols.map((r) => r.data['name'] as String).toSet();
        expect(wbNames, contains('breaker_a'));
        expect(wbNames, contains('rcd_rated_a'));
      } finally {
        await db8.close();
        dir.deleteSync(recursive: true);
      }
    });
  });

  group('moduleLabels', () {
    Future<int> addRoof(String name) async {
      await c.addRoof(RoofFormResult(
        name: name,
        lengthM: 10.0,
        widthM: 5.0,
        pitchDeg: 30.0,
        azimuthDeg: 180,
        type: RoofType.pitched,
        rafterStraight: true,
        hasCounterBatten: false,
        tileMaterial: TileMaterial.clay,
        hasSpareTiles: false,
        hasInsulation: false,
      ));
      return c.roofs.last.id;
    }

    Future<int> placeModule(int roofId, double x) async {
      return db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
          roofId: roofId, moduleId: 1, x: x, y: 0.5));
    }

    /// Creates a string on MPPT tracker [mppIndex] (0-based) with the given
    /// (placedModuleId, seriesPosition) members.
    Future<int> addString(int mppIndex,
        List<(int placedId, int pos)> members) async {
      final stringId = await db.into(db.moduleStrings).insert(
        ModuleStringsCompanion.insert(
            projectId: 1, name: 'String', mppIndex: Value(mppIndex)),
      );
      for (final (pm, pos) in members) {
        await db.into(db.stringModules).insert(StringModulesCompanion.insert(
            stringId: stringId, placedModuleId: pm, position: Value(pos)));
      }
      return stringId;
    }

    test('modules without a string have no label', () async {
      final roofId = await addRoof('Dach');
      await placeModule(roofId, 0.5);
      await c.load();

      expect(c.moduleLabels, isEmpty);
    });

    test('labels are unique and formatted roofId.stringId.moduleId', () async {
      final r1 = await addRoof('Dach 1');
      final r2 = await addRoof('Dach 2');
      final a1 = await placeModule(r1, 0.5);
      final a2 = await placeModule(r1, 3.0);
      final b1 = await placeModule(r2, 0.5);

      // Two strings on different MPPT trackers (1 and 2).
      await addString(0, [(a1, 0), (a2, 1)]);
      await addString(1, [(b1, 0)]);
      await c.load();

      final labels = c.moduleLabels;
      expect(labels, {a1: '1.1.1', a2: '1.1.2', b1: '2.2.1'});

      final values = labels.values.toList();
      expect(values.toSet().length, values.length); // all unique
      for (final v in values) {
        expect(v, matches(RegExp(r'^\d+\.\d+\.\d+$')));
      }
    });

    test('roofId ranks only roofs that carry modules, gap-free', () async {
      final r1 = await addRoof('Dach 1'); // has modules -> rank 1
      await addRoof('Dach 2'); // no modules -> skipped, must not consume a rank
      final r3 = await addRoof('Dach 3'); // has modules -> rank 2
      final a = await placeModule(r1, 0.5);
      final b = await placeModule(r3, 0.5);

      await addString(0, [(a, 0), (b, 1)]);
      await c.load();

      // The empty roof (r2) must not consume a rank: b gets '2.', never '3.'
      expect(c.moduleLabels, {a: '1.1.1', b: '2.1.2'});
      for (final v in c.moduleLabels.values) {
        expect(v, isNot(startsWith('3.')));
      }
    });

    test('parallel strings on one MPPT number modules continuously', () async {
      final r1 = await addRoof('Dach');
      final m1 = await placeModule(r1, 0.5);
      final m2 = await placeModule(r1, 3.0);
      final m3 = await placeModule(r1, 5.5);

      // Two parallel strings on tracker 0 (stringId 1): continuous numbering.
      await addString(0, [(m1, 0), (m2, 1)]); // created first
      await addString(0, [(m3, 0)]); // parallel with the first
      await c.load();

      expect(c.moduleLabels, {m1: '1.1.1', m2: '1.1.2', m3: '1.1.3'});
    });

    test('moduleLabel() returns null for unassigned modules', () async {
      final r1 = await addRoof('Dach');
      final a = await placeModule(r1, 0.5); // no string at all
      final b = await placeModule(r1, 3.0);

      await addString(0, [(b, 0)]);
      await c.load();

      expect(c.moduleLabel(a), isNull);
      expect(c.moduleLabel(b), '1.1.1');
    });
  });
}
