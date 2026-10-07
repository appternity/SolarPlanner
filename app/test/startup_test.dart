import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../lib/db/database.dart';
import '../lib/db/seed.dart';
import '../lib/features/editor/editor_controller.dart';

/// Startup integration test: verifies that a fresh database (schema v14)
/// can be opened, seeded, and loaded by EditorController without errors.
///
/// This catches the same class of bugs that caused the runtime crash:
///   SqliteException: no such table: component_status_table
///
/// The test uses a file-based database so it exercises the exact same code
/// path as the production app (including onUpgrade).
void main() {
  late String dbPath;

  setUp(() async {
    final tempDir = Directory.systemTemp;
    dbPath = p.join(
      tempDir.path,
      'startup_test_${DateTime.now().millisecondsSinceEpoch}.db',
    );
  });

  tearDown(() {
    final file = File(dbPath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  group('Startup — fresh database', () {
    test('EditorController.load() succeeds on a fresh DB', () async {
      final db = AppDatabase(NativeDatabase.memory());
      try {
        await seedIfEmpty(db);

        final projectId = await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            name: 'StartupTest',
            createdAt: 0,
            updatedAt: 0,
          ),
        );

        final controller = EditorController(
          db: db,
          projectId: projectId,
          readOnly: false,
        );
        await controller.load();

        expect(controller.project, isNotNull);
        expect(controller.heatPumps, hasLength(3));
        expect(controller.inventoryItems, isNotEmpty);
        expect(controller.calculator, isNotNull);
      } finally {
        await db.close();
      }
    });

    test('Migration v14 creates all inventory tables from a v13 database',
        () async {
      // Create a minimal v13 file-based database, then let drift's
      // onUpgrade (v13→v14) create the inventory tables.
      // This simulates a user upgrading from a pre-inventory version.
      final sqlite = sqlite3.open(dbPath);
      try {
        sqlite.execute('''
          CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0
          )
        ''');
        sqlite.execute('PRAGMA user_version = 13');
        sqlite.close();

        // Open with drift — it runs onUpgrade (v13→v14).
        final upgradedDb = AppDatabase(NativeDatabase(File(dbPath)));
        try {
          expect(upgradedDb.schemaVersion, 14);

          final tables = await upgradedDb.customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
          ).get();

          final tableNames = tables.map((row) => row.data['name'] as String).toSet();

          expect(tableNames, contains('inventory_items'));
          expect(tableNames, contains('component_status_table'));

          final expectedTables = {
            'boiler', 'hw_verteiler', 'zirkulationspumpe', 'rueckflussverhinderer',
            'schmutzfanger', 'durchflusswaechter', 'pufferspeicher',
            'plattenwaermetauscher', 'safety_valve', 'membranausdehnungsgefaess',
            'entluftungsventil', 'heizkreispumpe', 'absperrventil', 'fbh_verteiler',
            'fbh_schleife', 'mischbatterie', 'rfv_gartenanschluss',
            'fuellwasser_zuleitung', 'kaltwasser_verbraucher', 'ls_schalter',
            'fi_schutzschalter', 'zuleitung_starkstrom', 'trennschalter',
            'klemmenleiste', 'pe_anschluss', 'hpa_anschluss',
          };
          expect(tableNames, containsAll(expectedTables));
        } finally {
          await upgradedDb.close();
        }
      } finally {
        sqlite.close();
      }
    });

    test('All 27 inventory tables are created by seedIfEmpty on fresh DB',
        () async {
      final db = AppDatabase(NativeDatabase.memory());
      try {
        await seedIfEmpty(db);
        expect(db.schemaVersion, 14);

        final tables = await db.customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
        ).get();

        final tableNames = tables.map((row) => row.data['name'] as String).toSet();

        expect(tableNames, contains('inventory_items'));
        expect(tableNames, contains('component_status_table'));

        final expectedTables = {
          'boiler', 'hw_verteiler', 'zirkulationspumpe', 'rueckflussverhinderer',
          'schmutzfanger', 'durchflusswaechter', 'pufferspeicher',
          'plattenwaermetauscher', 'safety_valve', 'membranausdehnungsgefaess',
          'entluftungsventil', 'heizkreispumpe', 'absperrventil', 'fbh_verteiler',
          'fbh_schleife', 'mischbatterie', 'rfv_gartenanschluss',
          'fuellwasser_zuleitung', 'kaltwasser_verbraucher', 'ls_schalter',
          'fi_schutzschalter', 'zuleitung_starkstrom', 'trennschalter',
          'klemmenleiste', 'pe_anschluss', 'hpa_anschluss', 'heat_pumps',
          'heat_loops',
        };
        expect(tableNames, containsAll(expectedTables));
      } finally {
        await db.close();
      }
    });
  });
}
