# Testing Concept & Logging Infrastructure

**Date:** 2025-01-16
**Status:** Approved (Approach A — Layered & Incremental)

## Goal

Establish a structured, reliable testing concept with logging/debugging infrastructure for SolarPlanner. Every new feature must have test coverage before merge.

## Scope

Six layers, built in dependency order:
1. Unit tests (pure logic)
2. Logging & debugging infrastructure
3. Database migration + integrity tests
4. Widget tests (every interactive control)
5. Integration tests (full app flows)
6. CI/CD pipeline

## Tech Stack Decisions

- **Logging:** `logger` package (simple, file output, log levels)
- **Test framework:** Flutter's built-in `flutter_test` + `integration_test`
- **Mocking:** `mockito` for database/controller mocks in widget tests
- **CI:** GitHub Actions (flutter analyze + flutter test on every push)

## Layer 1: Unit Tests

### Target files (pure logic, no Flutter/DI):
- `lib/core/geo.dart` — Pt, pointInPolygon, polygonArea, polygonCentroid, BBox
- `lib/core/efficiency_table.dart` — EfficiencyTable.efficiencyPercent()
- `lib/db/electrical.dart` — inverterOutputCurrentA, recommendedMcbA, mcbRatingForInverter
- `lib/features/editor/component_calculator.dart` — ComponentCalculation, SystemCompleteness getters

### Null-safety strategy:
Every nullable parameter tested with `null` input → verify graceful behavior (defaults, early returns, or meaningful errors).

## Layer 2: Logging & Debugging Infrastructure

### Architecture:
- `lib/core/logger.dart` — Thin wrapper around `logger.Logger` with singleton access
- Log levels: debug, info, warn, error, fatal
- File output to app documents directory (for crash diagnostics)
- Debug overlay toggle via `EditorController.debugLogging = true`
- Structured log context: module name, function, timing

### Integration points:
- `EditorController` — log all mutations (addRoof, placeModule, assignString)
- `AppDatabase` — log migration events and query errors
- VDE validation — log warnings with specific check names

## Layer 3: Database Migration + Integrity Tests

### Migration tests:
- File-based DB (not in-memory) to exercise real `onUpgrade` paths
- Test every version transition: v1→v2→...→current (or at least sample key transitions)
- Verify seed data consistency after migration

### Integrity tests:
- Schema constraints (NOT NULL, UNIQUE) hold for all tables
- Seed data completeness (all expected inventory items present)
- Foreign key relationships valid after load

## Layer 4: Widget Tests

### Screens/controls to cover (based on existing test patterns):
- `editor_screen.dart` — canvas interactions, tab switching
- `roof_dialogs.dart` — roof form creation/editing
- `efficiency_dialog.dart` — efficiency parameter selection
- `project_properties_dialog.dart` — project metadata editing
- `heat_loop_dialogs.dart` — heat loop creation/editing (already partially tested)
- `inventory_screen.dart` — inventory list interactions (already partially tested)
- `setup_screen.dart` — initial setup flow
- `projects_screen.dart` — project list management

### Testing approach:
- Widget tests for each dialog/screen
- Test null/empty inputs to all form fields
- Test canvas gesture interactions (pan, zoom, place)
- Use existing `helpers.dart` patterns for DB setup

## Layer 5: Integration Tests

### Full app flows:
1. Fresh startup → seed data loads correctly
2. Create project → add roof → place modules → assign strings → run VDE checks
3. Heat pump inventory flow: add components → calculate completeness

### Test location: `app/integration_test/`
- Uses `flutter_driver` / `integration_test` framework
- Runs on device/emulator

## Layer 6: CI/CD Pipeline

### GitHub Actions workflow (`.github/workflows/flutter-ci.yml`):
- Trigger: push to any branch, PRs to main
- Steps: `flutter pub get` → `flutter analyze` → `flutter test` (unit + widget)
- Cache flutter dependencies between runs

## Testing Mandate for Future Features

Every new feature must include:
1. Unit tests for any pure logic functions it introduces
2. Widget tests for new UI controls/dialogs
3. Null-safety edge cases for all nullable parameters
4. Integration test if the feature touches multiple subsystems

This mandate should be documented in `AGENTS.md`.
