# AGENTS.md — SolarPlanner

Working notes for the coding agent. Read this first, keep it updated as work
progresses (add/mark/remove tasks). This file is the source of truth for task
state across sessions.

## Role & code style (IMPORTANT)

You are an **expert Flutter developer**. Write clean, idiomatic Dart following
Flutter best practices.

- Understand state management (Provider, Riverpod, Bloc, GetX), widget
  lifecycles, performance optimization, and modern Flutter patterns (Riverpod
  v2+, GoRouter, isolated packages).
- Always include type hints, proper error handling, null safety, and comments
  where necessary.
- When providing complete files or large code blocks, use markdown code blocks
  with language identifiers.
- For complex problems, break the solution into steps **before** writing code.

## Project layout

- Repo root: `C:/dev/github/appternity/SolarPlanner`
- Flutter app lives in **`app/`** (run all `flutter` commands from there).
- Python auxiliary files live at the repo root (`src/solarplanner/`, `data/`).
  - Open question: `src/solarplanner/__init__.py` looks like a leftover
    hello-world; root scripts + `data/` may need cleanup or docs.

## Toolchain & locked deps (verified)

- Flutter `3.47.4`, Dart `3.13.3`.
- Locked in `app/pubspec.lock`:
  - drift / drift_dev: **2.35.0**
  - sqlite3: **3.5.2**, sqlite3_flutter_libs: `0.6.0+eol`
  - file_picker: **13.1.0**, android_file_picker: **2.0.0**
  - path_provider: `2.1.6`

## Roof model (v2, implemented)

- Roofs are **typed rectangles** (`RoofType.flat` / `RoofType.pitched`, stored
  as strings in the `type` column; enums + parse extensions live in
  `db/tables.dart`). Type, length and width are **fixed after creation** —
  changing the type means delete + re-add.
- `Roofs` columns: name, polygon (4 points), lengthM/widthM (m), pitchDeg,
  azimuthDeg (direction the roof faces/slopes down, ° clockwise from north),
  type; Flachdach: flatBaseHeightCm/flatAttikaHeightCm/flatAttikaWidthCm;
  Steildach: rafter*/batten* (cm), rafterStraight, hasCounterBatten,
  tilesVisibleWidth/Height, tileOverlapCm, tileMaterial (clay/concrete),
  hasSpareTiles, hasInsulation, insulationThicknessCm. All detail fields
  nullable (cm).
- Schema v1→v2 migration in `db/database.dart` adds the columns and drops
  `base_height_m`. Readers open snapshots read-only, so migrations only run on
  the writer's working DB (snapshots are `VACUUM INTO` copies).
- UI: "Dach zeichnen" (freehand polygon) mode is **gone**. Roofs are added via
  `showAddRoofDialog` (features/editor/roof_dialogs.dart) → rectangle placed to
  the right of all existing objects. Edit dialog locks type/length/width.
  Delete asks for confirmation (`confirmDeleteRoof`). Canvas shows name + m² at
  the centroid, length on one long edge and width on one short edge; fixed
  compass rose bottom-right (N up); zoom via pinch + buttons.
- In select mode roofs/obstacles can be **moved** (drag) but not rotated.

## Key API facts (Drift 2.35 / sqlite3 3.5 — verified against pub cache)

- `IntColumn` is a typedef for `Column<int>` (NOT `GeneratedColumn`).
  - So table `primaryKey` overrides must be typed `Set<Column>`, not
    `Set<GeneratedColumn>`: `Set<Column> get primaryKey => {id};`
- Companions take **raw values** for required fields and `Value<T>` for
  optional ones. `Constant` is an `Expression`, NOT a `Value`.
- Insert API: both `db.table.insert(companion)` and
  `db.into(db.table).insert(...)` are valid. There is **no top-level**
  `into(...)`.
- `NativeDatabase` has no `openFile`/`createFile`:
  - read-write: `NativeDatabase(File(path))`
  - read-only: `NativeDatabase.opened(sqlite3.open(path, mode: OpenMode.readOnly))`
  - `OpenMode` comes from `package:sqlite3/sqlite3.dart`.
- Generated subclass constructor is `_$AppDatabase(QueryExecutor e) : super(e);`
  → hand-written subclass must use `super.e`.
- Drift_dev pluralization quirk: table `Wallboxes` → data class `Wallboxe`.
  Fixed with `@DataClassName('Wallbox')` on the table (import from drift).
- **Drift migrations must be idempotent**: drift only bumps `user_version`
  after `onUpgrade` completes, so a crash mid-migration leaves the DB
  half-migrated and re-runs `onUpgrade` from the old version. Use raw
  `ALTER TABLE ... ADD COLUMN` guarded by a `PRAGMA table_info()` check (see
  `_addColumnIfMissing` in database.dart). Note: `m.addColumn` is NOT a no-op
  for existing columns (it throws "duplicate column name").
- `customSelect(...)` takes variables as a **named** parameter:
  `variables: [Variable(x)]` — no positional list.
- Reading raw rows (`QueryRow`) from `customSelect`: use
  `row.data['col']`, NOT `row.read('col')` (the latter throws
  "Could not find a matching SQL type for dynamic" because the column has no
  drift type mapping).
- `GestureDetector`: pan + scale handlers are mutually exclusive ("scale is a
  superset of pan"). Use only `onScaleStart/Update/End`: single pointer = pan,
  two pointers = pinch. `ScaleUpdateDetails` has no `delta`, no
  `previousScale`; `d.scale` is relative to gesture start. Use the focal point
  for both panning (`focalPoint - focalStart`) and zoom anchoring.
- `file_picker 13.1.0` removed SAF symbols (`FilePickerAndroidOptions`,
  `AndroidSAFOptions`, `AndroidSAFGrant`, `AndroidSAFAccessMode`). They live in
  the **`android_file_picker`** package (the Android impl of file_picker).
- `Matrix4.identity()` is a **non-const factory** in this Flutter — do NOT
  write `const Matrix4.identity().storage` (compile error GD5B17B6A). Use
  `canvas.transform(Matrix4.identity().storage)` (no const) to reset the CTM.
- `TextPainter`: no `toParagraph()` method and (in this Flutter) the getter is
  **not** named `paragraph` — see open error below. Use whatever compiles;
  verify against `/c/dev/flutter/.../text_painter.dart`.

## Roof dialog `_submit` (roof_dialogs.dart) — edit-mode gotcha

- In **edit mode** `lengthM`/`widthM` are intentionally null (geometry is fixed
  once created). The submit guard must only require them in **add mode**:
  `if (_isAdd && (lengthM == null || widthM == null)) return;` — a guard that
  checks `lengthM == null || widthM == null` unconditionally makes "Speichern"
  silently no-op in edit mode (dialog never pops). Regression-tested by
  `test/roof_dialogs_test.dart`.
- Widget-test note: a focused `TextFormField` keeps its cursor-blink ticker
  alive, which can block `pumpAndSettle`. After `enterText`, call
  `FocusManager.instance.primaryFocus?.unfocus()` and use fixed-duration pumps.
  For the tall edit dialog, `tester.scrollUntilVisible(target, 200,
  scrollable: find.byType(Scrollable).first)` + `tapAt(getCenter(...))` is
  reliable (the actions bar isn't inside the scroll view).

## Auto-fill panel alignment (editor_controller.dart)

- `autoFillRoof` lays panels out in a **local frame aligned to the roof's
  compass heading** (ridge/slope axes derived from `azimuthDeg`), NOT on the
  world X/Y grid. Each panel gets `rotationDeg` matching the ridge direction so
  it aligns with the roof. Regression-tested in `editor_controller_test.dart`
  (east-facing roof → panels rotated ≈ ±90°, not the world-grid default of 0).
- **Auto-Fill placement rules** (from `data/transkripte/*.txt`):
  - *Steildach:* edge margin ≈ one tile row (~5 cm) so no module overhangs the
    roof edge; 2 cm between modules (clamp width).
  - *Flachdach:* panels on ballasted rails tilted ~10°; two rails per module,
    rail center-to-center = module length + 2 cm. Ost-West (bifacial) packs
    tighter than single-direction Süd (which needs a larger anti-shading gap).
  - `autoFillRoof` picks margin/gap by `roof.type`. Regression-tested: every
    panel corner must stay inside the roof polygon (no overhang).
  - **Configurable per-roof overrides:** `Roofs.moduleMarginM` / `moduleGapM`
    (nullable, meters) are the *stored* units. The roof dialog exposes them in
    **centimeters** (`moduleMarginCm`/`moduleGapM→cm`) and the controller converts
    cm↔m on read/write. Null = use the type default above; `autoFillRoof` applies
    them when >= 0. Regression-tested: a larger margin fits fewer panels, and the
    edit path persists them to the DB.
- **Every editable roof field is round-trip tested.** `updateRoof` writes a full
  `RoofsCompanion`; the test 'every editable field round-trips through the DB'
  sets each column to a distinct value and re-reads from `db.roofsOf(...)` (not
  just in-memory state) to prove persistence. A second test verifies that
  *clearing* a field persists NULL (not the stale value). If you add a roof
  column, extend both tests.
- **"Not persisted" / "button does nothing" on the running app is usually a stale binary.** The source round-trips every field (proven by tests) and `load()` re-reads from the DB after each write. If a user reports edits not saving or "Dach hinzufügen" doing nothing, first confirm they rebuilt/relaunched with the latest code — an old binary's `updateRoof`/`addRoof` companion simply lacks the newer columns. The DB itself migrates fine (verified: both the local and OneDrive `solarplanner.db` are at user_version 3 with all columns).
- **Edit-roof dialog shows dimensions read-only.** In edit mode the length/width
  are fixed, so they're rendered as disabled `TextFormField`s (via `_readOnlyField`,
  with a lock icon) under an "Abmessungen (nicht änderbar)" section — the user can
  see them but not change them. Regression-tested in `roof_dialogs_test.dart`
  (values shown + fields disabled).
- **Control-panel roof dropdown overflow:** `DropdownButtonFormField` overflows at narrow widths (its internal label+arrow row). Wrap it in `SizedBox(width: double.infinity)` + `isExpanded: true` and give the item `Text(overflow: TextOverflow.ellipsis)`. This overflow throws a RenderFlex exception that fails full-screen widget tests.
- **Schema version is now 8.** v3 added the module margin/gap columns, v4
  `Projects.active_module_type_id`/`active_inverter_id`, **v5 added the
  VDE-check data**: `Projects.tAmbientMinC/tAmbientMaxC/gridPhases/maxFeedInKw/
  hasMainEquipotential/isBoltedMounting`, `Inverters.acPhases` (default 3 — all
  seeded inverters are three-phase per datasheet), `Inverters.dcVoltageClass`,
  `Inverters.iOutA` (max AC output current from datasheet), **v6 added
  `Inverters.mcbA`** (recommended LS-Schalter rating in A, derived from
  `iOutA` via the IEC 60898 series). The v5→v6 guard backfills `mcb_a` from
  the stored datasheet values (guarded by table existence, like all column
  guards — `PRAGMA table_info` on a missing table returns empty, not an error).
  **v7 fixed `Projects.tAmbientMinC` at −25 °C** (IEC cold condition): column
  default changed from 5 to −25 and a `from < 7` guard normalizes all existing
  rows (constant UPDATE, idempotent). T_min/T_max are **read-only in the UI**
  (disabled `TextField`s in `_SiteConditions`, editor_screen.dart) and
  `updateSiteConditions` no longer accepts them. The cold-Voc calculation is
  unchanged in shape — `tCellColdC = tAmbientMinC − 10` (now −35 °C by
  default), so strings pack fewer modules than with the old T_min = 5 °C
  default; test expectations in `vde_validation_test.dart` use the −35 °C
  numbers. **v8 added** `Inverters.mppMinVoltage`/`mppMaxVoltage` (nullable, V —
  MPPT operating window from the datasheets; seed + name-backfill in both live
  DBs: GoodWe ET 200–850, SMA STPxx-50 210/260/345/430–800, SMA STPHxx-60
  100/120/160/200/240/300–850), `Inverters.qKvar` (nullable, informational) and
  `Wallboxes.breakerA`/`rcdRatedA` (nullable, A — installation-specific,
  entered via the inventory dialog, no backfill).
  `SolarModules.frameClass` ('I'/'II', null = unknown → treated as 'I'),
  `Wallboxes.rcdType` (default 'B'), `ModuleStrings.dcCableMm2/fuseA`. If you
  add columns later, bump `schemaVersion` and add a new `from < N` guard — do
  NOT rely on an existing guard, because drift only runs `onUpgrade` when stored
  version < schemaVersion. Regression-tested in the 'migration' group of
  `editor_controller_test.dart` (seeds a v2 file DB, reopens, asserts columns
  appear).
- **VDE planning checks** live in `EditorController.validateProject()`
  (cold/hot Voc per string, MPPT ΣIsc/ΣImp, fuse/cable via `recommendedFuseA`/
  `cableIzA`, feed-in limit, AC output current + MCB recommendation,
  frame earthing / equipotential, wallbox RCD type) and are shown in
  `_ViolationsPanel` (editor_screen.dart). The LS-Schalter info line is shown
  for the **active inverter only** (not every inventory item) and uses the
  stored `Inverters.mcbA` when present, falling back to the derived rating.
  Shared electrical helpers (`inverterOutputCurrentA`, `recommendedMcbA`,
  `mcbRatingForInverter`) live in `lib/db/electrical.dart` so seed, migration
  backfill and the controller use one source of truth. `load()` re-resolves a
  stale/missing active module/inverter selection (deleted inventory item) to
  the persisted or first available one. `autoAssignStrings` packs
  strings against the **cold-Voc** limit `min(1500, maxInputVoltage)` and
  respects per-MPPT parallel Isc/Imp sums. Remaining backlog:
  `docs/vde-norm-ideas.md` (single-phase 11.5 kVA limit, wallbox charge-current
  check, MPP window, DC/AC display).
- **Datasheet values are persisted in existing DBs by name-based backfill**
  (seed only runs on empty DBs): `iOutA`/`dcVoltageClass='1000V'` for all 14
  inverters, `frameClass='II'` (Jinko Tiger Neo — datasheet "Protection Class
  II") and `'I'` (Trina TSM, anodized frame) for modules. JA Solar JAM54D41
  stays NULL (class not stated in its datasheet). Both the local working DB and
  the OneDrive share copy were updated in place (2026-07).

## Yield efficiency table (hard-coded, NOT in DB)

- `lib/core/efficiency_table.dart` hard-codes the German PV yield table from
  Mertens, *Photovoltaik – Lehrbuch*, 5. Aufl., S. 58 (source image:
  `data/effizienz/pv-module_ausrichtung_vs_neigung.png`, bundled as
  `assets/effizienz/...` in pubspec). Rows = deviation from due south (0°=S,
  90°=O/W, 180°=N) in 10° steps; columns = pitch (Neigung) 0–90°. Values are
  constant → deliberately **not** persisted. `EfficiencyTable.efficiencyPercent`
  wraps azimuth to a south-deviation, rounds both axes to the nearest step,
  clamps out-of-range. Shown per roof in `_ControlPanel` (editor_screen.dart,
  `_roofEfficiencyRow`): roofs with modules show the % + a `table_chart`
  icon opening `showEfficiencyTableDialog` (efficiency_dialog.dart) with the
  image; roofs without modules show a blank value. Regression-tested in
  `test/efficiency_table_test.dart` (spot-checked against the image).
- Note: Dart `double.round()` rounds half away from zero (0.5 → 1).

## Canvas gestures (roof_canvas.dart)
- **Mouse-wheel zoom**: a `Listener.onPointerSignal` wrapping the
  `GestureDetector` catches `PointerScrollEvent` (import from
  `package:flutter/gestures.dart`, NOT rendering/material) and calls `_zoomAt`
  which anchors the zoom at the cursor position (not screen center). Scroll up
  = zoom in.
- **Whitespace panning**: in select mode, `onScaleStart` hit-tests the focal
  point. If it hits an object → move that object (`_dragStart`); if whitespace
  → record `_panStart` (focal point) + `_panStartOffset` (current pan), and
  `onScaleUpdate` pans by the screen-space delta. GOTCHA: store the focal point
  at start (not the pan offset) — computing `d.focalPoint - d.focalPoint` is
  always zero and the pan silently does nothing.
- **World painter must stay clipped.** The canvas uses
  `CustomPaint(size: Size.infinite)` so the painter can draw the whole world;
  it is wrapped in a `ClipRect` (inside the `RepaintBoundary`). Without the
  clip, roof/module paint leaks onto sibling widgets — e.g. it shows through
  the transparent control panel and looks like canvas objects are in front of
  the pane. Regression-tested: 'world painter is clipped to the canvas bounds'
  in `roof_canvas_test.dart` (asserts the infinite CustomPaint's direct parent
  is a ClipRect).
- **Resizable right pane** (editor_screen.dart, wide layout only): an 8 px
  `_PanelResizeHandle` between canvas and panel (1 px visible line,
  `SystemMouseCursors.resizeLeftRight` on hover via MouseRegion). Panel width
  starts at `_minPanelWidth = 340` (also the minimum); build clamps it to
  `window − _handleWidth(8) − _minCanvasWidth(200)` so dragging it wider than
  the window can never overflow the Row. Width is session state, not persisted.
  Regression-tested in `test/editor_screen_resize_test.dart` (widen,
  min-clamp, max-clamp).

- `seed.dart` inserts the full inverter inventory from datasheets in
  `data/datenblatt/wechselrichter/`:
  - **GoodWe ET PLUS+** (`hybridwechselrichter_goodwe_kn_et_plus_datenblatt.md`):
    GW5KN-ET / 6.5KN-ET / 8KN-ET / 10KN-ET, hybrid, **2 MPPT × 1 string**,
    min V=180 (start-up), max V=1000, I_in/MPP=16 A, I_sc/MPP=21.2 A.
  - **SMA STPxx-50** (`STPxx-50-DS-de-21.md`): STP 12/15/20/25-50, hybrid,
    **3 MPPT × 2 strings**.
  - **SMA STPHxx-60** (`STPHxx-60-DS-de-10.md`): STPH5/6/8/10/12/15-60 (marketing
    names Hybrid X 5..15), hybrid, **3 MPPT × 1 string**. Seeded name format is
    `STPHxx-60 (Hybrid X n)` so both technical and marketing names are visible.
  The earlier seed had two wrong single entries ("ET PLUS+ GW8KN" and a
  mislabeled `Sungrow` "STP 12") which were replaced.
- Note: seed only runs on an empty DB (`seedIfEmpty`), so existing databases
  were updated in place — the pre-existing GoodWe (id=1) and SMA STP-12 (id=2)
  rows were UPDATEd to their proper names/values to preserve the FKs from
  `module_strings`; all other products inserted by name-match.

## Module seed (seed.dart)

- `seed.dart` seeds the module inventory from datasheets in
  `data/datenblatt/module/`. **Trina Solar Vertex S**
  (`VertexS_NEG9RC.27_DE_2023_B_web.md`): TSM-415/420, 425, 430, 435/440 —
  bifacial double-glass N-type i-TOPCon, 144 cells, all 1762×1134×30 mm,
  21.0 kg, Voc temp coeff −0.24 %/K. Range products use their **max** Pmax and
  the top-of-range electrical values.
- The earlier seed had a mislabeled "VertexS NEG9RC.27 435" (wrongly attributed
  to `NEG (Canadian Solar)`) which was removed and replaced by the four correct
  Trina Solar products. In existing DBs that row was deleted only when no
  `placed_modules` referenced it (it had none).
- **JA Solar Deep Blue 4.0** (`JAM54D41 430-455 LB_25-yr warranty.md`):
  JAM54D41-430/435/440/445/450/455/LB — n-type bifacial double glass, 108
  cells, all 1762×1134×30 mm, 22 kg, Voc coeff −0.26 %/K.
- **JinkoSolar Tiger Neo 54HL4R-(V)** (`Datenblatt-Tiger_Neo_...md`):
  435-440W / 445-450W / 455-460W — N-type TOPCon mono-facial, 108 cells,
  all 1762×1134×30 mm, 21 kg, Voc coeff −0.25 %/K. Range products use max Pmax
  + top-of-range electrical values. The pre-existing "Tiger Neo 54HL4R-V 460"
  entry IS the 455-460W product (kept, not duplicated).

## Active module/inverter selection is persisted per project
- `Projects` has nullable `active_module_type_id` + `active_inverter_id`
  (schema v4). The editor's "Modultyp" / "Wechselrichter" dropdowns call
  `EditorController.setActiveModuleType` / `setActiveInverter`, which persist the
  choice to the project row AND re-run `autoAssignStrings()` so string Voc and
  the Anlage totals reflect the new inverter limits / module type. `load()`
  restores these from the project row (falling back to the first inventory
  item). Do NOT assign `activeModuleTypeId`/`activeInverterId` directly from the
  UI — that skips persistence. The "Modultyp" is a **system-wide** choice:
  `setActiveModuleType` re-types every placed module to the new product (so
  Anlage kWp + each string's Voc sum update) while keeping which module sits in
  which string (memberships reference placed-module ids, so they survive). It does
  NOT rebuild strings. `setActiveInverter` only persists + repaints; use "Alle
  Strings automatisch zuweisen" to rebuild against the new inverter's limits.

## String assignment (editor_controller.dart)

- `string_modules` has PK `(string_id, placed_module_id)`. A module belongs to
  exactly **one** string. `assignSelectedToActiveString` must: (1) no-op if the
  module is already in the target string, (2) delete it from any other string
  first, then insert. Blindly inserting throws `UNIQUE constraint failed` when
  re-assigning a module.
- Drift compound `where`: use static `Expression.and([a, b])` — NOT `&&`
  (non-bool operand) and NOT instance `.and(...)` (static method).

## Canvas label z-order (roof_canvas.dart)

- Roof labels (name/area at centroid, edge lengths) must be drawn in a **final
  foreground pass** after obstacles and placed modules, otherwise they get
  painted over. The painter collects labels into a list during the roof loop and
  renders them last, before `canvas.restore()`.
- **Move semantics:** All objects (roofs, obstacles, modules) are moveable via
  drag. Moving a roof moves its assigned `placedModules` (by `roofId`) along
  with it. Moving a module does NOT affect its roof.
- **Gesture wiring gotcha (Windows/desktop):** The canvas uses a single
  `onScaleStart/Update/End` recognizer for pan+move. In `onScaleUpdate`, a drag
  that started on an object (`_dragStart != null && _panStart == null`) MUST
  route the world delta to `controller.updateMove(from, to)` — an early `return`
  there silently disables all object moving (pan still works, so it's easy to
  miss). Controller unit tests call `beginMove/updateMove/endMove` directly and do
  NOT catch this; a widget test that performs `tester.startGesture(...).moveBy()`
  on the canvas is required. See 'dragging a roof' in `roof_canvas_test.dart`.
- **Roof-move module drift:** When a roof is dragged, its modules must be
  repositioned from their **fixed start positions** (captured in `beginMove` into
  `_moveStartModulePos`), NOT by adding the cumulative delta to each module's
  *current* position. The gesture reports a growing `to - from` delta every update;
  re-applying it to an already-moved position makes panels drift away
  quadratically. The roof itself is safe because it's computed from the fixed
  `_moveStartPoly`. Regression-tested with multiple incremental updates in
  `editor_controller_test.dart` (group 'move').

## Module naming / labels (`{roofId}.{stringId}.{moduleId}`)

- Every placed module that belongs to a string gets an identifier shown on the
  canvas as white text in a semi-transparent black band along its top edge (in
  the module's local rotated frame, so it follows panel orientation). Modules
  without a string get no label.
- **Label parts** (all 1-based, derived in `EditorController.moduleLabels` /
  `moduleLabel()` — session state only, NOT persisted):
  - *roofId* = rank of the module's roof among roofs that carry ≥1 placed
    module (sorted by `Roofs.id`). Empty roofs do NOT consume a rank.
  - *stringId* = `mppIndex + 1` of the module's string — i.e. the MPPT
    tracker number on the inverter (global per project, not per string).
  - *moduleId* = position within that tracker: modules of all strings on the
    same `mppIndex` are numbered continuously (strings ordered by id, then by
    series `position`).
- **Rendering** (`_drawModuleLabel` in roof_canvas.dart): band height
  `min(h*0.9, 13/zoom)`, font size `12/zoom` (constant ~12px on screen at any
  zoom), shrinks to fit the module width. Only drawn when the module is ≥ ~14px
  on screen (`min(w,h)*zoom >= 14`) so tiny panels don't get unreadable text.
- Regression-tested in `editor_controller_test.dart` (group 'moduleLabels'):
  format/uniqueness, gap-free roof ranking with an empty middle roof,
  continuous numbering across parallel strings on one MPPT, and null for
  unassigned modules.

## Android sync MethodChannel contract (source of truth = Kotlin)

- Channel: `solar_planner/sync`
  (`app/android/app/src/main/kotlin/de/appternity/solar_planner/MainActivity.kt`)
- Kotlin expects:
  - `resolveChild` `{parent, name}` → child uri or null
  - `listFiles` `{dir}` → list of names
  - `readFile` `{uri}` → raw **ByteArray** (NOT base64)
  - `writeFile` `{uri, data}` where `data` is a **ByteArray**
  - `createFile` `{parent, name, mimeType}` → new uri
  - `statFile` `{uri}` → map with `size` and `mtime` (NOT a list)
  - `deleteFile` `{uri}`
- Dart side (`app/lib/sync/uri_backend.dart`) must match this exactly. Send a
  `Uint8List` for write bytes so the standard codec encodes a byte array.

## Commands (run from `app/`)

- Analyze: `flutter analyze`
- Test:    `flutter test`
- Regen DB:`dart run build_runner build --delete-conflicting-outputs`
  (note: `--delete-conflicting-outputs` is now a no-op warning)
