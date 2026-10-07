import 'dart:io';

import 'package:drift/drift.dart';

import '../core/geo.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show OpenMode, sqlite3;

import 'electrical.dart' show mcbRatingForInverter;
import 'seed.dart' as seed show seedIfEmpty;
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
  HeatPumps,
  HeatLoops,
  // Heat pump components inventory (27 tables + shared status).
  InventoryItems,
  ComponentStatusTable,
  Boiler,
  HwVerteiler,
  Zirkulationspumpe,
  Rueckflussverhinderer,
  Schmutzfanger,
  Durchflusswaechter,
  Pufferspeicher,
  Plattenwaermetauscher,
  SafetyValve,
  Membranausdehnungsgefaess,
  Entluftungsventil,
  Heizkreispumpe,
  Absperrventil,
  FbhVerteiler,
  FbhSchleife,
  Mischbatterie,
  RfvGartenanschluss,
  FuellwasserZuleitung,
  KaltwasserVerbraucher,
  LsSchalter,
  FiSchutzschalter,
  ZuleitungStarkstrom,
  Trennschalter,
  Klemmenleiste,
  PeAnschluss,
  HpaAnschluss,
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
  int get schemaVersion => 14;

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

          if (from < 9) {
            // v8 -> v9: Haushaltsparameter (Eingabewerte) from
            // komponenten.md §1 — building/household input values.
            await _addColumnIfMissing('projects', 'personen',
                "INTEGER NOT NULL DEFAULT 4");
            await _addColumnIfMissing('projects', 'etagen',
                "INTEGER NOT NULL DEFAULT 2");
            await _addColumnIfMissing('projects', 'keller',
                "INTEGER NOT NULL DEFAULT 1");
            await _addColumnIfMissing('projects', 'baeder',
                "INTEGER NOT NULL DEFAULT 2");
            await _addColumnIfMissing('projects', 'kuechen',
                "INTEGER NOT NULL DEFAULT 1");
            await _addColumnIfMissing('projects', 'fbh_zonen',
                "INTEGER NOT NULL DEFAULT 4");
            await _addColumnIfMissing('projects', 'radiatoren',
                "INTEGER NOT NULL DEFAULT 0");
            await _addColumnIfMissing('projects', 'garten',
                "INTEGER NOT NULL DEFAULT 1");
            await _addColumnIfMissing('projects', 'wp_kw',
                "REAL NOT NULL DEFAULT 10.25");
            await _addColumnIfMissing('projects', 'hw_schleife_m',
                "INTEGER NOT NULL DEFAULT 28");
            await _addColumnIfMissing('projects', 'pv_kwp',
                "REAL NOT NULL DEFAULT 10");
            await _addColumnIfMissing('projects', 'wb_kw',
                "REAL NOT NULL DEFAULT 11");
            await _addColumnIfMissing('projects', 'wb_aussen',
                "INTEGER NOT NULL DEFAULT 1");
            await _addColumnIfMissing('projects', 'wb_komm',
                "INTEGER NOT NULL DEFAULT 1");
            await _addColumnIfMissing('projects', 'wb_ueberschuss',
                "INTEGER NOT NULL DEFAULT 0");
            await _addColumnIfMissing('projects', 'bza',
                "INTEGER NOT NULL DEFAULT 0");
            await _addColumnIfMissing('projects', 'wb_leitung_m',
                "INTEGER NOT NULL DEFAULT 30");
            await _addColumnIfMissing('projects', 'bat_kwh',
                "REAL NOT NULL DEFAULT 10");
            await _addColumnIfMissing('projects', 'bat_units',
                "INTEGER NOT NULL DEFAULT 2");
            await _addColumnIfMissing('projects', 'bat_dc_a',
                "REAL NOT NULL DEFAULT 45");
            await _addColumnIfMissing('projects', 'bat_ac_kw',
                "REAL NOT NULL DEFAULT 6.4");
            await _addColumnIfMissing('projects', 'bat_aussen',
                "INTEGER NOT NULL DEFAULT 1");
            await _addColumnIfMissing('projects', 'pv_anlage',
                "INTEGER NOT NULL DEFAULT 0");
            await _addColumnIfMissing('projects', 'bat_anlage',
                "INTEGER NOT NULL DEFAULT 0");
            await _addColumnIfMissing('projects', 'wb_anlage',
                "INTEGER NOT NULL DEFAULT 0");
            await _addColumnIfMissing('projects', 'wp_anlage',
                "INTEGER NOT NULL DEFAULT 0");
            await _addColumnIfMissing('projects', 'active_heat_pump_id',
                'INTEGER');
          }

          if (from < 13) {
            // v10 -> v12: Add heat_pumps and heat_loops tables with correct column names.
            // When upgrading from v11 that already has heat_pumps with old column names
            // (a7w35 instead of a7_w35, weightKg instead of weight_kg, etc.),
            // detect and rename columns by recreating the table and preserving data.
            // Check whether heat_pumps table exists and has old column names.
            try {
              final pragma = await customSelect(
                  'PRAGMA table_info(heat_pumps)',
              ).get();
              final colNames = pragma.map((r) => r.data['name'] as String).toList();
              final hasOldCols = colNames.any((c) =>
                  c.contains('a7w35') ||
                  c.contains('a2w35') ||
                  c == 'weightKg' ||
                  c.contains('_35C55C'));
              if (hasOldCols) {
                // Migrate old data: copy old columns to new ones.
                await customStatement(
                    'CREATE TABLE heat_pumps_migrate AS SELECT id, display_name, manufacturer, series_name, model_number, heating_capacity_kw_a7w35 AS c_a7, electrical_consumption_kw_a7w35 AS e_a7, cop_ratio_a7w35 AS cop_a7, heating_capacity_kw_a2w35 AS c_a2, electrical_consumption_kw_a2w35 AS e_a2, cop_ratio_a2w35 AS cop_a2, heating_capacity_kw_partial_load, electrical_consumption_kw_partial_load, cop_ratio_partial_load, cooling_capacity_kw, electrical_consumption_kw_cooling, eer_ratio, annual_heating_efficiency_percent, compressor_voltage_nominal_volts, compressor_frequency_hz, sound_level_erp_db_a, max_sound_level_day_night_db_a, dimensions_unpacked_width_mm, dimensions_unpacked_depth_mm, dimensions_unpacked_height_mm, weightKg AS w_kg, refrigerant_type, gwp_eu_regulation_value, refrigerant_quantity_kg_co2_equivalent, co2_equivalent_per_ton, energy_efficiency_class_35C55C AS e_class FROM heat_pumps');
                await customStatement('DROP TABLE heat_pumps');
                await customStatement(
                    'CREATE TABLE heat_pumps (id INTEGER PRIMARY KEY AUTOINCREMENT, display_name TEXT NOT NULL, manufacturer TEXT NOT NULL, series_name TEXT NOT NULL, model_number TEXT NOT NULL, heating_capacity_kw_a7_w35 REAL NOT NULL, electrical_consumption_kw_a7_w35 REAL NOT NULL, cop_ratio_a7_w35 REAL NOT NULL, heating_capacity_kw_a2_w35 REAL NOT NULL, electrical_consumption_kw_a2_w35 REAL NOT NULL, cop_ratio_a2_w35 REAL NOT NULL, heating_capacity_kw_partial_load REAL NOT NULL, electrical_consumption_kw_partial_load REAL NOT NULL, cop_ratio_partial_load REAL NOT NULL, cooling_capacity_kw REAL, electrical_consumption_kw_cooling REAL, eer_ratio REAL, annual_heating_efficiency_percent TEXT NOT NULL, compressor_voltage_nominal_volts INTEGER NOT NULL, compressor_frequency_hz INTEGER NOT NULL, sound_level_erp_db_a REAL NOT NULL, max_sound_level_day_night_db_a TEXT NOT NULL, dimensions_unpacked_width_mm INTEGER NOT NULL, dimensions_unpacked_depth_mm INTEGER NOT NULL, dimensions_unpacked_height_mm INTEGER NOT NULL, weight_kg REAL NOT NULL, refrigerant_type TEXT NOT NULL, gwp_eu_regulation_value REAL NOT NULL, refrigerant_quantity_kg_co2_equivalent REAL NOT NULL, co2_equivalent_per_ton REAL NOT NULL, energy_efficiency_class35_c55_c TEXT NOT NULL)');
                await customStatement(
                    'INSERT INTO heat_pumps (id, display_name, manufacturer, series_name, model_number, heating_capacity_kw_a7_w35, electrical_consumption_kw_a7_w35, cop_ratio_a7_w35, heating_capacity_kw_a2_w35, electrical_consumption_kw_a2_w35, cop_ratio_a2_w35, heating_capacity_kw_partial_load, electrical_consumption_kw_partial_load, cop_ratio_partial_load, cooling_capacity_kw, electrical_consumption_kw_cooling, eer_ratio, annual_heating_efficiency_percent, compressor_voltage_nominal_volts, compressor_frequency_hz, sound_level_erp_db_a, max_sound_level_day_night_db_a, dimensions_unpacked_width_mm, dimensions_unpacked_depth_mm, dimensions_unpacked_height_mm, weight_kg, refrigerant_type, gwp_eu_regulation_value, refrigerant_quantity_kg_co2_equivalent, co2_equivalent_per_ton, energy_efficiency_class35_c55_c) SELECT id, display_name, manufacturer, series_name, model_number, c_a7, e_a7, cop_a7, c_a2, e_a2, cop_a2, heating_capacity_kw_partial_load, electrical_consumption_kw_partial_load, cop_ratio_partial_load, cooling_capacity_kw, electrical_consumption_kw_cooling, eer_ratio, annual_heating_efficiency_percent, compressor_voltage_nominal_volts, compressor_frequency_hz, sound_level_erp_db_a, max_sound_level_day_night_db_a, dimensions_unpacked_width_mm, dimensions_unpacked_depth_mm, dimensions_unpacked_height_mm, w_kg, refrigerant_type, gwp_eu_regulation_value, refrigerant_quantity_kg_co2_equivalent, co2_equivalent_per_ton, e_class FROM heat_pumps_migrate');
                await customStatement('DROP TABLE heat_pumps_migrate');
              }
            } on Exception catch (_) {
              // Table does not exist yet (fresh DB) � just create it.
            }
            await customStatement('DROP TABLE IF EXISTS heat_pumps');
            await customStatement(
                'CREATE TABLE heat_pumps (id INTEGER PRIMARY KEY AUTOINCREMENT, display_name TEXT NOT NULL, manufacturer TEXT NOT NULL, series_name TEXT NOT NULL, model_number TEXT NOT NULL, heating_capacity_kw_a7_w35 REAL NOT NULL, electrical_consumption_kw_a7_w35 REAL NOT NULL, cop_ratio_a7_w35 REAL NOT NULL, heating_capacity_kw_a2_w35 REAL NOT NULL, electrical_consumption_kw_a2_w35 REAL NOT NULL, cop_ratio_a2_w35 REAL NOT NULL, heating_capacity_kw_partial_load REAL NOT NULL, electrical_consumption_kw_partial_load REAL NOT NULL, cop_ratio_partial_load REAL NOT NULL, cooling_capacity_kw REAL, electrical_consumption_kw_cooling REAL, eer_ratio REAL, annual_heating_efficiency_percent TEXT NOT NULL, compressor_voltage_nominal_volts INTEGER NOT NULL, compressor_frequency_hz INTEGER NOT NULL, sound_level_erp_db_a REAL NOT NULL, max_sound_level_day_night_db_a TEXT NOT NULL, dimensions_unpacked_width_mm INTEGER NOT NULL, dimensions_unpacked_depth_mm INTEGER NOT NULL, dimensions_unpacked_height_mm INTEGER NOT NULL, weight_kg REAL NOT NULL, refrigerant_type TEXT NOT NULL, gwp_eu_regulation_value REAL NOT NULL, refrigerant_quantity_kg_co2_equivalent REAL NOT NULL, co2_equivalent_per_ton REAL NOT NULL, energy_efficiency_class35_c55_c TEXT NOT NULL)');
            await customStatement('DROP TABLE IF EXISTS heat_loops');
            await customStatement(
                'CREATE TABLE heat_loops (id INTEGER PRIMARY KEY AUTOINCREMENT, project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE, name TEXT NOT NULL, loop_type TEXT NOT NULL DEFAULT ' + "'radiator'" + ', nominal_kw REAL NOT NULL DEFAULT 0, flow_temp_c INTEGER NOT NULL DEFAULT 55)');
            // Add active_heat_pump_id to projects table (used by heat pump
            // selection).  Existing databases created at v12 lack this column.
            await _addColumnIfMissing(
                'projects', 'active_heat_pump_id', 'INTEGER');
          }
          if (from < 14) {
            // v13 -> v14: Heat pump components inventory.
            // Creates 27 inventory tables (one per component type) +
            // shared `inventory_items` table + `component_status` table.
            await customStatement('''
              CREATE TABLE IF NOT EXISTS inventory_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                manufacturer TEXT NOT NULL DEFAULT '',
                series_name TEXT NOT NULL DEFAULT '',
                model_number TEXT NOT NULL DEFAULT '',
                component_type TEXT NOT NULL
              )
            ''');

            await customStatement('''
              CREATE TABLE IF NOT EXISTS component_status_table (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
                inventory_item_id INTEGER REFERENCES inventory_items(id),
                status TEXT NOT NULL DEFAULT 'Offen',
                required INTEGER NOT NULL DEFAULT 0,
                quantity INTEGER NOT NULL DEFAULT 0
              )
            ''');

            await _createInventoryTables();
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

  Stream<List<HeatPump>> watchHeatPumps() => (select(heatPumps)
        ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
      .watch();

  Future<List<HeatLoop>> heatLoopsOf(int projectId) =>
      (select(heatLoops)..where((t) => t.projectId.equals(projectId))).get();

  Stream<List<HeatLoop>> watchHeatLoopsOf(int projectId) =>
      (select(heatLoops)
        ..where((t) => t.projectId.equals(projectId))
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

  /// Creates all 27 heat pump component inventory tables.
  Future<void> _createInventoryTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS boiler (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        volume_litres INTEGER NOT NULL DEFAULT 200)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS hw_verteiler (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        zones INTEGER NOT NULL DEFAULT 1)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS zirkulationspumpe (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        flow_rate_l_min REAL NOT NULL DEFAULT 0,
        head_pressure_m REAL NOT NULL DEFAULT 0,
        eei_rating REAL NOT NULL DEFAULT 0.2)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS rueckflussverhinderer (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        dn_size INTEGER NOT NULL DEFAULT 25)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS schmutzfanger (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        filter_size_mm REAL NOT NULL DEFAULT 2)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS durchflusswaechter (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        min_flow_m3h REAL NOT NULL DEFAULT 0.5)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS pufferspeicher (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        volume_litres INTEGER NOT NULL DEFAULT 500)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS plattenwaermetauscher (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        plates INTEGER NOT NULL DEFAULT 30, area_m2 REAL NOT NULL DEFAULT 2.0)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS safety_valve (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        opening_pressure_bar REAL NOT NULL DEFAULT 3)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS membranausdehnungsgefaess (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        volume_litres INTEGER NOT NULL DEFAULT 10)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS entluftungsventil (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        dn_size INTEGER NOT NULL DEFAULT 25)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS heizkreispumpe (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        flow_rate_l_min REAL NOT NULL DEFAULT 0,
        head_pressure_m REAL NOT NULL DEFAULT 0,
        eei_rating REAL NOT NULL DEFAULT 0.2)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS absperrventil (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        dn_size INTEGER NOT NULL DEFAULT 25)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS fbh_verteiler (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        zones INTEGER NOT NULL DEFAULT 1)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS fbh_schleife (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        pipe_length_m REAL NOT NULL DEFAULT 0,
        pipe_diameter_mm INTEGER NOT NULL DEFAULT 16)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS mischbatterie (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        dn_size INTEGER NOT NULL DEFAULT 25)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS rfv_gartenanschluss (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        dn_size INTEGER NOT NULL DEFAULT 25)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS fuellwasser_zuleitung (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        pipe_diameter_mm INTEGER NOT NULL DEFAULT 20)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS kaltwasser_verbraucher (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        count INTEGER NOT NULL DEFAULT 1)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS ls_schalter (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        current_rating_a INTEGER NOT NULL DEFAULT 16,
        pole_count INTEGER NOT NULL DEFAULT 3,
        char_type TEXT NOT NULL DEFAULT 'B')
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS fi_schutzschalter (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        current_rating_a INTEGER NOT NULL DEFAULT 40,
        sensitivity_ma INTEGER NOT NULL DEFAULT 30,
        type TEXT NOT NULL DEFAULT 'A')
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS zuleitung_starkstrom (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        cross_section_mm2 INTEGER NOT NULL DEFAULT 6,
        length_m REAL NOT NULL DEFAULT 0,
        conductor_material TEXT NOT NULL DEFAULT 'Cu')
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS trennschalter (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        current_rating_a INTEGER NOT NULL DEFAULT 16,
        pole_count INTEGER NOT NULL DEFAULT 3)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS klemmenleiste (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        bus_width INTEGER NOT NULL DEFAULT 12)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS pe_anschluss (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        wire_cross_section_mm2 INTEGER NOT NULL DEFAULT 4)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS hpa_anschluss (id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, manufacturer TEXT NOT NULL DEFAULT '',
        series_name TEXT NOT NULL DEFAULT '', model_number TEXT NOT NULL DEFAULT '',
        conductor_cross_section_mm2 INTEGER NOT NULL DEFAULT 4)
    ''');
  }

  Future<void> touchProject(int projectId) async {
    await (update(projects)..where((t) => t.id.equals(projectId))).write(
      ProjectsCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Seed inventory tables when the database is completely empty.
  Future<void> seedIfEmpty() => seed.seedIfEmpty(this);
}
