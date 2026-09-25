# Architecture Overview & Deep Dives

## Roof Model (v2) — Schema, UI, Move Semantics

### Schema (`db/tables.dart`)

Roofs are **typed rectangles** stored as strings in the `type` column. Enums + parse extensions live in `db/extensions.dart`. Type, length and width are **fixed after creation** — changing the type means delete + re-add.

```dart
// Roofs columns:
name, polygon (4 points), lengthM/widthM (m), pitchDeg, azimuthDeg (direction roof faces/slopes down, ° clockwise from north), type;
Flachdach: flatBaseHeightCm/flatAttikaHeightCm/flatAttikaWidthCm;
Steildach: rafter*/batten* (cm), rafterStraight, hasCounterBatten, tilesVisibleWidth/Height, tileOverlapCm, tileMaterial (clay/concrete), hasSpareTiles, hasInsulation, insulationThicknessCm.
All detail fields nullable (cm).
```

- Schema v1→v2 migration in `db/database.dart` adds the columns and drops `base_height_m`. Readers open snapshots read-only, so migrations only run on the writer's working DB (snapshots are `VACUUM INTO` copies).
- UI: "Dach zeichnen" (freehand polygon) mode is **gone**. Roofs are added via `showAddRoofDialog` → rectangle placed to the right of all existing objects. Edit dialog locks type/length/width. Delete asks for confirmation (`confirmDeleteRoof`). Canvas shows name + m² at centroid, length on one long edge and width on one short edge; fixed compass rose bottom-right (N up); zoom via pinch + buttons. In select mode roofs/obstacles can be **moved** (drag) but not rotated.

### Auto-fill panel placement (`autoFillRoof`) — rules & config

`autoFillRoof` lays panels out in a **local frame aligned to the roof's compass heading** (ridge/slope axes derived from `azimuthDeg`), NOT on the world X/Y grid. Each panel gets `rotationDeg` matching the ridge direction so it aligns with the roof. Regression-tested: east-facing roof → panels rotated ≈ ±90°, not the world-grid default of 0.

**Per-roof type defaults (when margin/gap are null):**
- *Steildach:* edge margin ≈ one tile row (~5 cm) so no module overhangs the roof edge; 2 cm between modules (clamp width).
- *Flachdach:* panels on ballasted rails tilted ~10°; two rails per module, rail center-to-center = module length + 2 cm. Ost-West (bifacial) packs tighter than single-direction Süd (which needs a larger anti-shading gap).

**Configurable overrides:** `Roofs.moduleMarginM` / `moduleGapM` are stored in **meters**. The roof dialog exposes them in **centimeters** (`moduleMarginCm`/`moduleGapM→cm`) and the controller converts cm↔m on read/write. Null = use the type default above; `autoFillRoof` applies them when >= 0. Regression-tested: a larger margin fits fewer panels, and the edit path persists them to the DB.

**Every editable roof field is round-trip tested.** The test 'every editable field round-trips through the DB' sets each column to a distinct value and re-reads from `db.roofsOf(...)` (not just in-memory state) to prove persistence. A second test verifies that *clearing* a field persists NULL (not the stale value). If you add a roof column, extend both tests.

**"Not persisted" / "button does nothing" on the running app is usually a stale binary.** The source round-trips every field and `load()` re-reads from the DB after each write. If a user reports edits not saving or "Dach hinzufügen" doing nothing, first confirm they rebuilt/relaunched with the latest code — an old binary's `updateRoof`/`addRoof` companion simply lacks the newer columns. The DB itself migrates fine (verified: both local and OneDrive `solarplanner.db` are at user_version 3 with all columns).

**Edit-roof dialog shows dimensions read-only.** In edit mode length/width are fixed, so they're rendered as disabled `TextFormField`s (via `_readOnlyField`, with a lock icon) under an "Abmessungen (nicht änderbar)" section — the user can see them but not change them. Regression-tested in `roof_dialogs_test.dart` (values shown + fields disabled).

**Control-panel roof dropdown overflow:** `DropdownButtonFormField` overflows at narrow widths. Wrap it in `SizedBox(width: double.infinity)` + `isExpanded: true` and give the item `Text(overflow: TextOverflow.ellipsis)`. This overflow throws a RenderFlex exception that fails full-screen widget tests.

### Move semantics & module drift (critical bug pattern)

- Moving a roof moves its assigned `placedModules` (by `roofId`) along with it.
- Moving a module does NOT affect its roof.
- **Roof-move module drift:** When a roof is dragged, modules must be repositioned from their **fixed start positions** (`_moveStartModulePos`, captured in `beginMove`), NOT by adding the cumulative delta to each module's *current* position. The gesture reports a growing `to - from` delta every update; re-applying it to an already-moved position makes panels drift away quadratically. Regression-tested with multiple incremental updates in `editor_controller_test.dart` (group 'move').

## VDE Planning Checks & Electrical Validation (`EditorController.validateProject()`)

VDE planning checks live in `EditorController.validateProject()` and are shown in `_ViolationsPanel` (editor_screen.dart). The LS-Schalter info line is shown for the **active inverter only** (not every inventory item) and uses the stored `Inverters.mcbA` when present, falling back to the derived rating.

Shared electrical helpers (`inverterOutputCurrentA`, `recommendedMcbA`, `mcbRatingForInverter`) live in `lib/db/electrical.dart` so seed, migration backfill and the controller use one source of truth. `load()` re-resolves a stale/missing active module/inverter selection (deleted inventory item) to the persisted or first available one.

**Cold/hot Voc calculation:** unchanged in shape — `tCellColdC = tAmbientMinC − 10` (now −35 °C by default after schema v7), so strings pack fewer modules than with the old T_min = 5 °C default; test expectations in `vde_validation_test.dart` use the −35 °C numbers.

**String assignment (`autoAssignStrings`):** packs strings against the **cold-Voc** limit `min(1500, maxInputVoltage)` and respects per-MPPT parallel Isc/Imp sums. Remaining backlog: single-phase 11.5 kVA limit (VDE-AR-N 4105), wallbox charge-current check, MPP window validation, DC/AC display.

## Module Naming / Labels (`{roofId}.{stringId}.{moduleId}`) — deep dive

Every placed module that belongs to a string gets an identifier shown on the canvas as white text in a semi-transparent black band along its top edge (in the module's local rotated frame). Modules without a string get no label.

**Label parts (all 1-based, session state only):**
- `roofId` = rank of the module's roof among roofs that carry ≥1 placed module (sorted by `Roofs.id`). Empty roofs do NOT consume a rank.
- `stringId` = `mppIndex + 1` of the module's string — i.e., MPPT tracker number on the inverter (global per project, not per string).
- `moduleId` = position within that tracker: modules of all strings on the same `mppIndex` are numbered continuously (strings ordered by id, then by series `position`).

**Rendering:** band height `min(h*0.9, 13/zoom)`, font size `12/zoom` (~constant ~12px), shrinks to fit module width. Only drawn when the module is ≥ ~14 px on screen (`min(w,h)*zoom >= 14`). Regression-tested in `editor_controller_test.dart` (group 'moduleLabels'): format/uniqueness, gap-free roof ranking with an empty middle roof, continuous numbering across parallel strings on one MPPT, null for unassigned modules.

## Active Module/Inverter Selection — persistence & behavior

`Projects` has nullable `active_module_type_id` + `active_inverter_id` (schema v4). The editor's "Modultyp" / "Wechselrichter" dropdowns call `EditorController.setActiveModuleType` / `setActiveInverter`, which persist the choice to the project row AND re-run `autoAssignStrings()` so string Voc and Anlage totals reflect the new inverter limits / module type.

- `load()` restores these from the project row (falling back to the first inventory item).
- **Do NOT assign** `activeModuleTypeId`/`activeInverterId` directly from the UI — that skips persistence.
- The "Modultyp" is a **system-wide** choice: re-types every placed module to the new product so Anlage kWp + each string's Voc sum update, while keeping which module sits in which string (memberships reference `placed_module_id`s). It does NOT rebuild strings.
- `setActiveInverter` only persists + repaints; use "Alle Strings automatisch zuweisen" to rebuild against the new inverter's limits.

## Yield Efficiency Table (`lib/core/efficiency_table.dart`)

Hard-codes the German PV yield table from Mertens, *Photovoltaik – Lehrbuch*, 5. Aufl., S. 58 (source image: `data/effizienz/pv-module_ausrichtung_vs_neigung.png`, bundled as `assets/effizienz/...` in pubspec).

Rows = deviation from due south (0°=S, 90°=O/W, 180°=N) in 10° steps; columns = pitch (Neigung) 0–90°. Values are constant → deliberately **not** persisted. `EfficiencyTable.efficiencyPercent` wraps azimuth to a south-deviation, rounds both axes to the nearest step, clamps out-of-range. Shown per roof in `_ControlPanel` (`editor_screen.dart`, `_roofEfficiencyRow`): roofs with modules show % + table_chart icon opening `showEfficiencyTableDialog`; roofs without modules show blank value. Regression-tested in `test/efficiency_table_test.dart`.

## Drift API Patterns — Table definitions & companions

### Companion construction rules (Drift 2.35)

- Required fields: pass raw values (`name`, `id`).
- Optional fields: wrap with `Value<T>` (`Value<int>(nullableId)`).
- **Do NOT use** `Constant` — it's an `Expression`, not a `Value`. Companion constructor throws "Cannot convert const Constant to Value".

```dart
// ❌ Wrong
db.table.insert(Companion(name: name, id: Constant(id)))  // Compile error

// ✅ Correct
db.table.insert(Companion(name: name, id: Value<int>(id)))
```

### `customSelect` variables parameter (gotcha)

The named parameter is a **list**, not a positional argument. Omitting the variable list throws "missing required keyword argument 'variables'".

```dart
// ❌ Wrong — missing named param + wrong type
db.customSelect('SELECT * FROM t WHERE id = ?', [Variable(id)])  // Error: expected List<Variable>

// ✅ Correct
db.customSelect(
  'SELECT * FROM t WHERE id = ?',
  variables: [Variable(id)],  // ← named!
)
```

### `into(...)` has no top-level function

Drift provides two equivalent patterns — there is **no** standalone `into` helper.

```dart
// ✅ Both valid
db.table.insert(companion);
db.into(db.table).insert(values: {...});  // ← the table argument, not a method call on db
```

## Canvas Painter Architecture (`roof_canvas.dart`)

The painter uses `CustomPaint(size: Size.infinite)` to draw an unbounded world. It is wrapped in a `ClipRect` (inside the `RepaintBoundary`). Without the clip, roof/module paint leaks onto sibling widgets — e.g., through the transparent control panel. Regression-tested: 'world painter is clipped to the canvas bounds' in `roof_canvas_test.dart`.

### Label z-order fix

Roof labels (name/area at centroid, edge lengths) must be drawn in a **final foreground pass** after obstacles and placed modules, otherwise they get painted over. The painter collects labels into a list during the roof loop and renders them last, before `canvas.restore()`.

## String Assignment (`EditorController`) — re-assignment gotcha

`string_modules` has PK `(string_id, placed_module_id)`. A module belongs to exactly **one** string. `assignSelectedToActiveString` must:
1. No-op if the module is already in the target string.
2. Delete it from any other string first (if present).
3. Insert into the new string.

Blindly inserting throws `UNIQUE constraint failed`. The test 'module can be moved between strings' verifies this three-step flow.

## Test Infrastructure Notes

- **Widget tests for tall dialogs:** A focused `TextFormField` keeps its cursor-blink ticker alive, which blocks `pumpAndSettle`. After `enterText`, call `FocusManager.instance.primaryFocus?.unfocus()` and use fixed-duration pumps (e.g., 10 ms). For the tall edit dialog, `tester.scrollUntilVisible(target, 200, scrollable: find.byType(Scrollable).first)` + `tapAt(getCenter(...))` is reliable — the actions bar isn't inside the scroll view.
- **Controller unit tests** call methods directly (`beginMove`, `updateMove`, etc.) and do NOT catch gesture-wiring bugs like missing `_dragStart` propagation or module drift from cumulative deltas. Widget tests that perform actual gestures on the canvas are required to expose those issues.
