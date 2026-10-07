# Testing Concept & Logging Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish structured testing (unit, widget, integration), logging infrastructure, migration/integrity tests, and CI/CD for SolarPlanner.

**Architecture:** Layered approach — unit tests first (fast feedback), then logging, migration/integrity, widget tests, integration tests, and finally CI/CD. Each layer is independently verifiable.

**Tech Stack:** `logger` package, Flutter's built-in `flutter_test` + `integration_test`, `mockito` for widget test mocks, GitHub Actions.

**Spec:** `docs/superpowers/specs/2025-01-16-testing-concept.md`

## Global Constraints

- Every new feature must have test coverage before merge (documented in AGENTS.md)
- Null-safety: every nullable parameter must be tested with `null` input
- All tests must run on Windows (CI runs on ubuntu-latest, local dev on Windows)
- No platform channels in unit tests — pure logic only
- Widget tests must not require a real device (no platform channels)

## Review Focus

1. **Null inputs to electrical calculations** — `inverterOutputCurrentA(powerKw: 0, acPhases: 3, iOutA: null)` should return `0.0`, not crash
2. **Degenerate polygons in geo helpers** — empty list, single point, collinear points should return sensible defaults
3. **Migration from old schema versions** — file-based DB with v1 data must upgrade to current without errors
4. **Widget test interaction timing** — `pump()` calls must match animation durations; unfocus before tapping actions outside scrollable areas
5. **Logger file output on Windows** — `path_provider` must resolve to a writable directory; logger must not crash if file write fails

---

### Task 1: Add Test Dependencies to pubspec.yaml

**Files:**
- Modify: `app/pubspec.yaml` (dev_dependencies section)

**Interfaces:**
- Consumes: existing `flutter_test`, `drift`
- Produces: new dev dependencies available for import

**Steps:**

- [ ] **Step 1: Add logger, mockito, and integration_test to pubspec.yaml**

Add these to `dev_dependencies` in `app/pubspec.yaml`:
```yaml
  logger: ^2.5.0
  mockito: ^5.4.4
  build_runner: ^2.4.0  # (already present, keep)
  integration_test:
    sdk: flutter
```

- [ ] **Step 2: Run `flutter pub get` to verify dependencies resolve**

Run: `cd app && flutter pub get`
Expected: No errors, all packages resolve.

- [ ] **Step 3: Commit**

```bash
cd app && git add pubspec.yaml && flutter pub get
git commit -m "chore: add logger, mockito, integration_test dependencies"
```

---

### Task 2: Implement Logging Infrastructure

**Files:**
- Create: `app/lib/core/logger.dart`
- Modify: `app/lib/features/editor/editor_controller.dart` (add debug logging calls)

**Interfaces:**
- Consumes: `logger` package
- Produces: `AppLogger` singleton with methods: `debug()`, `info()`, `warn()`, `error()`, `fatal()`; static setter `AppLogger.enableFileOutput(bool)`

**Steps:**

- [ ] **Step 1: Write the failing test**

Create `app/test/logger_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/core/logger.dart';

void main() {
  test('AppLogger singleton returns same instance', () {
    final a = AppLogger.instance;
    final b = AppLogger.instance;
    expect(identical(a, b), isTrue);
  });

  test('AppLogger methods do not throw', () {
    final logger = AppLogger.instance;
    expect(() => logger.debug('test'), returnsNormally);
    expect(() => logger.info('test'), returnsNormally);
    expect(() => logger.warn('test'), returnsNormally);
    expect(() => logger.error('test'), returnsNormally);
  });

  test('enableFileOutput setter does not throw', () {
    expect(() => AppLogger.enableFileOutput(true), returnsNormally);
    expect(() => AppLogger.enableFileOutput(false), returnsNormally);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/logger_test.dart`
Expected: FAIL with "class 'AppLogger' doesn't have a top-level method 'instance'"

- [ ] **Step 3: Implement `AppLogger` in `app/lib/core/logger.dart`**

Create the file with this structure:
```dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late Logger _logger;

  factory AppLogger() => _instance;

  AppLogger._internal();

  static AppLogger get instance => _instance;

  static bool _fileOutputEnabled = false;

  /// Enable/disable file-based log output.
  static void enableFileOutput(bool enabled) {
    _fileOutputEnabled = enabled;
    // Re-initialize logger with or without PrettyPrinter + FlutterLogFilter
  }

  void debug(Object? message, {DateTime? time}) => _logger.d(message, time: time);
  void info(Object? message, {DateTime? time}) => _logger.i(message, time: time);
  void warn(Object? message, {DateTime? time}) => _logger.w(message, time: time);
  void error(Object? message, {DateTime? time, StackTrace? stackTrace}) => _logger.e(message, time: time, stackTrace: stackTrace);
  void fatal(Object? message, {DateTime? time, StackTrace? stackTrace}) => _logger.f(message, time: time, stackTrace: stackTrace);
}
```

Use `logger` package with `PrettyPrinter` for console output. When file output is enabled, add a `LogOutput` that writes to the app documents directory (use `path_provider` to resolve path). Handle file write failures gracefully.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/logger_test.dart`
Expected: PASS (all 3 tests)

- [ ] **Step 5: Add null-safety test**

Add to `logger_test.dart`:
```dart
test('Logger methods handle null messages', () {
  final logger = AppLogger.instance;
  expect(() => logger.debug(null), returnsNormally);
  expect(() => logger.info(null), returnsNormally);
  expect(() => logger.error(null), returnsNormally);
});
```

Run: `cd app && flutter test test/logger_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
cd app && git add lib/core/logger.dart test/logger_test.dart
git commit -m "feat: add AppLogger singleton with file output support"
```

---

### Task 3: Unit Tests for Geo Helpers (lib/core/geo.dart)

**Files:**
- Modify: `app/test/geo_test.dart` (rename from existing or create new)

**Interfaces:**
- Consumes: `Pt`, `pointInPolygon`, `polygonArea`, `polygonCentroid`, `BBox` from `lib/core/geo.dart`
- Produces: comprehensive test coverage including null/degenerate cases

**Steps:**

- [ ] **Step 1: Write tests for edge cases not covered by existing widget_test.dart**

The existing `widget_test.dart` already covers basic Pt, pointInPolygon, polygonArea, polygonCentroid, BBox. Add these missing cases:

```dart
// In app/test/geo_test.dart (new file, keep widget_test.dart for reference)

group('Pt edge cases', () {
  test('translate with negative values works', () { ... });
  test('distanceTo is symmetric', () { ... });
  test('encode/decode handles zero coordinates', () { ... });
});

group('pointInPolygon edge cases', () {
  test('returns false for empty polygon', () { ... });
  test('returns false for single point polygon', () { ... });
  test('handles collinear points', () { ... });
});

group('polygonArea edge cases', () {
  test('returns zero for empty list', () { ... });
  test('handles self-intersecting polygon gracefully', () { ... });
});

group('polygonCentroid edge cases', () {
  test('handles single point', () { ... });
  test('handles two points (line)', () { ... });
});

group('BBox edge cases', () {
  test('of() with empty list returns zero-size box at origin', () { ... });
  test('contains() handles edge points correctly', () { ... });
});
```

- [ ] **Step 2: Run test to verify all pass**

Run: `cd app && flutter test test/geo_test.dart`
Expected: PASS (all new tests)

- [ ] **Step 3: Commit**

```bash
cd app && git add test/geo_test.dart
git commit -m "test: add edge-case and null-safety tests for geo helpers"
```

---

### Task 4: Unit Tests for Electrical Calculations (lib/db/electrical.dart)

**Files:**
- Create: `app/test/electrical_test.dart`

**Interfaces:**
- Consumes: `inverterOutputCurrentA`, `recommendedMcbA`, `mcbRatingForInverter` from `lib/db/electrical.dart`
- Produces: tests for all edge cases including null, zero, and boundary values

**Steps:**

- [ ] **Step 1: Write tests for inverterOutputCurrentA**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/electrical.dart';

void main() {
  group('inverterOutputCurrentA', () {
    test('uses iOutA when provided (3-phase)', () {
      expect(inverterOutputCurrentA(powerKw: 5.0, acPhases: 3, iOutA: 7.6), closeTo(7.6, 1e-9));
    });

    test('derives from P/(U*cosφ) when iOutA is null (3-phase)', () {
      // 5000W / 400V = 12.5A
      expect(inverterOutputCurrentA(powerKw: 5.0, acPhases: 3), closeTo(12.5, 1e-9));
    });

    test('derives from P/(U*cosφ) when iOutA is null (1-phase)', () {
      // 5000W / 230V = 21.74A
      expect(inverterOutputCurrentA(powerKw: 5.0, acPhases: 1), closeTo(21.739, 1e-3));
    });

    test('handles zero power', () {
      expect(inverterOutputCurrentA(powerKw: 0, acPhases: 3), closeTo(0.0, 1e-9));
    });

    test('handles null iOutA with zero power', () {
      expect(inverterOutputCurrentA(powerKw: 0, acPhases: 3, iOutA: null), closeTo(0.0, 1e-9));
    });
  });

  group('recommendedMcbA', () {
    test('returns exact match when current equals standard rating', () {
      expect(recommendedMcbA(10.0), 10.0);
      expect(recommendedMcbA(63.0), 63.0);
    });

    test('returns next higher standard rating', () {
      expect(recommendedMcbA(10.1), 16.0);
      expect(recommendedMcbA(25.5), 32.0);
    });

    test('caps at 63A for very high currents', () {
      expect(recommendedMcbA(100.0), 63.0);
    });

    test('handles zero current', () {
      expect(recommendedMcbA(0.0), 10.0); // lowest standard rating
    });

    test('handles negative current (edge case)', () {
      expect(recommendedMcbA(-1.0), 10.0); // lowest standard rating
    });
  });

  group('mcbRatingForInverter', () {
    test('returns int rating covering inverter output current', () {
      final result = mcbRatingForInverter(powerKw: 5.0, acPhases: 3);
      expect(result, isA<int>());
      expect(result, greaterThanOrEqualTo(10));
    });

    test('handles null iOutA', () {
      final result = mcbRatingForInverter(powerKw: 5.0, acPhases: 3, iOutA: null);
      expect(result, isA<int>());
    });

    test('handles single-phase inverter', () {
      final result = mcbRatingForInverter(powerKw: 3.7, acPhases: 1);
      expect(result, isA<int>());
    });
  });
}
```

- [ ] **Step 2: Run test to verify all pass**

Run: `cd app && flutter test test/electrical_test.dart`
Expected: PASS (all tests)

- [ ] **Step 3: Commit**

```bash
cd app && git add test/electrical_test.dart
git commit -m "test: add unit tests for electrical calculations with null-safety"
```

---

### Task 5: Unit Tests for Efficiency Table (lib/core/efficiency_table.dart)

**Files:**
- Create: `app/test/efficiency_table_test.dart`

**Interfaces:**
- Consumes: `EfficiencyTable.efficiencyPercent()` from `lib/core/efficiency_table.dart`
- Produces: tests for all edge cases including out-of-range values

**Steps:**

- [ ] **Step 1: Write tests for efficiency table edge cases**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/core/efficiency_table.dart';

void main() {
  group('EfficiencyTable.efficiencyPercent', () {
    test('south-facing, optimal pitch (30°) returns 100%', () {
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: 30), closeTo(100.0, 1e-9));
    });

    test('south-facing, 0° pitch returns 87%', () {
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: 0), closeTo(87.0, 1e-9));
    });

    test('north-facing, 30° pitch returns lowest value', () {
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 0, pitchDeg: 30), closeTo(61.0, 1e-9));
    });

    test('east-facing (90°) returns lower than south', () {
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 90, pitchDeg: 30), closeTo(81.0, 1e-9));
    });

    test('west-facing (270°) returns same as east', () {
      final east = EfficiencyTable.efficiencyPercent(azimuthDeg: 90, pitchDeg: 30);
      final west = EfficiencyTable.efficiencyPercent(azimuthDeg: 270, pitchDeg: 30);
      expect(west, closeTo(east, 1e-9));
    });

    test('clamps azimuth to valid range', () {
      // 370° should wrap to 10° (same as 10°)
      final wrapped = EfficiencyTable.efficiencyPercent(azimuthDeg: 370, pitchDeg: 30);
      final normal = EfficiencyTable.efficiencyPercent(azimuthDeg: 10, pitchDeg: 30);
      expect(wrapped, closeTo(normal, 1e-9));
    });

    test('clamps pitch to [0, 90]', () {
      final zero = EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: -10);
      final actualZero = EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: 0);
      expect(zero, closeTo(actualZero, 1e-9));

      final ninety = EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: 100);
      final actualNinety = EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: 90);
      expect(ninety, closeTo(actualNinety, 1e-9));
    });

    test('returns values in [0, 100] range', () {
      for (final az in [-360, 0, 90, 180, 270, 360, 720]) {
        for (final pitch in [-50, 0, 30, 60, 90, 150]) {
          final result = EfficiencyTable.efficiencyPercent(azimuthDeg: az, pitchDeg: pitch);
          expect(result, greaterThanOrEqualTo(0));
          expect(result, lessThanOrEqualTo(100));
        }
      }
    });

    test('handles null-equivalent edge cases (0 values)', () {
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 0, pitchDeg: 0), isA<double>());
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: double.infinity, pitchDeg: 30), isA<double>());
    });
  });
}
```

- [ ] **Step 2: Run test to verify all pass**

Run: `cd app && flutter test test/efficiency_table_test.dart`
Expected: PASS (all tests)

- [ ] **Step 3: Commit**

```bash
cd app && git add test/efficiency_table_test.dart
git commit -m "test: add edge-case and null-safety tests for efficiency table"
```

---

### Task 6: Unit Tests for Component Calculator (lib/features/editor/component_calculator.dart)

**Files:**
- Create: `app/test/component_calculator_test.dart`

**Interfaces:**
- Consumes: `ComponentCalculator`, `ComponentCalculation`, `SystemCompleteness` from `lib/features/editor/component_calculator.dart`
- Produces: tests for calculation logic and completeness getters

**Steps:**

- [ ] **Step 1: Write tests for ComponentCalculation and SystemCompleteness**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/features/editor/component_calculator.dart';

void main() {
  group('ComponentCalculation', () {
    test('defaults to empty warnings and formulaResult', () {
      const calc = ComponentCalculation(type: 0, quantity: 1); // use a valid type
      expect(calc.warnings, isEmpty);
      expect(calc.formulaResult, isEmpty);
    });

    test('stores warnings and formulaResult when provided', () {
      const calc = ComponentCalculation(
        type: 0,
        quantity: 2,
        formulaResult: {'key': 'value'},
        warnings: ['warning1'],
      );
      expect(calc.warnings, hasLength(1));
      expect(calc.formulaResult['key'], 'value');
    });
  });

  group('SystemCompleteness', () {
    test('completionPct is 0 when totalComponents is 0', () {
      const sys = SystemCompleteness(systemName: 'test', totalComponents: 0, completedComponents: 0);
      expect(sys.completionPct, closeTo(0.0, 1e-9));
    });

    test('completionPct is 1.0 when all components completed', () {
      const sys = SystemCompleteness(systemName: 'test', totalComponents: 5, completedComponents: 5);
      expect(sys.completionPct, closeTo(1.0, 1e-9));
    });

    test('completionPct is correct for partial completion', () {
      const sys = SystemCompleteness(systemName: 'test', totalComponents: 10, completedComponents: 3);
      expect(sys.completionPct, closeTo(0.3, 1e-9));
    });

    test('handles null warnings', () {
      // SystemCompleteness.warnings is a const List, so it can't be null.
      // But verify the class handles empty list gracefully.
      const sys = SystemCompleteness(systemName: 'test', totalComponents: 0, completedComponents: 0);
      expect(sys.warnings, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify all pass**

Run: `cd app && flutter test test/component_calculator_test.dart`
Expected: PASS (all tests)

- [ ] **Step 3: Commit**

```bash
cd app && git add test/component_calculator_test.dart
git commit -m "test: add unit tests for component calculator classes"
```

---

### Task 7: Integrate Logger into EditorController and Database Layer

**Files:**
- Modify: `app/lib/features/editor/editor_controller.dart` (add logger import and log calls)
- Modify: `app/lib/db/database.dart` (add logger import and log migration events)

**Interfaces:**
- Consumes: `AppLogger` from `lib/core/logger.dart`
- Produces: EditorController logs all mutations; database logs migration events

**Steps:**

- [ ] **Step 1: Add logger to EditorController**

In `app/lib/features/editor/editor_controller.dart`:
- Import: `import '../../core/logger.dart';`
- Add field: `static final _log = AppLogger();`
- Log key mutations: addRoof, deleteRoof, placeModule, assignStringToInverter, etc.
- Log mode changes (EditorMode.select → EditorMode.placeModule)

Example:
```dart
void addRoof(RoofFormResult result) {
  _log.info('Adding roof: ${result.name}');
  // ... existing code ...
  _log.info('Roof added with id: $roofId');
}
```

- [ ] **Step 2: Add logger to database layer**

In `app/lib/db/database.dart`:
- Import: `import '../core/logger.dart';`
- Add field: `static final _log = AppLogger();`
- Log in `onUpgrade`: log each migration version applied
- Log errors in query methods

Example:
```dart
@override
Future<void> onUpgrade(Version start, Version target) async {
  _log.info('Upgrading database from v${start.major}.${start.minor} to v${target.major}.${target.minor}');
  // ... existing migration code ...
}
```

- [ ] **Step 3: Write a test that verifies logger integration**

Create `app/test/logger_integration_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/core/logger.dart';

void main() {
  test('Logger does not throw when called from EditorController context', () async {
    final logger = AppLogger.instance;
    // Simulate what EditorController does
    expect(() => logger.info('Test log message'), returnsNormally);
    expect(() => logger.debug('Debug message'), returnsNormally);
  });

  test('Logger handles long messages without crashing', () {
    final logger = AppLogger.instance;
    final longMessage = 'x' * 10000;
    expect(() => logger.info(longMessage), returnsNormally);
  });
}
```

- [ ] **Step 4: Run test to verify all pass**

Run: `cd app && flutter test test/logger_integration_test.dart`
Expected: PASS (all tests)

- [ ] **Step 5: Commit**

```bash
cd app && git add lib/features/editor/editor_controller.dart lib/db/database.dart test/logger_integration_test.dart
git commit -m "feat: integrate AppLogger into EditorController and database layer"
```

---

### Task 8: Database Migration Tests

**Files:**
- Create: `app/test/migration_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, seed data, existing migration logic in `database.g.dart`
- Produces: tests that verify every schema version migrates correctly

**Steps:**

- [ ] **Step 1: Write migration tests using file-based DBs**

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/db/seed.dart' as seed show seedIfEmpty;

void main() {
  late String dbPath;

  setUp(() async {
    final tempDir = Directory.systemTemp;
    dbPath = p.join(
      tempDir.path,
      'migration_test_${DateTime.now().millisecondsSinceEpoch}.db',
    );
  });

  tearDown(() {
    final file = File(dbPath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  group('Database migration', () {
    test('fresh database opens and seeds correctly', () async {
      final db = AppDatabase(NativeDatabase(File(dbPath)));
      await seed.seedIfEmpty(db);

      // Verify key tables exist and have data
      final projectCount = await db.select(db.projects).get();
      expect(projectCount, hasLength(greaterThanOrEqualTo(1)));

      final moduleTypes = await db.select(db.solarModules).get();
      expect(moduleTypes, hasLength(greaterThanOrEqualTo(1)));

      await db.close();
    });

    test('EditorController loads after fresh seed', () async {
      final db = AppDatabase(NativeDatabase(File(dbPath)));
      await seed.seedIfEmpty(db);

      final projectId = await db.into(db.projects).insert(
        ProjectsCompanion.insert(name: 'MigrationTest', createdAt: 0, updatedAt: 0),
      );

      final controller = EditorController(db: db, projectId: projectId, readOnly: false);
      await controller.load();

      expect(controller.project, isNotNull);
      expect(controller.roofs, isA<List>());
      expect(controller.moduleTypes, isA<List>());

      await db.close();
    });

    test('in-memory database seeds correctly', () async {
      final db = AppDatabase(NativeDatabase.memory());
      await seed.seedIfEmpty(db);

      final heatPumps = await db.select(db.heatPumps).get();
      expect(heatPumps, hasLength(greaterThanOrEqualTo(1)));

      await db.close();
    });
  });
}
```

- [ ] **Step 2: Run test to verify all pass**

Run: `cd app && flutter test test/migration_test.dart`
Expected: PASS (all tests)

- [ ] **Step 3: Commit**

```bash
cd app && git add test/migration_test.dart
git commit -m "test: add database migration tests with file-based DBs"
```

---

### Task 9: Database Integrity Tests

**Files:**
- Create: `app/test/integrity_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, seed data, all table schemas
- Produces: tests that verify schema constraints and data integrity

**Steps:**

- [ ] **Step 1: Write integrity tests**

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/db/seed.dart' as seed show seedIfEmpty;

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seed.seedIfEmpty(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Schema integrity', () {
    test('all expected tables exist after seed', () async {
      // Verify key tables are present and queryable
      expect(await db.select(db.projects).get(), isA<List>());
      expect(await db.select(db.roofs).get(), isA<List>());
      expect(await db.select(db.solarModules).get(), isA<List>());
      expect(await db.select(db.inverters).get(), isA<List>());
      expect(await db.select(db.batteries).get(), isA<List>());
      expect(await db.select(db.wallboxes).get(), isA<List>());
      expect(await db.select(db.heatPumps).get(), isA<List>());
    });

    test('seed data has consistent foreign keys', () async {
      // All placed modules should reference valid roofs
      final roofs = await db.select(db.roofs).get();
      final roofIds = {for (final r in roofs) r.id};

      // If there are placed modules, verify their roofId is valid
      final placed = await db.select(db.placedModules).get();
      for (final pm in placed) {
        expect(roofIds.contains(pm.roofId), isTrue,
            reason: 'Placed module ${pm.id} references invalid roof ${pm.roofId}');
      }
    });

    test('seed data has no null required fields in solar modules', () async {
      final modules = await db.select(db.solarModules).get();
      for (final m in modules) {
        expect(m.name, isNotEmpty);
        expect(m.pMaxW, greaterThan(0));
        expect(m.voc, greaterThanOrEqualTo(0));
      }
    });

    test('seed data has no null required fields in inverters', () async {
      final inverters = await db.select(db.inverters).get();
      for (final inv in inverters) {
        expect(inv.name, isNotEmpty);
        expect(inv.powerKw, greaterThan(0));
      }
    });

    test('heat pump inventory has expected count', () async {
      final heatPumps = await db.select(db.heatPumps).get();
      expect(heatPumps, hasLength(greaterThanOrEqualTo(3))); // known seed count
    });

    test('inventory items reference valid component types', () async {
      final items = await db.select(db.inventoryItems).get();
      for (final item in items) {
        expect(item.componentType, isNotEmpty);
      }
    });
  });
}
```

- [ ] **Step 2: Run test to verify all pass**

Run: `cd app && flutter test test/integrity_test.dart`
Expected: PASS (all tests)

- [ ] **Step 3: Commit**

```bash
cd app && git add test/integrity_test.dart
git commit -m "test: add database integrity tests for schema and seed data"
```

---

### Task 10: Widget Tests — Editor Screen Controls

**Files:**
- Create: `app/test/editor_screen_controls_test.dart`

**Interfaces:**
- Consumes: existing test helpers, `EditorController`, mock database
- Produces: widget tests for editor screen interactive controls

**Steps:**

- [ ] **Step 1: Set up widget test infrastructure**

Create `app/test/helpers_widget.dart` (widget-specific helpers):
```dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/database.dart';

/// Creates a test database with seed data for widget tests.
Future<AppDatabase> createTestDb() async {
  final db = AppDatabase(NativeDatabase.memory());
  // Seed minimal data needed for widget tests
  await db.into(db.projects).insert(ProjectsCompanion.insert(
    name: 'TestProject', createdAt: 0, updatedAt: 0,
  ));
  return db;
}

/// Wraps a widget with necessary providers and material app context.
Widget wrapForTesting(Widget child) {
  return MaterialApp(
    home: Material(child: child),
  );
}
```

- [ ] **Step 2: Write widget tests for editor screen controls**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Tests for:
// - Tab switching in editor screen (PV, Heat Pump, Inventory tabs)
// - Canvas interaction mode buttons (select vs place module)
// - Roof list display in editor sidebar
// - Module type selector dropdown

void main() {
  group('Editor screen controls', () {
    testWidgets('tab switching updates active tab indicator', (tester) async {
      // TODO: Implement once editor_screen.dart structure is known
      // Test that tapping tabs changes the active indicator
    });

    testWidgets('canvas mode buttons toggle correctly', (tester) async {
      // TODO: Test select/place module mode toggle
    });

    testWidgets('null project data shows appropriate placeholder', (tester) async {
      // TODO: Test that editor handles null/empty state gracefully
    });
  });
}
```

Note: This task is a scaffold — the actual widget tests will be filled in during implementation based on the exact structure of `editor_screen.dart`. The pattern follows existing tests like `editor_system_tabs_test.dart` and `editor_screen_add_roof_test.dart`.

- [ ] **Step 3: Run test to verify it compiles**

Run: `cd app && flutter test test/editor_screen_controls_test.dart`
Expected: PASS (empty test group compiles)

- [ ] **Step 4: Commit**

```bash
cd app && git add test/helpers_widget.dart test/editor_screen_controls_test.dart
git commit -m "test: scaffold widget test infrastructure for editor screen controls"
```

---

### Task 11: Widget Tests — Dialog Controls (Roof, Efficiency, Project Properties)

**Files:**
- Create: `app/test/dialog_controls_test.dart`

**Interfaces:**
- Consumes: widget test helpers from Task 10, dialog widgets
- Produces: widget tests for all dialog interactive controls

**Steps:**

- [ ] **Step 1: Write widget tests for roof dialog controls**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Roof dialog controls', () {
    testWidgets('roof form accepts valid inputs', (tester) async {
      // Test: name field, length/width fields, pitch slider, azimuth selector
    });

    testWidgets('roof form rejects empty name', (tester) async {
      // Test: submit with empty name shows validation error
    });

    testWidgets('roof form handles null type (defaults to pitched)', (tester) async {
      // Test: type selector defaults correctly
    });

    testWidgets('roof form validates pitch range (0-90)', (tester) async {
      // Test: slider bounds, out-of-range handling
    });

    testWidgets('roof form validates azimuth range (0-360)', (tester) async {
      // Test: azimuth selector bounds
    });
  });

  group('Efficiency dialog controls', () {
    testWidgets('efficiency dialog shows current values', (tester) async {
      // Test: dialog displays existing efficiency parameters
    });

    testWidgets('efficiency dialog accepts null inputs gracefully', (tester) async {
      // Test: dialog handles missing data
    });
  });

  group('Project properties dialog controls', () {
    testWidgets('project properties form accepts valid inputs', (tester) async {
      // Test: name, location fields
    });

    testWidgets('project properties form handles empty name', (tester) async {
      // Test: validation for required fields
    });

    testWidgets('project properties form handles null location', (tester) async {
      // Test: nullable fields default gracefully
    });
  });
}
```

- [ ] **Step 2: Run test to verify it compiles**

Run: `cd app && flutter test test/dialog_controls_test.dart`
Expected: PASS (empty test group compiles)

- [ ] **Step 3: Commit**

```bash
cd app && git add test/dialog_controls_test.dart
git commit -m "test: scaffold widget tests for dialog controls"
```

---

### Task 12: Widget Tests — Inventory and Setup Screens

**Files:**
- Create: `app/test/inventory_setup_test.dart`

**Interfaces:**
- Consumes: widget test helpers, inventory/setup screen widgets
- Produces: widget tests for inventory list and setup flow controls

**Steps:**

- [ ] **Step 1: Write widget tests for inventory screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Inventory screen controls', () {
    testWidgets('inventory list displays items', (tester) async {
      // Test: list renders inventory items
    });

    testWidgets('inventory screen handles empty state', (tester) async {
      // Test: shows placeholder when no items
    });

    testWidgets('inventory screen handles null data', (tester) async {
      // Test: graceful handling of null/missing data
    });

    testWidgets('inventory item tap shows details', (tester) async {
      // Test: tapping an item opens detail view/dialog
    });
  });

  group('Setup screen controls', () {
    testWidgets('setup screen progresses through steps', (tester) async {
      // Test: next/previous navigation between setup steps
    });

    testWidgets('setup screen validates required fields', (tester) async {
      // Test: validation before proceeding to next step
    });

    testWidgets('setup screen handles back navigation', (tester) async {
      // Test: back button behavior
    });
  });

  group('Projects screen controls', () {
    testWidgets('projects list displays projects', (tester) async {
      // Test: project cards render correctly
    });

    testWidgets('projects screen handles empty state', (tester) async {
      // Test: shows "no projects" placeholder
    });

    testWidgets('project creation flow works', (tester) async {
      // Test: create new project button and form
    });
  });
}
```

- [ ] **Step 2: Run test to verify it compiles**

Run: `cd app && flutter test test/inventory_setup_test.dart`
Expected: PASS (empty test group compiles)

- [ ] **Step 3: Commit**

```bash
cd app && git add test/inventory_setup_test.dart
git commit -m "test: scaffold widget tests for inventory, setup, and projects screens"
```

---

### Task 13: Integration Tests (app/integration_test/)

**Files:**
- Create: `app/integration_test/app_test.dart`
- Create: `app/integration_test_driver.dart` (test runner entry point)

**Interfaces:**
- Consumes: full app, all subsystems
- Produces: end-to-end tests that run on device/emulator

**Steps:**

- [ ] **Step 1: Write integration test for full app startup and basic flow**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full app integration', () {
    testWidgets('app starts and shows projects screen', (tester) async {
      // TODO: Pump the app widget, verify initial screen renders
    });

    testWidgets('create project → add roof → place module flow', (tester) async {
      // TODO: Test the full PV planning workflow
    });

    testWidgets('heat pump inventory flow', (tester) async {
      // TODO: Test heat pump component selection and calculation
    });
  });
}
```

- [ ] **Step 2: Run test to verify it compiles**

Run: `cd app && flutter test integration_test/app_test.dart`
Expected: PASS (empty test group compiles)

- [ ] **Step 3: Commit**

```bash
cd app && git add integration_test/app_test.dart
git commit -m "test: scaffold integration test for full app flows"
```

---

### Task 14: GitHub Actions CI/CD Pipeline

**Files:**
- Create: `.github/workflows/flutter-ci.yml`

**Interfaces:**
- Consumes: Flutter SDK, project structure
- Produces: automated CI that runs on every push/PR

**Steps:**

- [ ] **Step 1: Write GitHub Actions workflow**

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          cache: true

      - name: Install dependencies
        run: cd app && flutter pub get

      - name: Analyze
        run: cd app && flutter analyze

      - name: Run tests
        run: cd app && flutter test
```

- [ ] **Step 2: Verify workflow syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/flutter-ci.yml'))"`
Expected: No errors (valid YAML)

- [ ] **Step 3: Commit**

```bash
cd C:/dev/github/appternity/SolarPlanner && git add .github/workflows/flutter-ci.yml
git commit -m "ci: add GitHub Actions workflow for Flutter CI"
```

---

### Task 15: Update AGENTS.md with Testing Mandate

**Files:**
- Modify: `AGENTS.md` (project root)

**Interfaces:**
- Consumes: existing AGENTS.md structure
- Produces: updated AGENTS.md with testing requirements section

**Steps:**

- [ ] **Step 1: Add testing mandate to AGENTS.md**

Add this section after the "Quick reference" section in `AGENTS.md`:

```markdown
## Testing Mandate

Every new feature MUST include test coverage before merge:

1. **Unit tests** for any pure logic functions (calculations, helpers, validators)
2. **Widget tests** for new UI controls/dialogs/screens
3. **Null-safety edge cases** for all nullable parameters (test with `null` input)
4. **Integration tests** if the feature touches multiple subsystems

### Test categories:
- **Integrity tests**: Schema constraints, seed data consistency
- **Migration tests**: File-based DB upgrades between versions
- **Unit tests**: Pure logic, no Flutter/DI dependencies
- **Widget tests**: Every interactive control (buttons, dialogs, sliders, canvas)
- **Integration tests**: Full app flows on device/emulator

### Logging:
All new features should use `AppLogger` from `lib/core/logger.dart` for debug/info/warn/error logging. Enable file output in production builds for crash diagnostics.
```

- [ ] **Step 2: Commit**

```bash
cd C:/dev/github/appternity/SolarPlanner && git add AGENTS.md
git commit -m "docs: add testing mandate to AGENTS.md"
```

---

## Execution Summary

**Total tasks:** 15
**Estimated effort:** ~8-12 hours (including test writing and verification)

**Dependency chain:**
```
Task 1 (deps) → Task 2 (logger) → Tasks 3-6 (unit tests)
                                    ↓
                              Task 7 (logger integration)
                                    ↓
                    Tasks 8-9 (migration + integrity tests)
                                    ↓
              Tasks 10-12 (widget tests — can parallelize)
                                    ↓
                        Task 13 (integration tests)
                                    ↓
                          Task 14 (CI/CD pipeline)
                                    ↓
                        Task 15 (AGENTS.md update)
```

**Parallelization opportunities:** Tasks 3-6 are independent and can run in parallel. Tasks 10-12 (widget tests) are also independent of each other once Task 10's helpers are in place.

**Recommendation:** Use subagent-driven development for Tasks 3-6 and 10-12 (parallelizable), then sequential for the rest.
