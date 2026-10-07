# Heat Pump Components Inventory — Design Spec

## 1. Purpose

Create a complete inventory system for all 28 components from `data/systemuebersicht/komponenten.md` that are assigned to the `Wärmepumpe` system (and shared components used by PV, BAT, WB). Each component gets its own inventory table with type-specific spec columns, a unified status-mapping table, a calculation engine, and full UI integration.

## 2. Scope

### 2.1 Components (28 total)

**WP-specific (22):** From `komponenten.md` Chapter 2, components where `System` column contains `WP`:

| # | ID | Class | Name | Key specs |
|---|---|---|---|---|
| 1 | `HYD.WAR.Boiler_TWW` | Hydraulisch | Warmwasser-Boiler | volume (CALC_Boiler_Volumen) |
| 2 | `HYD.WAR.HW_Verteiler` | Hydraulisch | HW-Verteiler | zones |
| 3 | `HYD.WAR.Zirkulationspumpe` | Hydraulisch | Zirkulationspumpe | flow, head, EEI |
| 4 | `HYD.HEI.Waermepumpe` | Hydraulisch | Wärmepumpe | (already `HeatPumps` table) |
| 5 | `HYD.HEI.Pumpe_WP_Seite` | Hydraulisch | Heizungspumpe WP-Seite | flow, head, EEI |
| 6 | `HYD.HEI.Rueckflussverhinderer` | Hydraulisch | Rückflussverhinderer | DN size |
| 7 | `HYD.HEI.Schmutzfanger_Filter` | Hydraulisch | Schmutzfänger | filter size (2mm) |
| 8 | `HYD.HEI.Durchflusswaechter` | Hydraulisch | Durchflusswächter | flow (CALC_Min_Durchfluss) |
| 9 | `HYD.HEI.Pufferspeicher` | Hydraulisch | Pufferspeicher | volume (CALC_Puffer_Volumen) |
| 10 | `HYD.HEI.Plattenwaermetauscher` | Hydraulisch | Plattenwärmetauscher | plates, area |
| 11 | `HYD.HEI.Sicherheitsventil_3bar` | Hydraulisch | Sicherheitsventil | opening pressure (3 bar) |
| 12 | `HYD.HEI.Membranausdehnungsgefaess` | Hydraulisch | Membranausdehnungsgefäß | volume (CALC_MAG_Volumen) |
| 13 | `HYD.HEI.Entluftungsventil_auto` | Hydraulisch | Entlüftungsventil | DN size |
| 14 | `HYD.HEI.Pumpe_Heizkreis` | Hydraulisch | Heizungspumpe Heizkreis | flow, head, EEI |
| 15 | `HYD.HEI.Absperrventil_Vorlauf` | Hydraulisch | Absperrventil Vorlauf | DN size |
| 16 | `HYD.HEI.Absperrventil_Ruecklauf` | Hydraulisch | Absperrventil Rücklauf | DN size |
| 17 | `HYD.HEI.FBH_Verteiler` | Hydraulisch | FBH-Verteiler | zones |
| 18 | `HYD.HEI.FBH_Schleife` | Hydraulisch | FBH-Schleife | PEX length, pipe size |
| 19 | `HYD.WAR.Mischbatterie` | Hydraulisch | Mischbatterie | DN size |
| 20 | `HYD.KAL.RFV_Gartenanschluss` | Hydraulisch | RFV Garten | DN size |
| 21 | `HYD.HEI.Zuleitung_Fuellwasser` | Hydraulisch | Füllwasser-Zuleitung | pipe size |
| 22 | `HYD.KAL.Verbraucher_nur_KW` | Hydraulisch | Kaltwasser-Verbraucher | count |

**WP electrical (6):** Components where `System` column contains `WP`:

| # | ID | Class | Name | Key specs |
|---|---|---|---|---|
| 23 | `ELE.STK.LS_Schalter_WP` | Starkstrom | LS-Schalter WP | current rating (16A) |
| 24 | `ELE.STK.FI_Schutzschalter` | Starkstrom | FI-Schutzschalter | type (A), current (40A) |
| 25 | `ELE.STK.Zuleitung_Starkstrom` | Starkstrom | Zuleitung WP | cross-section (6mm²), length |
| 26 | `ELE.SCH.Trennschalter` | Schaltschrank | Trennschalter WP | current rating (16A) |
| 27 | `ELE.SCH.Klemmenleiste` | Schaltschrank | Klemmenleiste | bus width |
| 28 | `ELE.ERD.PE_Anschluss` | Erdung | PE-Anschluss | wire cross-section (4mm²) |

**Shared components** (visible in Projekt tab, referenced by all systems): `HYD.KAL.Hausanschluss`, `HYD.KAL.Zaehler_Absperrung`, `HYD.KAL.KW_Verteiler`, `ELE.ERD.HPA_Anschluss`.

### 2.2 What's NOT in scope (this spec)

- PV-specific inventory (already partially covered by `SolarModules`, `Inverters`)
- Battery-specific inventory (already has `Batteries` table)
- Wallbox-specific inventory (already has `Wallboxes` table)
- Communication components (KOM.NET, KOM.GW) — deferred to future iteration
- Database seeding of real manufacturer data (only generic placeholders)

## 3. Architecture

### 3.1 Database schema

**Existing tables** (modified):
- `HeatPumps` — already exists (3 seed items)
- `HeatLoops` — already exists

**New tables:**

```
inventory_items (28 items)
  id (PK, auto-increment)
  name (text)            -- display name
  manufacturer (text)    -- optional
  seriesName (text)      -- optional
  modelNumber (text)     -- optional
  componentType (text)   -- e.g. "HYD.WAR.Boiler_TWW"

component_status (28 rows per project)
  id (PK, auto-increment)
  projectId (FK → projects.id)
  inventoryItemId (FK → inventory_items.id)
  status (text)          -- "Offen" | "In Planung" | "Geplant" | "Eingebaut" | "Nicht Benötigt"
  required (bool)        -- is this component required for this project?
  quantity (int)         -- calculated quantity (from formulas)
```

**27 new inventory tables** (one per component type, each with type-specific spec columns):

| Table | Key columns |
|---|---|
| `Boiler` | `volumeLitres` (CALC_Boiler_Volumen) |
| `HwVerteiler` | `zones` |
| `Zirkulationspumpe` | `flowRateLMin`, `headPressureM`, `eeiRating` |
| `HydraulicPump` | (reuses `HeatPumps` — skip) |
| `Rueckflussverhinderer` | `dnSize` |
| `Schmutzfanger` | `filterSizeMm` (default 2) |
| `Durchflusswaechter` | `minFlowM3H` (CALC_Min_Durchfluss) |
| `Pufferspeicher` | `volumeLitres` (CALC_Puffer_Volumen) |
| `Plattenwaermetauscher` | `plates`, `areaM2` |
| `SafetyValve` | `openingPressureBar` (default 3) |
| `Membranausdehnungsgefaess` | `volumeLitres` (CALC_MAG_Volumen) |
| `Entluftungsventil` | `dnSize` |
| `Heizkreispumpe` | `flowRateLMin`, `headPressureM`, `eeiRating` |
| `Absperrventil` | `dnSize` |
| `FbhVerteiler` | `zones` |
| `FbhSchleife` | `pipeLengthM`, `pipeDiameterMm` (default 16) |
| `Mischbatterie` | `dnSize` |
| `RfvGartenanschluss` | `dnSize` |
| `FuellwasserZuleitung` | `pipeDiameterMm` |
| `KaltwasserVerbraucher` | `count` |
| `LsSchalter` | `currentRatingA` (default 16), `poleCount` (default 3), `charType` (default 'B') |
| `FiSchutzschalter` | `currentRatingA` (default 40), `sensitivityMa` (default 30), `type` (default 'A') |
| `ZuleitungStarkstrom` | `crossSectionMm2` (default 6), `lengthM`, `conductorMaterial` (default 'Cu') |
| `Trennschalter` | `currentRatingA` (default 16), `poleCount` (default 3) |
| `Klemmenleiste` | `busWidth` |
| `PeAnschluss` | `wireCrossSectionMm2` (default 4) |

### 3.2 Status enum

```dart
enum ComponentStatus {
  offen,       // nothing assigned yet, but needs to be
  inPlanung,   // manufacturer/model assigned, not installed
  geplant,     // planned but no specific manufacturer/model
  eingebaut,   // installed, manufacturer/model assigned
  nichtBenotigt, // neither planned nor required
}
```

### 3.3 ComponentType enum (28 values)

```dart
enum ComponentType {
  boilerTww,
  hwVerteiler,
  zirkulationspumpe,
  hydraulicPump,  // reuses HeatPumps
  rueckflussverhinderer,
  schmutzfanger,
  durchflusswaechter,
  pufferspeicher,
  plattenwaermetauscher,
  safetyValve,
  membranausdehnungsgefaess,
  entluftungsventil,
  heizkreispumpe,
  absperrventil,
  fbhVerteiler,
  fbhSchleife,
  mischbatterie,
  rfvGartenanschluss,
  fuellwasserZuleitung,
  kaltwasserVerbraucher,
  lsSchalter,
  fiSchutzschalter,
  zuleitungStarkstrom,
  trennschalter,
  klemmenleiste,
  peAnschluss,
  hpaAnschluss,  // shared
}
```

### 3.4 Data flow

```
Projects.wpAnlage = true
    → ComponentCalculator recalculates all 28 components
    → For each component:
        a. Evaluate formula from komponenten.md §3
        b. Update component_status.quantity (int)
        c. Set component_status.required = true if min > 0
    → EditorController.notifyListeners()
    → UI rebuilds with updated quantities and status badges
```

### 3.5 Seed data

28 generic placeholder items in `inventory_items`, one per component type:

| Component | Generic name (DE) | Status |
|---|---|---|
| `HYD.WAR.Boiler_TWW` | "Warmwasser-Boiler Standard" | `Geplant` |
| `HYD.WAR.HW_Verteiler` | "HW-Verteiler Standard" | `Geplant` |
| `HYD.WAR.Zirkulationspumpe` | "Zirkulationspumpe Standard" | `Geplant` |
| `HYD.HEI.Waermepumpe` | (uses existing `HeatPumps` table) | — |
| `HYD.HEI.Pumpe_WP_Seite` | "WP-Heizungspumpe Standard" | `Geplant` |
| `HYD.HEI.Rueckflussverhinderer` | "Rückflussverhinderer Standard" | `Geplant` |
| `HYD.HEI.Schmutzfanger_Filter` | "Schmutzfänger Standard" | `Geplant` |
| `HYD.HEI.Durchflusswaechter` | "Durchflusswächter Standard" | `Geplant` |
| `HYD.HEI.Pufferspeicher` | "Pufferspeicher Standard" | `Geplant` |
| `HYD.HEI.Plattenwaermetauscher` | "Plattenwärmetauscher Standard" | `Geplant` |
| `HYD.HEI.Sicherheitsventil_3bar` | "Sicherheitsventil 3 bar" | `Geplant` |
| `HYD.HEI.Membranausdehnungsgefaess` | "Membranausdehnungsgefäß Standard" | `Geplant` |
| `HYD.HEI.Entluftungsventil_auto` | "Entlüftungsventil Standard" | `Geplant` |
| `HYD.HEI.Pumpe_Heizkreis` | "Heizkreispumpe Standard" | `Geplant` |
| `HYD.HEI.Absperrventil_Vorlauf` | "Absperrventil Standard" | `Geplant` |
| `HYD.HEI.Absperrventil_Ruecklauf` | "Absperrventil Rücklauf Standard" | `Geplant` |
| `HYD.HEI.FBH_Verteiler` | "FBH-Verteiler Standard" | `Geplant` |
| `HYD.HEI.FBH_Schleife` | "FBH-Schleife Standard" | `Geplant` |
| `HYD.WAR.Mischbatterie` | "Mischbatterie Standard" | `Geplant` |
| `HYD.KAL.RFV_Gartenanschluss` | "RFV Gartenanschluss Standard" | `Geplant` |
| `HYD.HEI.Zuleitung_Fuellwasser` | "Füllwasser-Zuleitung Standard" | `Geplant` |
| `HYD.KAL.Verbraucher_nur_KW` | "Kaltwasser-Verbraucher Standard" | `Geplant` |
| `ELE.STK.LS_Schalter_WP` | "LS-Schalter B16 Standard" | `Geplant` |
| `ELE.STK.FI_Schutzschalter` | "FI-Schutzschalter Typ A 40A" | `Geplant` |
| `ELE.STK.Zuleitung_Starkstrom` | "Zuleitung NYM-J 5x6 Standard" | `Geplant` |
| `ELE.SCH.Trennschalter` | "Trennschalter B16 Standard" | `Geplant` |
| `ELE.SCH.Klemmenleiste` | "Klemmenleiste Standard" | `Geplant` |
| `ELE.ERD.PE_Anschluss` | "PE-Anschluss 4mm² Standard" | `Geplant` |

## 4. UI Integration

### 4.1 Projekt tab — Systemstatus section

Add a new section showing per-system completeness:

```
┌─ Systemstatus ─────────────────────────────────────┐
│  PV-Anlage:  [██████░░░░]  6/12  (50%)            │
│  Batteriespeicher: [██████████]  8/8  (100%)      │
│  Wallbox:      [██████░░░░]  5/8  (63%)            │
│  Wärmepumpe:   [███████░░░]  7/12  (58%)  ⚠️      │
└────────────────────────────────────────────────────┘
```

Each system shows:
- Progress bar (filled = assigned, empty = Offen)
- Fraction (assigned / total)
- Percentage
- Warning icon if any required component is `Offen`

### 4.2 Shared components in Projekt tab

Under "Hausanschluss & Elektrik" section, show shared components with:
- Status badge (color-coded)
- Calculated quantity
- Inventory selector (dropdown) if editable

### 4.3 Wärmepumpe tab — Full implementation

Replace `_SystemPlaceholder` with a full tab showing all 28 WP components:

```
┌─ Wärmepumpe ──────────────────────────────────────┐
│                                                   │
│  Hydraulik                                        │
│  ┌─────────────────────────────────────────────┐ │
│  │ Wärmepumpe (Vaillant aroTHERM pro VWL 115)  │ │
│  │ Status: Eingebaut  Qty: 1                   │ │
│  └─────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────┐ │
│  │ Heizungspumpe WP-Seite                      │ │
│  │ Status: In Planung  Qty: 1                  │ │
│  └─────────────────────────────────────────────┘ │
│  ... (remaining 21 components)                    │
│                                                   │
│  Elektrik                                         │
│  ┌─────────────────────────────────────────────┐ │
│  │ LS-Schalter WP                              │ │
│  │ Status: Offen  Qty: 1  ⚠️                  │ │
│  └─────────────────────────────────────────────┘ │
│  ... (remaining 5 components)                     │
└────────────────────────────────────────────────────┘
```

Each component card shows:
- Component name (from `komponenten.md`)
- Status badge (color-coded: Offen=red, In Planung=yellow, Geplant=blue, Eingebaut=green, Nicht Benötigt=gray)
- Calculated quantity (from formulas)
- Inventory dropdown (if editable and `PARAM_WP_anlage = true`)
- Warning icon if required but status is `Offen`

### 4.4 Conditional visibility

Components are hidden when:
- `PARAM_WP_anlage = false` (all WP components hidden)
- Status = `Nicht Benötigt`
- Some components only appear conditionally based on other params:
  - `HYD.HEI.Pufferspeicher`: shown when `PARAM_Radiatoren = true` OR `PARAM_FBH_Zonen > 6`
  - `HYD.WAR.Zirkulationspumpe`: shown when `PARAM_HW_Schleife_m > 15`

## 5. Calculation Engine

### 5.1 ComponentCalculator class

```dart
class ComponentCalculator {
  /// Recalculates all quantities for a project.
  /// Called when any Project parameter or component quantity changes.
  Map<ComponentType, ComponentCalculation> calculate(int projectId);
  
  /// Returns per-system completeness info.
  Map<SystemType, SystemCompleteness> getSystemCompleteness(int projectId);
}

class ComponentCalculation {
  final ComponentType type;
  final int minQuantity;
  final int maxQuantity;
  final bool required;
  final bool isWithinThreshold(int? actualQuantity);
}

class SystemCompleteness {
  final SystemType system;
  final int totalComponents;
  final int assignedComponents;  // status != Offen && status != NichtBenötigt
  final int requiredComponents;
  final int unassignedRequired;  // status == Offen && required
  double get completionPercentage => totalComponents > 0 ? assignedComponents / totalComponents : 0;
  bool get isComplete => unassignedRequired == 0;
}
```

### 5.2 Formula evaluation

The calculator evaluates formulas from `komponenten.md` §3 as Dart expressions, substituting:
- `PARAM_*` values from `Projects` table
- Component quantities by name (e.g., `Waermepumpe` → quantity of `HYD.HEI.Waermepumpe`)
- Constants and operators (`ceil()`, `? :`, `×`, `+`, `-`)

## 6. Testing

- Unit tests for `ComponentCalculator` (formula evaluation, edge cases)
- Widget tests for status badges, progress bars, inventory dropdowns
- Integration tests for status lifecycle (Offen → In Planung → Eingebaut)
- Migration tests (schema v14 → v15)

## 7. Implementation plan (invoked via writing-plans skill)

See implementation plan document for task breakdown.

## 8. Self-review

- No placeholders or TBDs
- 27 inventory tables + 1 status table + 28 generic seeds + calculation engine + UI
- Scope: WP-specific (22) + WP electrical (6) = 28 components
- Shared components (Hausanschluss, etc.) visible in Projekt tab
- Communication components (KOM.*) deferred
- PV/BAT/WB inventory already exists
- Migration from v13 → v14
