import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/geo.dart';
import '../../db/database.dart';
import '../../db/electrical.dart' show inverterOutputCurrentA, recommendedMcbA;
import '../../db/tables.dart' show RoofType, RoofTypeX;

export 'roof_dialogs.dart' show RoofFormResult;
import 'roof_dialogs.dart';

/// Holds the editor state and performs all mutations on the database.
///
/// All changes are persisted immediately (writer mode). In reader mode the
/// database is read-only and mutating methods are no-ops.
class EditorController extends ChangeNotifier {
  final AppDatabase db;
  final int projectId;
  final bool readOnly;

  /// The project row (site conditions for the VDE checks).
  Project? project;

  /// Scenarios of this project (for the wallbox RCD check).
  List<Scenario> scenarios = [];

  /// Wallbox catalog (for the wallbox RCD check).
  List<Wallbox> wallboxes = [];

  List<Roof> roofs = [];
  List<Obstacle> obstacles = [];
  List<PlacedModule> placed = [];
  List<ModuleString> strings = [];
  List<SolarModule> moduleTypes = [];
  List<Inverter> inverters = [];

  /// placedModuleId -> stringId (modules not in a string are absent).
  Map<int, int> placedToString = {};

  /// String memberships (with series position) for this project's strings.
  List<StringModule> _stringMemberships = [];

  int? selectedRoofId;
  int? selectedPlacedId;
  int? selectedObstacleId;

  /// What the next canvas tap does.
  EditorMode mode = EditorMode.select;

  bool get placing => mode == EditorMode.placeModule;

  /// Unique `{roofId}.{stringId}.{moduleId}` identifier for every placed module
  /// that belongs to a string. Modules not yet assigned to any string are absent.
  ///
  /// - **roofId** – 1-based rank of the module's roof among the roofs that carry
  ///   at least one placed module, ordered by creation (`Roofs.id`); no gaps.
  /// - **stringId** – the module's MPPT-tracker number: `mppIndex + 1` of its
  ///   string, global per project (tracker 1 counts up from the first MPPT).
  /// - **moduleId** – 1-based position within that tracker. When several parallel
  ///   strings share a tracker they are numbered continuously (string creation
  ///   order, then series position) so every identifier stays unique.
  Map<int, String> get moduleLabels {
    final placedById = {for (final m in placed) m.id: m};

    // roofId: rank roofs that carry at least one module, by creation order.
    final moduleRoofs = placed.map((m) => m.roofId).toSet();
    final roofRank = <int, int>{};
    var rank = 0;
    for (final r in [...roofs]..sort((a, b) => a.id.compareTo(b.id))) {
      if (moduleRoofs.contains(r.id)) roofRank[r.id] = ++rank;
    }

    // Group memberships by MPPT tracker (stringId) for continuous numbering.
    final stringById = {for (final s in strings) s.id: s};
    final byTracker = <int, List<StringModule>>{};
    for (final m in _stringMemberships) {
      final s = stringById[m.stringId];
      if (s == null) continue;
      byTracker.putIfAbsent((s.mppIndex ?? 0) + 1, () => []).add(m);
    }

    final labels = <int, String>{};
    for (final entry in byTracker.entries) {
      final members = [...entry.value]
        ..sort((a, b) => a.stringId != b.stringId
            ? a.stringId.compareTo(b.stringId)
            : a.position.compareTo(b.position));
      for (var i = 0; i < members.length; i++) {
        final pm = placedById[members[i].placedModuleId];
        if (pm == null) continue;
        final roofNum = roofRank[pm.roofId];
        if (roofNum == null) continue; // module's roof carries no other context
        labels[members[i].placedModuleId] = '$roofNum.${entry.key}.${i + 1}';
      }
    }
    return labels;
  }

  /// The `{roofId}.{stringId}.{moduleId}` identifier for [placedModuleId], or
  /// null when the module is not part of any string.
  String? moduleLabel(int placedModuleId) => moduleLabels[placedModuleId];
  bool get addingObstacle => mode == EditorMode.addObstacle;

  /// Whether the user may change geometry (move objects, edit roofs ...).
  bool get canEdit => _canEdit;

  void setMode(EditorMode m) {
    mode = m;
    _changed();
  }

  int? activeModuleTypeId;
  int? activeInverterId;
  int? activeMppIndex;

  EditorController({
    required this.db,
    required this.projectId,
    required this.readOnly,
  });

  bool get _canEdit => !readOnly;

  void _changed() => notifyListeners();

  /// Public alias so the UI can trigger a repaint after direct field edits.
  void notifyNow() => notifyListeners();

  Future<void> load() async {
    project =
        await (db.select(db.projects)..where((t) => t.id.equals(projectId)))
            .getSingleOrNull();
    scenarios =
        await (db.select(db.scenarios)
              ..where((t) => t.projectId.equals(projectId)))
            .get();
    wallboxes = await (db.select(db.wallboxes)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    roofs = await db.roofsOf(projectId);
    obstacles = await db.obstaclesOf(projectId);
    placed = await db.placedModulesOf(projectId);
    strings = await db.stringsOf(projectId);
    moduleTypes = await (db.select(db.solarModules)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    inverters = await (db.select(db.inverters)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();

    final stringIds = strings.map((s) => s.id).toSet();
    final memberships = await db.select(db.stringModules).get();
    placedToString = {
      for (final m in memberships)
        if (stringIds.contains(m.stringId)) m.placedModuleId: m.stringId
    };
    _stringMemberships =
        memberships.where((m) => stringIds.contains(m.stringId)).toList();

    // Re-resolve when the selection is missing OR stale (the referenced
    // inventory item was deleted). Prefer the project's persisted selection;
    // fall back to the first available.
    if (moduleTypes.isNotEmpty &&
        !moduleTypes.any((m) => m.id == activeModuleTypeId)) {
      final savedModule = project?.activeModuleTypeId;
      activeModuleTypeId = (savedModule != null &&
              moduleTypes.any((m) => m.id == savedModule))
          ? savedModule
          : moduleTypes.first.id;
    }
    if (inverters.isNotEmpty &&
        !inverters.any((i) => i.id == activeInverterId)) {
      final savedInverter = project?.activeInverterId;
      activeInverterId =
          (savedInverter != null && inverters.any((i) => i.id == savedInverter))
              ? savedInverter
              : inverters.first.id;
    }
    _changed();
  }

  /// Sets the project's global module type.
  ///
  /// The active module type is a system-wide choice: switching it re-types
  /// every placed module to the new product (so the Anlage kWp total and each
  /// string's Voc sum update), while keeping which module sits in which string.
  Future<void> setActiveModuleType(int? moduleId) async {
    if (!_canEdit || moduleId == null) return;
    final changed = activeModuleTypeId != moduleId;
    activeModuleTypeId = moduleId;
    await _persistProjectSettings();
    if (changed) {
      // Re-type all placed modules to the new product. String memberships
      // reference placed-module ids, so they are preserved untouched.
      for (final pm in placed) {
        if (pm.moduleId != moduleId) {
          await (db.update(db.placedModules)
                ..where((t) => t.id.equals(pm.id)))
              .write(PlacedModulesCompanion(moduleId: Value(moduleId)));
        }
      }
    }
    await load();
  }

  /// Persists the active inverter to the project.
  ///
  /// Existing string assignments are kept as-is; use "Alle Strings automatisch
  /// zuweisen" to rebuild them against the new inverter's limits.
  Future<void> setActiveInverter(int? inverterId) async {
    if (!_canEdit || inverterId == null) return;
    activeInverterId = inverterId;
    activeMppIndex = 0;
    await _persistProjectSettings();
    notifyNow();
  }

  Future<void> _persistProjectSettings() async {
    if (!_canEdit) return;
    final p = project;
    await (db.update(db.projects)
          ..where((t) => t.id.equals(projectId)))
        .write(ProjectsCompanion(
      activeModuleTypeId: Value(activeModuleTypeId),
      activeInverterId: Value(activeInverterId),
      tAmbientMinC:
          p == null ? const Value.absent() : Value(p.tAmbientMinC),
      tAmbientMaxC:
          p == null ? const Value.absent() : Value(p.tAmbientMaxC),
      gridPhases: p == null ? const Value.absent() : Value(p.gridPhases),
      maxFeedInKw: p == null ? const Value.absent() : Value(p.maxFeedInKw),
      hasMainEquipotential: p == null
          ? const Value.absent()
          : Value(p.hasMainEquipotential),
      isBoltedMounting:
          p == null ? const Value.absent() : Value(p.isBoltedMounting),
    ));
  }

  /// Persists the site-condition fields used by the VDE checks (grid phases,
  /// feed-in limit, equipotential / mounting flags). T_min/T_max are fixed
  /// planning constants (−25 °C / 40 °C) and are not user-editable.
  Future<void> updateSiteConditions({
    int? gridPhases,
    double? maxFeedInKw,
    bool? hasMainEquipotential,
    bool? isBoltedMounting,
  }) async {
    if (!_canEdit) return;
    // copyWith: null = keep current value. For the nullable feed-in limit
    // an explicit Value(null) clears it.
    project = project?.copyWith(
      gridPhases: gridPhases,
      maxFeedInKw:
          maxFeedInKw == null ? const Value.absent() : Value(maxFeedInKw),
      hasMainEquipotential: hasMainEquipotential,
      isBoltedMounting: isBoltedMounting,
    );
    await _persistProjectSettings();
  }

  // ------------------------------------------------------------------
  // Selection
  // ------------------------------------------------------------------

  void selectAt(Pt world) {
    for (var i = placed.length - 1; i >= 0; i--) {
      final pm = placed[i];
      final type = moduleTypeOf(pm.moduleId);
      if (type != null && _pointInModule(world, pm, type)) {
        selectedPlacedId = pm.id;
        selectedObstacleId = null;
        _changed();
        return;
      }
    }
    for (final o in obstacles) {
      if (pointInPolygon(world, Pt.decode(o.polygon))) {
        selectedObstacleId = o.id;
        selectedPlacedId = null;
        _changed();
        return;
      }
    }
    for (final r in roofs) {
      if (pointInPolygon(world, Pt.decode(r.polygon))) {
        selectedRoofId = r.id;
        selectedPlacedId = null;
        selectedObstacleId = null;
        _changed();
        return;
      }
    }
    selectedPlacedId = null;
    selectedObstacleId = null;
    selectedRoofId = null;
    _changed();
  }

  bool _pointInModule(Pt p, PlacedModule pm, SolarModule type) {
    final w = type.widthMm / 1000;
    final h = type.heightMm / 1000;
    final rad = pm.rotationDeg * math.pi / 180;
    final dx = p.x - pm.x;
    final dy = p.y - pm.y;
    final lx = dx * math.cos(rad) + dy * math.sin(rad);
    final ly = -dx * math.sin(rad) + dy * math.cos(rad);
    return lx.abs() <= w / 2 && ly.abs() <= h / 2;
  }

  /// The object under [world] (modules on top, then obstacles, then roofs),
  /// or null if the point is in empty space.
  HitResult? hitAt(Pt world) {
    for (var i = placed.length - 1; i >= 0; i--) {
      final pm = placed[i];
      final type = moduleTypeOf(pm.moduleId);
      if (type != null && _pointInModule(world, pm, type)) {
        return HitResult(HitKind.module, pm.id);
      }
    }
    for (final o in obstacles) {
      if (pointInPolygon(world, Pt.decode(o.polygon))) {
        return HitResult(HitKind.obstacle, o.id);
      }
    }
    for (final r in roofs) {
      if (pointInPolygon(world, Pt.decode(r.polygon))) {
        return HitResult(HitKind.roof, r.id);
      }
    }
    return null;
  }

  // ------------------------------------------------------------------
  // Moving objects (select mode)
  // ------------------------------------------------------------------

  /// Object currently being dragged, if any.
  HitResult? _moving;
  Pt? _moveStartPos; // module: center, obstacle/roof: centroid
  List<Pt>? _moveStartPoly;
  /// Starting positions of the modules riding on a roof being moved, keyed by
  /// module id. Needed so each update is computed from the fixed start (not
  /// re-applied to an already-moved position, which would drift the panels).
  Map<int, Pt>? _moveStartModulePos;

  bool get isMoving => _moving != null;

  /// Starts moving the object hit by [hit]. The drag gesture then reports
  /// deltas via [updateMove]; the final position is persisted by [endMove].
  void beginMove(HitResult hit) {
    if (!_canEdit || _moving != null) return;
    switch (hit.kind) {
      case HitKind.module:
        final pm = placed.where((m) => m.id == hit.id).firstOrNull;
        if (pm == null) return;
        _moveStartPos = Pt(pm.x, pm.y);
      case HitKind.obstacle:
        final o = obstacles.where((o) => o.id == hit.id).firstOrNull;
        if (o == null) return;
        _moveStartPoly = Pt.decode(o.polygon);
      case HitKind.roof:
        final r = roofs.where((r) => r.id == hit.id).firstOrNull;
        if (r == null) return;
        _moveStartPoly = Pt.decode(r.polygon);
        // Remember where each assigned module starts so it can be repositioned
        // relative to that fixed point on every update.
        _moveStartModulePos = {
          for (final m in placed.where((m) => m.roofId == hit.id))
            m.id: Pt(m.x, m.y)
        };
    }
    // Select the object while it is being moved.
    selectedPlacedId = hit.kind == HitKind.module ? hit.id : null;
    selectedObstacleId = hit.kind == HitKind.obstacle ? hit.id : null;
    selectedRoofId = hit.kind == HitKind.roof ? hit.id : null;
    _moving = hit;
  }

  /// Applies a live drag delta (world coordinates) to the moved object.
  void updateMove(Pt from, Pt to) {
    final hit = _moving;
    if (hit == null || !isMoving) return;
    final dx = to.x - from.x;
    final dy = to.y - from.y;
    switch (hit.kind) {
      case HitKind.module:
        final start = _moveStartPos!;
        for (var i = 0; i < placed.length; i++) {
          if (placed[i].id == hit.id) {
            placed = [
              ...placed.sublist(0, i),
              PlacedModule(
                id: placed[i].id,
                roofId: placed[i].roofId,
                moduleId: placed[i].moduleId,
                x: start.x + dx,
                y: start.y + dy,
                rotationDeg: placed[i].rotationDeg,
              ),
              ...placed.sublist(i + 1),
            ];
          }
        }
      case HitKind.obstacle:
        final start = _moveStartPoly!;
        for (var i = 0; i < obstacles.length; i++) {
          if (obstacles[i].id == hit.id) {
            obstacles = [
              ...obstacles.sublist(0, i),
              Obstacle(
                id: obstacles[i].id,
                projectId: obstacles[i].projectId,
                kind: obstacles[i].kind,
                polygon:
                    Pt.encode(start.map((p) => p.translate(dx, dy)).toList()),
                heightM: obstacles[i].heightM,
              ),
              ...obstacles.sublist(i + 1),
            ];
          }
        }
      case HitKind.roof:
        final start = _moveStartPoly!;
        for (var i = 0; i < roofs.length; i++) {
          if (roofs[i].id == hit.id) {
            roofs = [
              ...roofs.sublist(0, i),
              roofs[i].copyWith(
                polygon:
                    Pt.encode(start.map((p) => p.translate(dx, dy)).toList()),
              ),
              ...roofs.sublist(i + 1),
            ];
          }
        }
        // Move the roof's assigned modules along with it. Compute each from
        // its fixed start position (not the current one) so repeated updates
        // don't accumulate and drift the panels away from the roof.
        final startPos = _moveStartModulePos;
        if (startPos != null) {
          for (var i = 0; i < placed.length; i++) {
            final s = startPos[placed[i].id];
            if (s == null) continue;
            placed = [
              ...placed.sublist(0, i),
              PlacedModule(
                id: placed[i].id,
                roofId: placed[i].roofId,
                moduleId: placed[i].moduleId,
                x: s.x + dx,
                y: s.y + dy,
                rotationDeg: placed[i].rotationDeg,
              ),
              ...placed.sublist(i + 1),
            ];
          }
        }
    }
    _changed();
  }

  /// Persists the dragged position (no-op if nothing was actually moved).
  Future<void> endMove() async {
    final hit = _moving;
    if (hit == null) return;
    _moving = null;
    final startPoly = _moveStartPoly;
    final startPos = _moveStartPos;
    _moveStartPos = null;
    _moveStartPoly = null;
    _moveStartModulePos = null;

    if (!_canEdit) {
      await load(); // discard the live preview made in read-only mode
      return;
    }

    switch (hit.kind) {
      case HitKind.module:
        final pm = placed.where((m) => m.id == hit.id).firstOrNull;
        if (pm != null && startPos != null) {
          if ((pm.x - startPos.x).abs() > 1e-9 || (pm.y - startPos.y).abs() > 1e-9) {
            await (db.update(db.placedModules)
                  ..where((t) => t.id.equals(pm.id)))
                .write(PlacedModulesCompanion(x: Value(pm.x), y: Value(pm.y)));
          }
        }
      case HitKind.obstacle:
        final o = obstacles.where((o) => o.id == hit.id).firstOrNull;
        if (o != null && startPoly != null) {
          final newJson = o.polygon;
          if (newJson != Pt.encode(startPoly)) {
            await (db.update(db.obstacles)..where((t) => t.id.equals(o.id)))
                .write(ObstaclesCompanion(polygon: Value(newJson)));
          }
        }
      case HitKind.roof:
        final r = roofs.where((r) => r.id == hit.id).firstOrNull;
        if (r != null && startPoly != null) {
          final newJson = r.polygon;
          if (newJson != Pt.encode(startPoly)) {
            await (db.update(db.roofs)..where((t) => t.id.equals(r.id)))
                .write(RoofsCompanion(polygon: Value(newJson)));
            // Persist the moved modules that belong to this roof.
            for (final pm in placed.where((m) => m.roofId == hit.id)) {
              await (db.update(db.placedModules)
                    ..where((t) => t.id.equals(pm.id)))
                  .write(PlacedModulesCompanion(
                      x: Value(pm.x), y: Value(pm.y)));
            }
          }
        }
    }
  }

  // ------------------------------------------------------------------
  // Roofs
  // ------------------------------------------------------------------

  Roof? roofById(int id) => roofs.where((r) => r.id == id).firstOrNull;

  /// The rightmost x coordinate of any object in the drawing area.
  double get _maxX {
    var max = 0.0;
    for (final r in roofs) {
      final box = BBox.of(Pt.decode(r.polygon));
      max = math.max(max, box.maxX);
    }
    for (final o in obstacles) {
      final box = BBox.of(Pt.decode(o.polygon));
      max = math.max(max, box.maxX);
    }
    return max;
  }

  /// Creates a new roof from the dialog result.
  ///
  /// The rectangle (length x width) is placed to the right of all existing
  /// objects, with its ridge (long edge) perpendicular to [result.azimuthDeg]
  /// so the roof faces/slopes down in that direction.
  Future<void> addRoof(RoofFormResult result) async {
    if (!_canEdit || !result.isAdd) return;

    final azRad = result.azimuthDeg * math.pi / 180;
    // Unit vector pointing where the roof faces (slopes down toward).
    final fx = math.sin(azRad);
    final fy = -math.cos(azRad); // screen y grows south
    // Ridge direction (long edge), perpendicular to the facing.
    final rx = -fy;
    final ry = fx;

    const gapM = 2.0; // spacing between existing objects and the new roof
    final cx = _maxX + gapM + result.widthM! / 2;
    const cy = 0.0;

    // Corners: center ± half-ridge (length/2) ± half-slope (width/2).
    final poly = [
      Pt(cx - rx * result.lengthM! / 2 - fx * result.widthM! / 2,
          cy - ry * result.lengthM! / 2 - fy * result.widthM! / 2),
      Pt(cx + rx * result.lengthM! / 2 - fx * result.widthM! / 2,
          cy + ry * result.lengthM! / 2 - fy * result.widthM! / 2),
      Pt(cx + rx * result.lengthM! / 2 + fx * result.widthM! / 2,
          cy + ry * result.lengthM! / 2 + fy * result.widthM! / 2),
      Pt(cx - rx * result.lengthM! / 2 + fx * result.widthM! / 2,
          cy - ry * result.lengthM! / 2 + fy * result.widthM! / 2),
    ];

    final id = await db.into(db.roofs).insert(RoofsCompanion.insert(
      projectId: projectId,
      name: result.name,
      polygon: Pt.encode(poly),
      lengthM: result.lengthM!,
      widthM: result.widthM!,
      pitchDeg: Value(result.pitchDeg),
      azimuthDeg: Value(result.azimuthDeg.toDouble()),
      type: Value(result.type!.name),
      flatBaseHeightCm: Value(result.flatBaseHeightCm),
      flatAttikaHeightCm: Value(result.flatAttikaHeightCm),
      flatAttikaWidthCm: Value(result.flatAttikaWidthCm),
      rafterWidthCm: Value(result.rafterWidthCm),
      rafterDepthCm: Value(result.rafterDepthCm),
      rafterSpacingCm: Value(result.rafterSpacingCm),
      battenThicknessCm: Value(result.battenThicknessCm),
      rafterStraight: Value(result.rafterStraight),
      hasCounterBatten: Value(result.hasCounterBatten),
      tilesVisibleWidth: Value(result.tilesVisibleWidth),
      tilesVisibleHeight: Value(result.tilesVisibleHeight),
      tileOverlapCm: Value(result.tileOverlapCm),
      tileMaterial: Value(result.tileMaterial.name),
      hasSpareTiles: Value(result.hasSpareTiles),
      hasInsulation: Value(result.hasInsulation),
      insulationThicknessCm: Value(result.insulationThicknessCm),
      moduleMarginM: Value(result.moduleMarginCm != null ? result.moduleMarginCm! / 100 : null),
      moduleGapM: Value(result.moduleGapCm != null ? result.moduleGapCm! / 100 : null),
    ));
    selectedRoofId = id;
    await load();
  }

  /// Applies the dialog result to an existing roof.
  ///
  /// Type, length and width are ignored (fixed after creation); all other
  /// values update the roof in place without repositioning it.
  Future<void> updateRoof(int id, RoofFormResult result) async {
    if (!_canEdit || result.isAdd) return;
    await (db.update(db.roofs)..where((t) => t.id.equals(id))).write(
      RoofsCompanion(
        name: Value(result.name),
        pitchDeg: Value(result.pitchDeg),
        azimuthDeg: Value(result.azimuthDeg.toDouble()),
        flatBaseHeightCm: Value(result.flatBaseHeightCm),
        flatAttikaHeightCm: Value(result.flatAttikaHeightCm),
        flatAttikaWidthCm: Value(result.flatAttikaWidthCm),
        rafterWidthCm: Value(result.rafterWidthCm),
        rafterDepthCm: Value(result.rafterDepthCm),
        rafterSpacingCm: Value(result.rafterSpacingCm),
        battenThicknessCm: Value(result.battenThicknessCm),
        rafterStraight: Value(result.rafterStraight),
        hasCounterBatten: Value(result.hasCounterBatten),
        tilesVisibleWidth: Value(result.tilesVisibleWidth),
        tilesVisibleHeight: Value(result.tilesVisibleHeight),
        tileOverlapCm: Value(result.tileOverlapCm),
        tileMaterial: Value(result.tileMaterial.name),
        hasSpareTiles: Value(result.hasSpareTiles),
        hasInsulation: Value(result.hasInsulation),
        insulationThicknessCm: Value(result.insulationThicknessCm),
        moduleMarginM: Value(result.moduleMarginCm != null ? result.moduleMarginCm! / 100 : null),
        moduleGapM: Value(result.moduleGapCm != null ? result.moduleGapCm! / 100 : null),
      ),
    );
    await load();
  }

  Future<void> deleteRoof(int id) async {
    if (!_canEdit) return;
    await (db.delete(db.placedModules)..where((t) => t.roofId.equals(id)))
        .go();
    await (db.delete(db.roofs)..where((t) => t.id.equals(id))).go();
    if (selectedRoofId == id) selectedRoofId = null;
    await load();
  }

  // ------------------------------------------------------------------
  // Obstacles
  // ------------------------------------------------------------------

  Future<void> addObstacleAt(Pt pos) async {
    if (!_canEdit) return;
    const s = 0.5;
    final poly = [
      Pt(pos.x - s, pos.y - s),
      Pt(pos.x + s, pos.y - s),
      Pt(pos.x + s, pos.y + s),
      Pt(pos.x - s, pos.y + s),
    ];
    final id = await db.into(db.obstacles).insert(ObstaclesCompanion.insert(
      projectId: projectId,
      kind: 'chimney',
      polygon: Pt.encode(poly),
      heightM: 2,
    ));
    selectedObstacleId = id;
    selectedPlacedId = null;
    await load();
  }

  Future<void> deleteObstacle(int id) async {
    if (!_canEdit) return;
    await (db.delete(db.obstacles)..where((t) => t.id.equals(id))).go();
    if (selectedObstacleId == id) selectedObstacleId = null;
    await load();
  }

  // ------------------------------------------------------------------
  // Placed modules
  // ------------------------------------------------------------------

  SolarModule? moduleTypeOf(int moduleId) {
    for (final m in moduleTypes) {
      if (m.id == moduleId) return m;
    }
    return null;
  }

  /// Places a module of the active type at [pos] on the roof containing it.
  Future<void> placeModuleAt(Pt pos) async {
    if (!_canEdit || activeModuleTypeId == null) return;
    Roof? target;
    for (final r in roofs) {
      if (pointInPolygon(pos, Pt.decode(r.polygon))) {
        target = r;
        break;
      }
    }
    if (target == null && selectedRoofId != null) {
      target = roofs
          .where((r) => r.id == selectedRoofId)
          .cast<Roof?>()
          .firstWhere((_) => true, orElse: () => null);
    }
    if (target == null) return;

    await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
      roofId: target.id,
      moduleId: activeModuleTypeId!,
      x: pos.x,
      y: pos.y,
    ));
    await load();
  }

  Future<void> deletePlaced(int id) async {
    if (!_canEdit) return;
    await (db.delete(db.stringModules)
          ..where((t) => t.placedModuleId.equals(id)))
        .go();
    await (db.delete(db.placedModules)..where((t) => t.id.equals(id))).go();
    placedToString.remove(id);
    await load();
  }

  /// Fills [roofId] with a grid of the active module type.
  Future<void> autoFillRoof(int roofId) async {
    if (!_canEdit || activeModuleTypeId == null) return;
    final roof = roofs
        .where((r) => r.id == roofId)
        .cast<Roof?>()
        .firstWhere((_) => true, orElse: () => null);
    final type = moduleTypeOf(activeModuleTypeId!);
    if (roof == null || type == null) return;
    final poly = Pt.decode(roof.polygon);
    final box = BBox.of(poly);

    final existing = placed.where((pm) => pm.roofId == roofId).toList();
    for (final pm in existing) {
      await (db.delete(db.stringModules)
            ..where((t) => t.placedModuleId.equals(pm.id)))
          .go();
    }
    if (existing.isNotEmpty) {
      await (db.delete(db.placedModules)
            ..where((t) => t.roofId.equals(roofId)))
          .go();
    }

    final w = type.widthMm / 1000;
    final h = type.heightMm / 1000;

    // Placement rules derived from the installation transcripts:
    //
    // Steildach (pitched):
    //  - Edge margin: at least one tile row free (~5 cm) so a module never
    //    overhangs the roof edge.
    //  - 2 cm between modules for the clamps, +5 cm at the ends for end-clamps.
    //
    // Flachdach (flat):
    //  - Panels sit on ballasted rails tilted ~10°; two rails per module with
    //    rail center-to-center = module length + 2 cm (clamp width).
    //  - Ost-West (bifacial) layout packs tighter; single-direction needs a
    //    larger gap so rows don't shade each other. We use the tighter, more
    //    common case here.
    final isFlat = roof.type == 'flat';
    const clampCm = 2.0; // module-to-module clamp width
    double margin;
    double gap;
    if (isFlat) {
      // Flat roof: keep a small clearance to the parapet/edge and use the
      // clamp width between panels.
      margin = 0.15; // 15 cm edge clearance
      gap = clampCm / 100;
    } else {
      // Pitched roof: one tile row (~5 cm) free at the edge, 2 cm between.
      margin = 0.05; // ~one tile row
      gap = clampCm / 100;
    }
    // Per-roof overrides from the form (null = keep the defaults above).
    final mOverride = roof.moduleMarginM;
    if (mOverride != null && mOverride >= 0) margin = mOverride;
    final gOverride = roof.moduleGapM;
    if (gOverride != null && gOverride >= 0) gap = gOverride;

    // Lay the panels out in a local frame aligned with the roof's compass
    // heading instead of the world grid. The ridge (long edge) runs along
    // [rx,ry] and the slope/facing direction (short edge) along [fx,fy],
    // derived from the roof azimuth exactly as in addRoof.
    final azRad = roof.azimuthDeg * math.pi / 180;
    final fx = math.sin(azRad);
    final fy = -math.cos(azRad); // screen y grows south
    final rx = -fy;
    final ry = fx;
    // Panel rotation so its local X (width) follows the ridge direction.
    final panelRotDeg = math.atan2(ry, rx) * 180 / math.pi;

    // Roof center and half-extents along the two local axes.
    final cx = (box.minX + box.maxX) / 2;
    final cy = (box.minY + box.maxY) / 2;
    // Project the polygon onto each local axis to get usable extents.
    double projMin(double a, double b) =>
        poly.map((p) => (p.x - cx) * a + (p.y - cy) * b).reduce(math.min);
    double projMax(double a, double b) =>
        poly.map((p) => (p.x - cx) * a + (p.y - cy) * b).reduce(math.max);
    final ridgeMin = projMin(rx, ry), ridgeMax = projMax(rx, ry);
    final slopeMin = projMin(fx, fy), slopeMax = projMax(fx, fy);

    // Iterate a grid in the local (ridge, slope) frame.
    for (var s = slopeMin + h / 2 + margin;
        s <= slopeMax - h / 2 - margin;
        s += h + gap) {
      for (var r = ridgeMin + w / 2 + margin;
          r <= ridgeMax - w / 2 - margin;
          r += w + gap) {
        // Local offset from roof center, transformed to world coordinates.
        final wx = cx + rx * r + fx * s;
        final wy = cy + ry * r + fy * s;

        // Panel corners in world space (rotated by panelRotDeg).
        final rad = panelRotDeg * math.pi / 180;
        final cosR = math.cos(rad), sinR = math.sin(rad);
        Pt corner(double lx, double ly) =>
            Pt(wx + lx * cosR - ly * sinR, wy + lx * sinR + ly * cosR);
        final corners = [
          corner(-w / 2, -h / 2),
          corner(w / 2, -h / 2),
          corner(-w / 2, h / 2),
          corner(w / 2, h / 2),
        ];
        if (corners.every((c) => pointInPolygon(c, poly))) {
          await db.into(db.placedModules).insert(PlacedModulesCompanion.insert(
            roofId: roofId,
            moduleId: type.id,
            x: wx,
            y: wy,
            rotationDeg: Value(panelRotDeg),
          ));
        }
      }
    }
    await load();
  }

  // ------------------------------------------------------------------
  // Strings
  // ------------------------------------------------------------------

  Inverter? get activeInverter {
    for (final i in inverters) {
      if (i.id == activeInverterId) return i;
    }
    return null;
  }

  /// Assigns the selected placed module to the active inverter/MPPT,
  /// creating a new string if needed.
  Future<void> assignSelectedToActiveString() async {
    if (!_canEdit || selectedPlacedId == null) return;
    final inv = activeInverter;
    if (inv == null) return;

    int? stringId;
    for (final s in strings) {
      if (s.inverterId == inv.id && s.mppIndex == activeMppIndex) {
        final count = await (db.select(db.stringModules)
              ..where((t) => t.stringId.equals(s.id)))
            .get();
        if (count.length < 60) {
          stringId = s.id;
          break;
        }
      }
    }
    stringId ??= await db.into(db.moduleStrings).insert(ModuleStringsCompanion.insert(
        projectId: projectId,
        name: 'String ${strings.length + 1}',
        inverterId: Value(inv.id),
        mppIndex: Value(activeMppIndex ?? 0),
      ));
    final sid = stringId;

    // A module belongs to exactly one string. If it is already in the target
    // string, nothing to do (re-inserting would violate the UNIQUE constraint
    // on (string_id, placed_module_id)). If it is in a different string,
    // remove it from that one first.
    final moduleId = selectedPlacedId!;
    if (placedToString[moduleId] == sid) {
      return; // already assigned to this string
    }
    final existing = await (db.select(db.stringModules)
          ..where((t) => t.placedModuleId.equals(moduleId)))
        .get();
    for (final m in existing) {
      await (db.delete(db.stringModules)
            ..where((t) => Expression.and([
                  t.placedModuleId.equals(moduleId),
                  t.stringId.equals(m.stringId),
                ])))
          .go();
    }

    final position = await (db.select(db.stringModules)
          ..where((t) => t.stringId.equals(sid)))
        .get();
    await db.into(db.stringModules).insert(StringModulesCompanion(
      stringId: Value(sid),
      placedModuleId: Value(moduleId),
      position: Value(position.length),
    ));
    await load();
  }

  /// Greedy string builder: groups placed modules by type and packs them
  /// into strings respecting the active inverter's voltage/current limits.
  Future<void> autoAssignStrings() async {
    if (!_canEdit) return;
    final inv = activeInverter;
    if (inv == null || placed.isEmpty) {
      // Nothing to string — clear any stale strings.
      for (final s in strings) {
        await (db.delete(db.stringModules)
              ..where((t) => t.stringId.equals(s.id)))
            .go();
      }
      if (strings.isNotEmpty) {
        await (db.delete(db.moduleStrings)
              ..where((t) => t.projectId.equals(projectId)))
            .go();
      }
      strings = [];
      await load();
      return;
    }

    for (final s in strings) {
      await (db.delete(db.stringModules)
            ..where((t) => t.stringId.equals(s.id)))
          .go();
    }
    if (strings.isNotEmpty) {
      await (db.delete(db.moduleStrings)
            ..where((t) => t.projectId.equals(projectId)))
          .go();
    }
    strings = [];

    final byType = <int, List<PlacedModule>>{};
    for (final pm in placed) {
      byType.putIfAbsent(pm.moduleId, () => []).add(pm);
    }

    // Cold-Voc limit: the string must stay below both the inverter's max
    // input voltage and the 1500 V Class B limit at coldest conditions.
    final vocLimit = inv.maxInputVoltage != null
        ? math.min(1500.0, inv.maxInputVoltage!)
        : 1500.0;

    final mppCount = inv.mppCount > 0 ? inv.mppCount : 1;
    final maxPerMpp =
        inv.maxStringsPerMpp > 0 ? inv.maxStringsPerMpp : mppCount;
    final stringsPerMpp = List<int>.filled(mppCount, 0);
    // Parallel current sums per MPPT: strings on the same tracker add up.
    final mppIsc = List<double>.filled(mppCount, 0);
    final mppImp = List<double>.filled(mppCount, 0);

    var stringIdx = 0;

    for (final entry in byType.entries) {
      final type = moduleTypeOf(entry.key);
      if (type == null) continue;
      final modules = entry.value;

      // Cold Voc of a string with n modules of this type.
      final gamma = type.vocTempCoeff / 100.0;
      double vocColdOf(int n) =>
          n * type.voc * (1 + gamma * (tCellColdC - 25));

      var i = 0;
      while (i < modules.length) {
        // Pack as many modules as fit under the cold-Voc limit.
        var stringModules = <PlacedModule>[];
        while (i < modules.length) {
          if (stringModules.isNotEmpty &&
              vocColdOf(stringModules.length + 1) > vocLimit) {
            break;
          }
          stringModules.add(modules[i]);
          i++;
        }

        // Pick an MPPT with room: string count AND parallel current sums.
        var mpp = 0;
        for (var m = 0; m < mppCount; m++) {
          final iscOk = inv.maxShortCircuitCurrentPerMpp == null ||
              mppIsc[m] + type.isc <= inv.maxShortCircuitCurrentPerMpp!;
          final impOk = inv.maxInputCurrentPerMpp == null ||
              mppImp[m] + type.imp <= inv.maxInputCurrentPerMpp!;
          if (stringsPerMpp[m] < maxPerMpp && iscOk && impOk) {
            mpp = m;
            break;
          }
        }
        stringsPerMpp[mpp]++;
        mppIsc[mpp] += type.isc;
        mppImp[mpp] += type.imp;

        final id = await db.into(db.moduleStrings).insert(ModuleStringsCompanion.insert(
          projectId: projectId,
          name: 'String ${++stringIdx}',
          inverterId: Value(inv.id),
          mppIndex: Value(mpp),
        ));
        for (var p = 0; p < stringModules.length; p++) {
          await db.into(db.stringModules).insert(StringModulesCompanion(
            stringId: Value(id),
            placedModuleId: Value(stringModules[p].id),
            position: Value(p),
          ));
        }
      }
    }
    await load();
  }

  Future<void> deleteString(int id) async {
    if (!_canEdit) return;
    await (db.delete(db.stringModules)..where((t) => t.stringId.equals(id)))
        .go();
    await (db.delete(db.moduleStrings)..where((t) => t.id.equals(id))).go();
    await load();
  }

  // ------------------------------------------------------------------
  // Derived values
  // ------------------------------------------------------------------

  double get totalKwp {
    var w = 0.0;
    for (final pm in placed) {
      final t = moduleTypeOf(pm.moduleId);
      if (t != null) w += t.pMaxW;
    }
    return w / 1000;
  }

  /// Total AC rated power (kW) of the inverters used in this project: sum of
  /// `powerKw` over the distinct inverters referenced by strings. Falls back
  /// to the active inverter when no string is assigned yet (VDE-AR-N 4105 §2:
  /// the AC feed-in limit applies to the AC rated power, not DC kWp).
  double get totalAcKw {
    final ids = strings.map((s) => s.inverterId).whereType<int>().toSet();
    if (ids.isEmpty && activeInverter != null) ids.add(activeInverter!.id);
    return inverters
        .where((i) => ids.contains(i.id))
        .fold(0.0, (a, i) => a + i.powerKw);
  }

  /// The modules assigned to string [s].
  List<PlacedModule> _membersOf(ModuleString s) => placed
      .where((pm) => placedToString[pm.id] == s.id)
      .toList();

  /// Summary of a string for the UI list.
  StringSummary summaryOf(ModuleString s) {
    var count = 0;
    double vocStc = 0, vocCold = 0, vocHot = 0;
    double? vmpCold, vmpHot;
    for (final pm in _membersOf(s)) {
      final t = moduleTypeOf(pm.moduleId);
      if (t == null) continue;
      count++;
      final gamma = t.vocTempCoeff / 100.0;
      vocStc += t.voc;
      vocCold += t.voc * (1 + gamma * (tCellColdC - 25));
      vocHot += t.voc * (1 + gamma * (tCellHotC - 25));
      if (t.vmp > 0) {
        vmpCold = (vmpCold ?? 0) + t.vmp * (1 + gamma * (tCellColdC - 25));
        vmpHot = (vmpHot ?? 0) + t.vmp * (1 + gamma * (tCellHotC - 25));
      }
    }
    return StringSummary(s, count, vocStc, vocCold, vocHot,
        vmpCold: vmpCold, vmpHot: vmpHot);
  }

  // ------------------------------------------------------------------
  // VDE checks (planning aid — see docs/vde-norm-ideas.md)
  // ------------------------------------------------------------------

  /// Cell temperature for the cold-Voc check: T_ambient,min − 10 K.
  /// Cell temperature for the cold-Voc check: fixed IEC cold condition
  /// (T_min = −25 °C) minus the 10 K planning offset.
  double get tCellColdC => (project?.tAmbientMinC ?? -25) - 10;

  /// Cell temperature for the hot-Voc (start-up) check: T_ambient,max + 30 K.
  double get tCellHotC => (project?.tAmbientMaxC ?? 40) + 30;

  /// Runs all VDE planning checks for the current project state and returns
  /// them as a list of violations (errors, warnings, info notes).
  List<Violation> validateProject() {
    final out = <Violation>[];
    final inv = activeInverter;

    // -- Per string: cold Voc, hot start-up voltage ---------------------
    for (final s in strings) {
      final sum = summaryOf(s);
      if (sum.moduleCount == 0) continue;

      // Cold Voc must stay below min(1500 V Class B, inverter max input).
      final limit = inv?.maxInputVoltage != null
          ? math.min(1500.0, inv!.maxInputVoltage!)
          : 1500.0;
      if (sum.vocCold > limit) {
        out.add(Violation('error',
            '${s.name}: Voc kalt ${sum.vocCold.toStringAsFixed(0)} V > ' 
            '${limit.toStringAsFixed(0)} V (max. Eingangs-/Klasse-B-Spannung)'));
      }

      // Hot Voc must stay above the inverter's start-up voltage.
      final minV = inv?.minInputVoltage;
      if (minV != null && sum.vocHot < minV) {
        out.add(Violation('warning',
            '${s.name}: Voc heiß ${sum.vocHot.toStringAsFixed(0)} V < ' 
            '${minV.toStringAsFixed(0)} V (Startspannung) – Wechselrichter ' 
            'startet bei Hitze ggf. nicht'));
      }

      // MPP window (VDE-AR-N 4105 §3.3, planning approximation): the
      // string's Vmp must stay inside the inverter's MPP operating range for
      // both the coldest and hottest expected cell temperature.
      final mppMin = inv?.mppMinVoltage;
      if (sum.vmpHot != null && mppMin != null && sum.vmpHot! < mppMin) {
        out.add(Violation('warning',
            '${s.name}: Vmp heiß ${sum.vmpHot!.toStringAsFixed(0)} V < ' 
            'MPP-Minimum ${mppMin.toStringAsFixed(0)} V – Wechselrichter '
            ' arbeitet außerhalb des MPP-Bereichs'));
      }
      final mppMax = inv?.mppMaxVoltage;
      if (sum.vmpCold != null && mppMax != null && sum.vmpCold! > mppMax) {
        out.add(Violation('warning',
            '${s.name}: Vmp kalt ${sum.vmpCold!.toStringAsFixed(0)} V > ' 
            'MPP-Maximum ${mppMax.toStringAsFixed(0)} V – Wechselrichter '
            ' arbeitet außerhalb des MPP-Bereichs'));
      }

      // Fuse / cable cross-section (VDE 0100-443).
      final type = _dominantTypeOf(s);
      if (type != null) {
        final ib = 1.25 * type.imp; // load current of the string
        if (s.fuseA != null) {
          if (ib > s.fuseA!) {
            out.add(Violation('warning',
                '${s.name}: Laststrom Ib ≈ ${ib.toStringAsFixed(1)} A > ' 
                'Sicherung ${s.fuseA!.toStringAsFixed(0)} A'));
          }
        } else {
          final rec = recommendedFuseA(type.isc);
          if (rec == null) {
            out.add(Violation('warning',
                '${s.name}: keine Standard-DC-Sicherung für Isc ' 
                '${type.isc.toStringAsFixed(1)} A (Serie endet bei 35 A) – '
                ' größere DC-Sicherung oder Aufteilung auf mehrere Strings'));
          } else {
            out.add(Violation('info',
                '${s.name}: keine DC-Sicherung angegeben – empfohlen ≥ ' 
                '${rec.toStringAsFixed(0)} A (Isc ${type.isc.toStringAsFixed(1)} A)'));
          }
        }
        if (s.dcCableMm2 != null && s.fuseA != null) {
          final iz = cableIzA(s.dcCableMm2!);
          if (iz != null && s.fuseA! > iz) {
            out.add(Violation('warning',
                '${s.name}: Sicherung ${s.fuseA!.toStringAsFixed(0)} A > ' 
                'Leitertragfähigkeit Iz ≈ ${iz.toStringAsFixed(0)} A bei ' 
                '${s.dcCableMm2!.toStringAsFixed(1)} mm²'));
          }
        } else if (s.dcCableMm2 == null) {
          out.add(Violation('info',
              '${s.name}: kein DC-Querschnitt angegeben – empfohlen ' 
              '${recommendedCableMm2(math.max(ib, s.fuseA ?? ib)).toStringAsFixed(1)} mm²'));
        }
      }
    }

    // -- Per MPPT: parallel current sums --------------------------------
    if (inv != null) {
      for (var m = 0; m < inv.mppCount; m++) {
        var iscSum = 0.0, impSum = 0.0;
        for (final s in strings) {
          if (s.inverterId != inv.id || s.mppIndex != m) continue;
          final t = _dominantTypeOf(s);
          if (t == null) continue;
          iscSum += t.isc;
          impSum += t.imp;
        }
        if (iscSum == 0) continue;
        final maxIsc = inv.maxShortCircuitCurrentPerMpp;
        if (maxIsc != null && iscSum > maxIsc) {
          out.add(Violation('error',
              'MPPT ${m + 1}: ΣIsc ${iscSum.toStringAsFixed(1)} A > ' 
              '${maxIsc.toStringAsFixed(1)} A (parallele Strings)'));
        }
        final maxImp = inv.maxInputCurrentPerMpp;
        if (maxImp != null && impSum > maxImp) {
          out.add(Violation('warning',
              'MPPT ${m + 1}: ΣImp ${impSum.toStringAsFixed(1)} A > ' 
              '${maxImp.toStringAsFixed(1)} A (Eingangsstrom)'));
        }
      }
    }

    // -- Project level ----------------------------------------------------
    final p = project;
    if (p != null) {
      // AC output current / recommended MCB for the selected inverter only
      // (VDE-AR-N 4105 §2) — listing every inventory inverter would be noise.
      final i = activeInverter;

      // Feed-in limit (VDE-AR-N 4105 §2): the AC rated power of the
      // inverters is what matters for grid feed-in, not DC kWp.
      final maxFeedIn = p.maxFeedInKw;
      if (maxFeedIn != null && totalAcKw > maxFeedIn) {
        out.add(Violation('warning',
            'AC-Nennleistung ${totalAcKw.toStringAsFixed(1)} kW (DC '
            '${totalKwp.toStringAsFixed(1)} kWp) > vereinbarte Einspeisung '
            '${maxFeedIn.toStringAsFixed(1)} kW (Überschuss muss '
            'verbraucht/geregelt werden)'));
      }

      // Single-phase feed-in limit (VDE-AR-N 4105 §2 / grid operator rules):
      // typical cap of 11.5 kVA at a single-phase coupling point.
      if (i != null && i.acPhases == 1 && i.powerKw > 11.5) {
        out.add(Violation('warning',
            '${i.name}: einphasiger Wechselrichter übersteigt das übliche ' 
            '11,5-kVA-Einspeiselimit'));
      }
      if (p.gridPhases == 1 && totalAcKw > 11.5) {
        out.add(Violation('warning',
            'Anlagen-AC-Leistung ${totalAcKw.toStringAsFixed(1)} kW > '
            'Einphasen-Einspeiselimit (üblich 11,5 kVA)'));
      }

      // Phase mismatch between inverter and grid connection.
      if (i != null && i.acPhases != p.gridPhases) {
        out.add(Violation('warning',
            '${i.name}: Wechselrichter (${i.acPhases}~) passt nicht zur ' 
            'Netzankopplung (${p.gridPhases}~)'));
      }

      if (i != null) {
        final iOut = inverterOutputCurrentA(
            powerKw: i.powerKw, acPhases: i.acPhases, iOutA: i.iOutA);
        // Stored inventory value wins; fall back to the derived rating.
        final mcb = i.mcbA ?? recommendedMcbA(iOut).round();
        out.add(Violation('info',
            '${i.name}: I_out ≈ ${iOut.toStringAsFixed(1)} A – ' 
            'empfohlener LS-Schalter $mcb A'));
      }

      // Mixed strings on one MPPT (VDE 0100-712 §4): unequal string length
      // or module type causes circulating currents between the strings.
      if (i != null) {
        for (var m = 0; m < i.mppCount; m++) {
          final ss = strings
              .where((s) => s.inverterId == i.id && s.mppIndex == m)
              .toList();
          if (ss.length < 2) continue;
          final sigs = ss.map((s) {
            final t = _dominantTypeOf(s);
            return '${summaryOf(s).moduleCount}:${t?.id ?? -1}';
          }).toSet();
          if (sigs.length > 1) {
            out.add(Violation('warning',
                'MPPT ${m + 1} (${i.name}): ungleiche Strings (Modulanzahl ' 
                'oder -typ) – Umladestrom-Risiko'));
          }
        }
      }

      // Earthing of module frames (VDE 0100-600 §542).
      final needsEarthing = placed.any((pm) {
        final t = moduleTypeOf(pm.moduleId);
        return t != null && (t.frameClass == null || t.frameClass! != 'II');
      });
      if (needsEarthing && !p.hasMainEquipotential) {
        out.add(Violation('warning',
            'Module mit Schutzklasse I (Rahmen muss geerdet werden) – ' 
            'Haupt-Potenzialausgleich ist nicht als vorhanden markiert'));
      }

      // Ballasted flat-roof mounting → dedicated PE conductor recommended.
      final hasFlatRoof =
          roofs.any((r) => RoofTypeX.parse(r.type) == RoofType.flat);
      if (needsEarthing && hasFlatRoof && !p.isBoltedMounting) {
        out.add(Violation('warning',
            'Flachdach ohne Schraubmontage: natürlicher Schutzleiter ist ' 
            'fraglich – separaten PE-Leiter vorsehen'));
      }

      // Battery storage in the project must be part of the equipotential
      // bonding (VDE 0100-600 §543).
      if (!p.hasMainEquipotential &&
          scenarios.any((sc) => sc.batteryId != null)) {
        out.add(Violation('warning',
            'Batteriesystem im Projekt, aber Haupt-Potenzialausgleich ist '
            'nicht als vorhanden markiert – Batterie muss in den '
            'Potenzialausgleich einbezogen werden'));
      }

      // Cable temperature derating (VDE 0100-443, planning note): the Iz
      // table values assume 30 °C; DC cables on a hot roof lose ~10–20 %.
      if (strings.any((s) => s.dcCableMm2 != null)) {
        out.add(Violation('info',
            'Iz-Werte ohne Temperaturfaktor – DC-Kabel auf dem Dach '
            '(T_max 40 °C) verlieren ~10–20 % Tragfähigkeit, durch '
            'Elektroplaner korrigieren lassen'));
      }

      // Wallbox RCD type + charge current (VDE 0100-534 / -443).
      for (final sc in scenarios) {
        if (sc.wallboxId == null) continue;
        final wb = wallboxes.where((w) => w.id == sc.wallboxId).firstOrNull;
        if (wb == null) continue;
        if (wb.rcdType != 'B') {
          out.add(Violation('warning',
              '${wb.name}: Ladekreis benötigt FI-Typ B (aktuell: ' 
              '${wb.rcdType})'));
        }
        final u = wb.phases == 1 ? 230.0 : math.sqrt(3) * 400;
        final ichg = wb.powerKw * 1000 / u;
        if (wb.breakerA == null && wb.rcdRatedA == null) {
          out.add(Violation('info',
              '${wb.name}: Ladestrom ≈ ${ichg.toStringAsFixed(1)} A – '
              'LS-/FI-Nennstrom angeben, um den Check zu aktivieren'));
        } else {
          if (wb.breakerA != null && ichg > wb.breakerA!) {
            out.add(Violation('warning',
                '${wb.name}: Ladestrom ≈ ${ichg.toStringAsFixed(1)} A > '
                'LS-Nennstrom ${wb.breakerA!.toStringAsFixed(0)} A'));
          }
          if (wb.rcdRatedA != null && ichg > wb.rcdRatedA!) {
            out.add(Violation('warning',
                '${wb.name}: Ladestrom ≈ ${ichg.toStringAsFixed(1)} A > '
                'FI-Nennstrom ${wb.rcdRatedA!.toStringAsFixed(0)} A'));
          }
        }
      }
    }

    return out;
  }

  /// The module type that dominates a string (strings are homogeneous in the
  /// auto-assigner; for mixed strings this returns the type of the first
  /// member). Null if the string has no resolvable members.
  SolarModule? _dominantTypeOf(ModuleString s) {
    for (final pm in _membersOf(s)) {
      final t = moduleTypeOf(pm.moduleId);
      if (t != null) return t;
    }
    return null;
  }

  /// Next standard DC fuse rating (A) that covers [isc]: IEC 60269 series.
  /// Returns null when no standard DC fuse covers [isc] (above 35 A) — the
  /// caller must then suggest a larger DC fuse or splitting into more strings.
  static double? recommendedFuseA(double isc) {
    for (final f in const [10.0, 15.0, 20.0, 25.0, 35.0]) {
      if (isc <= f) return f;
    }
    return null; // above 35 A: no standard DC fuse in this series
  }

  /// Typical current-carrying capacity (A) of a Cu DC cable in conduit at
  /// 30 °C, for the common PV cross-sections.
  static final Map<double, double> _cableIz = {
    1.5: 14.0,
    2.5: 20,
    4: 27,
    6: 34,
    10: 50,
  };

  /// Current-carrying capacity of [mm2], or null if not in the table.
  static double? cableIzA(double mm2) => _cableIz[mm2];

  /// Smallest standard cross-section (mm²) whose Iz covers [currentA].
  static double recommendedCableMm2(double currentA) {
    const mm2 = [1.5, 2.5, 4.0, 6.0, 10.0];
    for (final c in mm2) {
      if ((cableIzA(c) ?? 0.0) >= currentA) return c;
    }
    return mm2.last;
  }

}

class StringSummary {
  final ModuleString moduleString;
  final int moduleCount;

  /// Voc sum at STC (25 °C).
  final double voc;

  /// Voc sum at coldest expected cell temperature (tCellColdC).
  final double vocCold;

  /// Voc sum at hottest expected cell temperature (tCellHotC).
  final double vocHot;

  /// Vmp sum at coldest expected cell temperature (tCellColdC). Null if no
  /// member has a Vmp value.
  final double? vmpCold;

  /// Vmp sum at hottest expected cell temperature (tCellHotC). Null if no
  /// member has a Vmp value.
  final double? vmpHot;

  const StringSummary(this.moduleString, this.moduleCount,
      this.voc, this.vocCold, this.vocHot,
      {this.vmpCold, this.vmpHot});
}

/// Result of a single VDE planning check.
class Violation {
  /// 'error' (hard requirement violated), 'warning' (should be reviewed) or
  /// 'info' (recommendation).
  final String severity;
  final String message;

  const Violation(this.severity, this.message);
}

/// What a canvas tap does.
enum EditorMode { select, placeModule, addObstacle }

/// What kind of object a canvas hit test found.
enum HitKind { module, obstacle, roof }

/// Result of a hit test in select mode.
class HitResult {
  final HitKind kind;
  final int id;

  const HitResult(this.kind, this.id);
}
