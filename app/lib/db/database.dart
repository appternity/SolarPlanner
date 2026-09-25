import 'dart:io';

import 'package:drift/drift.dart';

import '../core/geo.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show OpenMode, sqlite3;

import 'electrical.dart' show mcbRatingForInverter;
import 'tables.dart';

part 'database.g.dart';

/// The application database.
///
/// Opened either as the local working copy (writer mode, read-write)
/// or as a snapshot copy (reader mode, read-only).
@DriftDatabase(tables: [
  SolarModules,
  Inverters,
  Batteries,
  Wallboxes,
  Projects,
  Roofs,
  Obstacles,
  PlacedModules,
  ModuleStrings,
  StringModules,
  Scenarios,
  ScenarioResults,
])
class AppDatabase extends _$AppDatabase {
  /// Whether this connection is a read-only snapshot (reader mode).
  final bool readOnly;

  AppDatabase(super.e, {this.readOnly = false});

  /// Opens the database at [path].
  ///
  /// When [readOnly] is true the underlying sqlite3 connection is opened in
  /// read-only mode, so the snapshot can never be modified by accident.
  factory AppDatabase.open(String path, {bool readOnly = false}) {
    final executor = readOnly
        ? NativeDatabase.opened(sqlite3.open(path, mode: OpenMode.readOnly))
        : NativeDatabase(File(path));
    return AppDatabase(executor, readOnly: readOnly);
  }

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v1 -> v2: roofs become typed rectangles with detail fields.
            // length_m/width_m are NOT NULL but SQLite cannot add such a
            // column without a non-null default, so backfill from the stored
            // polygon (a length x width rectangle) afterwards.
            // Every step is idempotent: earlier failed runs may have left the
            // database half-migrated (columns added, but user_version not yet
            // bumped because drift only writes it after onUpgrade completes).
            await _addColumnIfMissing('roofs', 'length_m',
                'REAL NOT NULL DEFAULT 0'); // backfilled below
            await _addColumnIfMissing('roofs', 'width_m',
                'REAL NOT NULL DEFAULT 0'); // backfilled below
            await _addColumnIfMissing('roofs', 'type',
                "TEXT NOT NULL DEFAULT 'pitched'");
            await _addColumnIfMissing('roofs', 'flat_base_height_cm', 'REAL');
            await _addColumnIfMissing('roofs', 'flat_attika_height_cm', 'REAL');
            await _addColumnIfMissing('roofs', 'flat_attika_width_cm', 'REAL');
            await _addColumnIfMissing('roofs', 'rafter_width_cm', 'REAL');
            await _addColumnIfMissing('roofs', 'rafter_depth_cm', 'REAL');
            await _addColumnIfMissing('roofs', 'rafter_spacing_cm', 'REAL');
            await _addColumnIfMissing('roofs', 'batten_thickness_cm', 'REAL');
            await _addColumnIfMissing('roofs', 'rafter_straight',
                'INTEGER NOT NULL DEFAULT 1');
            await _addColumnIfMissing('roofs', 'has_counter_batten',
                'INTEGER NOT NULL DEFAULT 0');
            await _addColumnIfMissing('roofs', 'tiles_visible_width', 'INTEGER');
            await _addColumnIfMissing('roofs', 'tiles_visible_height', 'INTEGER');
            await _addColumnIfMissing('roofs', 'tile_overlap_cm', 'REAL');
            await _addColumnIfMissing('roofs', 'tile_material',
                "TEXT NOT NULL DEFAULT 'clay'");
            await _addColumnIfMissing('roofs', 'has_spare_tiles',
                'INTEGER NOT NULL DEFAULT 0');
            await _addColumnIfMissing('roofs', 'has_insulation',
                'INTEGER NOT NULL DEFAULT 0');
            await _addColumnIfMissing('roofs', 'insulation_thickness_cm', 'REAL');
            // Drop the old eave-height column (replaced by flatBaseHeightCm).
            await _dropColumnIfPresent('roofs', 'base_height_m');

            // Backfill the dimensions of existing (rectangular) roofs from
            // their polygon: length = long edge, width = short edge.
            final rows = await customSelect('SELECT id FROM roofs').get();
            for (final row in rows) {
              final id = row.data['id'] as int;
              String? polyJson;
              try {
                polyJson = (await customSelect(
                            'SELECT polygon FROM roofs WHERE id = ?',
                        variables: [Variable(id)])
                        .getSingle()).data['polygon'] as String?;
              } catch (_) {}
              if (polyJson == null) continue;
              try {
                final poly = Pt.decode(polyJson);
                if (poly.length >= 3) {
                  final box = BBox.of(poly);
                  await customStatement(
                      'UPDATE roofs SET length_m = ?, width_m = ? WHERE id = ?',
                      [box.width, box.height, id]);
                }
              } catch (_) {
                // Unparseable polygon: leave the 0 defaults; the user can
                // delete and re-add such a roof.
              }
            }
          }

          if (from < 3) {
            // v2 -> v3: per-roof module layout overrides (auto-fill margin
            // and gap). Both nullable, so no backfill needed.
            await _addColumnIfMissing('roofs', 'module_margin_m', 'REAL');
            await _addColumnIfMissing('roofs', 'module_gap_m', 'REAL');
          }

          if (from < 4) {
            // v3 -> v4: persist the project's active module type and
            // inverter selection so it survives reloads.
            await _addColumnIfMissing('projects', 'active_module_type_id',
                'INTEGER');
            await _addColumnIfMissing('projects', 'active_inverter_id',
                'INTEGER');
          }

          if (from < 5) {
            // v4 -> v5: VDE-check data. Site conditions on projects, DC/AC
            // device details on inverters, frame class on modules, RCD type
            // on wallboxes and per-string cable/fuse data.
            await _addColumnIfMissing('projects', 't_ambient_min_c',
                'REAL NOT NULL DEFAULT 5');
            await _addColumnIfMissing('projects', 't_ambient_max_c',
                'REAL NOT NULL DEFAULT 40');
            await _addColumnIfMissing('projects', 'grid_phases',
                'INTEGER NOT NULL DEFAULT 3');
            await _addColumnIfMissing('projects', 'max_feed_in_kw', 'REAL');
            await _addColumnIfMissing('projects', 'has_main_equipotential',
                'INTEGER NOT NULL DEFAULT 0');
            await _addColumnIfMissing('projects', 'is_bolted_mounting',
                'INTEGER NOT NULL DEFAULT 1');
            // All seeded inverters are three-phase (GoodWe ET PLUS+, SMA
            // STPxx-50, STPHxx-60), so the default of 3 is correct for
            // existing rows — no name-based backfill needed.
            await _addColumnIfMissing('inverters', 'ac_phases',
                'INTEGER NOT NULL DEFAULT 3');
            await _addColumnIfMissing('inverters', 'dc_voltage_class', 'TEXT');
            await _addColumnIfMissing('inverters', 'i_out_a', 'REAL');
            await _addColumnIfMissing('solar_modules', 'frame_class', 'TEXT');
            await _addColumnIfMissing('wallboxes', 'rcd_type',
                "TEXT NOT NULL DEFAULT 'B'");
            await _addColumnIfMissing('module_strings', 'dc_cable_mm2', 'REAL');
            await _addColumnIfMissing('module_strings', 'fuse_a', 'REAL');
          }

          if (from < 6) {
            // v5 -> v6: recommended MCB rating per inverter.
            await _addColumnIfMissing('inverters', 'mcb_a', 'INTEGER');
            // One-time backfill: derive from the stored datasheet values.
            // Guarded by table existence so minimal fixtures (migration
            // tests) without an inverters table still upgrade cleanly.
            final hasInverters = await customSelect(
                    "SELECT 1 FROM sqlite_master WHERE type='table' AND name='inverters'")
                .getSingleOrNull();
            if (hasInverters != null) {
              final rows = await customSelect(
                      'SELECT id, power_kw, ac_phases, i_out_a '
                      'FROM inverters WHERE mcb_a IS NULL')
                  .get();
              for (final r in rows) {
                final id = r.data['id']! as int;
                final kw = (r.data['power_kw']! as num).toDouble();
                final phases = r.data['ac_phases'] == null
                    ? 3
                    : (r.data['ac_phases']! as num).toInt();
                final iOut = (r.data['i_out_a'] as num?)?.toDouble();
                await customStatement(
                    'UPDATE inverters SET mcb_a = ? WHERE id = ?', [
                  mcbRatingForInverter(
                      powerKw: kw, acPhases: phases, iOutA: iOut),
                  id,
                ]);
              }
            }
          }

          if (from < 7) {
            // v6 -> v7: T_min becomes the fixed IEC cold condition (−25 °C)
            // and is no longer user-editable — normalize all existing
            // projects. Idempotent: the assignment is a constant, so re-running
            // after a crash mid-migration is harmless.
            final hasProjects = await customSelect(
                    "SELECT 1 FROM sqlite_master WHERE type='table' AND name='projects'")
                .getSingleOrNull();
            if (hasProjects != null) {
              await customStatement(
                  'UPDATE projects SET t_ambient_min_c = -25');
            }
          }

          if (from < 8) {
            // v7 -> v8: MPP voltage window + reactive power per inverter,
            // circuit-breaker / RCD rated currents per wallbox. All nullable
            // (no backfill in the migration — existing rows are filled from
            // the datasheets by a one-time UPDATE, see docs/vde-norm-ideas.md).
            await _addColumnIfMissing('inverters', 'mpp_min_voltage', 'REAL');
            await _addColumnIfMissing('inverters', 'mpp_max_voltage', 'REAL');
            await _addColumnIfMissing('inverters', 'q_kvar', 'REAL');
            await _addColumnIfMissing('wallboxes', 'breaker_a', 'REAL');
            await _addColumnIfMissing('wallboxes', 'rcd_rated_a', 'REAL');
          }
        },
        beforeOpen: (details) async {
          // Setting foreign_keys is a write and would fail on a read-only
          // snapshot, so only enable it for the local working copy.
          if (!readOnly) {
            await customStatement('PRAGMA foreign_keys = ON');
          }
        },
      );

  // ---------------------------------------------------------------------
  // Inventory
  // ---------------------------------------------------------------------

  Stream<List<SolarModule>> watchModules() => (select(solarModules)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Stream<List<Inverter>> watchInverters() => (select(inverters)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Stream<List<Battery>> watchBatteries() => (select(batteries)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Stream<List<Wallbox>> watchWallboxes() => (select(wallboxes)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  // ---------------------------------------------------------------------
  // Projects
  // ---------------------------------------------------------------------

  Stream<List<Project>> watchProjects() => (select(projects)
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<List<Roof>> roofsOf(int projectId) =>
      (select(roofs)..where((t) => t.projectId.equals(projectId))).get();

  Future<List<Obstacle>> obstaclesOf(int projectId) =>
      (select(obstacles)..where((t) => t.projectId.equals(projectId))).get();

  Future<List<PlacedModule>> placedModulesOf(int projectId) async {
    final roofs = await roofsOf(projectId);
    if (roofs.isEmpty) return [];
    final ids = roofs.map((r) => r.id).toList();
    return (select(placedModules)..where((t) => t.roofId.isIn(ids))).get();
  }

  Future<List<ModuleString>> stringsOf(int projectId) async {
    return (select(moduleStrings)
          ..where((t) => t.projectId.equals(projectId)))
        .get();
  }

  /// Whether [table] already has a column named [column].
  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    for (final r in rows) {
      if (r.data['name'] == column) return true;
    }
    return false;
  }

  /// Adds [column] to [table] unless it already exists.
  Future<void> _addColumnIfMissing(
      String table, String column, String type) async {
    // PRAGMA table_info returns an empty result set for a missing table
    // (it does not throw), so treat "no rows" as "table absent": a partial
    // database that never had this table has nothing to migrate.
    final rows = await customSelect('PRAGMA table_info($table)').get();
    if (rows.isEmpty) return;
    for (final r in rows) {
      if (r.data['name'] == column) return;
    }
    await customStatement('ALTER TABLE $table ADD COLUMN $column $type');
  }

  /// Drops [column] from [table] if it exists.
  Future<void> _dropColumnIfPresent(String table, String column) async {
    if (!await _hasColumn(table, column)) return;
    await customStatement('ALTER TABLE $table DROP COLUMN $column');
  }

  Future<void> touchProject(int projectId) async {
    await (update(projects)..where((t) => t.id.equals(projectId))).write(
      ProjectsCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
