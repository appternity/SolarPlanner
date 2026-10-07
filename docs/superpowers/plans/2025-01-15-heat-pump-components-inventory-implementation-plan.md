# Implementation Plan: Heat Pump Components Inventory

## Task breakdown (inferred from spec)

### Task 1: Database schema — New tables
- Add `inventory_items` table (id, name, manufacturer, seriesName, modelNumber, componentType)
- Add 27 inventory tables with type-specific columns:
  - `Boiler` (volumeLitres)
  - `HwVerteiler` (zones)
  - `Zirkulationspumpe` (flowRateLMin, headPressureM, eeiRating)
  - `Rueckflussverhinderer` (dnSize)
  - `Schmutzfanger` (filterSizeMm)
  - `Durchflusswaechter` (minFlowM3H)
  - `Pufferspeicher` (volumeLitres)
  - `Plattenwaermetauscher` (plates, areaM2)
  - `SafetyValve` (openingPressureBar)
  - `Membranausdehnungsgefaess` (volumeLitres)
  - `Entluftungsventil` (dnSize)
  - `Heizkreispumpe` (flowRateLMin, headPressureM, eeiRating)
  - `Absperrventil` (dnSize)
  - `FbhVerteiler` (zones)
  - `FbhSchleife` (pipeLengthM, pipeDiameterMm)
  - `Mischbatterie` (dnSize)
  - `RfvGartenanschluss` (dnSize)
  - `FuellwasserZuleitung` (pipeDiameterMm)
  - `KaltwasserVerbraucher` (count)
  - `LsSchalter` (currentRatingA, poleCount, charType)
  - `FiSchutzschalter` (currentRatingA, sensitivityMa, type)
  - `ZuleitungStarkstrom` (crossSectionMm2, lengthM, conductorMaterial)
  - `Trennschalter` (currentRatingA, poleCount)
  - `Klemmenleiste` (busWidth)
  - `PeAnschluss` (wireCrossSectionMm2)
  - `HpaAnschluss` (conductorCrossSectionMm2)
- Add `ComponentStatus` table (id, projectId, inventoryItemId, status, required, quantity)
- Bump schemaVersion 13 → 14
- Add migration block (from < 14) creating all tables
- Update seedIfEmpty to call new seed functions

### Task 2: Dart enums + Calculator
- Create `ComponentType` enum (28 values)
- Create `ComponentStatus` enum (5 values)
- Create `ComponentCalculator` class:
  - `calculate(projectId)` → Map<ComponentType, ComponentCalculation>
  - `getSystemCompleteness(projectId)` → Map<SystemType, SystemCompleteness>
  - Formula evaluation from komponenten.md §3
  - Per-system completeness calculation

### Task 3: Seed data
- Create 28 generic placeholder items (one per component type)
- Create `_seedInventoryItems()` function
- Create 28 `_seedGeneric*()` functions (one per inventory table)
- Wire into `seedIfEmpty()`

### Task 4: EditorController integration
- Add lists for all 27 inventory tables + ComponentStatus
- Add `load()` method to fetch all data
- Integrate `ComponentCalculator` into controller
- Add `updateComponentStatus()` method

### Task 5: Projekt tab — Systemstatus section
- Add "Systemstatus" section to `_ProjectTabBody`
- Show per-system completeness (progress bar + fraction + percentage + warning icon)
- Show shared components (Hausanschluss, Schaltschrank, Erdung) with status badges

### Task 6: Wärmepumpe tab — Full implementation
- Replace `_SystemPlaceholder` (case 4) with full `_HeatPumpTabBody` implementation
- Show all 28 WP components grouped by category (Hydraulik + Elektrik)
- Each component card: name, status badge, quantity, inventory dropdown
- Conditional visibility (Pufferspeicher, Zirkulationspumpe)
- Warning icons for required but Offen components

### Task 7: Tests
- Unit tests for `ComponentCalculator` (formula evaluation, edge cases)
- Widget tests for status badges, progress bars, inventory dropdowns
- Integration tests for status lifecycle (Offen → In Planung → Eingebaut)
- Migration tests (schema v14)

## File list

### Read
- `app/lib/db/tables.dart` (448 lines)
- `app/lib/db/database.dart` (450 lines)
- `app/lib/db/seed.dart` (635 lines)
- `app/lib/features/editor/editor_controller.dart` (395 lines)
- `app/lib/features/editor/editor_screen.dart` (1620 lines)

### Write/Edit
- `app/lib/db/tables.dart` — 27 new tables + `ComponentStatus` + `ComponentType` enum
- `app/lib/db/database.dart` — migration (v14), schema reference
- `app/lib/db/seed.dart` — 28 generic seed functions + seedIfEmpty wiring
- `app/lib/features/editor/editor_controller.dart` — load all lists + calculator
- `app/lib/features/editor/editor_screen.dart` — Projekt tab Systemstatus + Heat Pump tab
- `app/lib/features/editor/component_calculator.dart` (new) — formula evaluation
- `app/test/component_calculator_test.dart` (new)
- `app/test/heat_pump_inventory_ui_test.dart` (new)

## Dependencies between tasks
1 → 2 → 3 → 4 → 5, 6 (parallel) → 7
