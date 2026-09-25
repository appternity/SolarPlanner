# VDE Norm Validation — Backlog & Ideas

## Implemented (in `EditorController.validateProject()` → `_ViolationsPanel`)

| Check | Standard reference | Status |
|-------|-------------------|--------|
| Cold/hot Voc per string | DIN VDE 0126-1-1, IEC 62446 | ✅ |
| MPPT ΣIsc / ΣImp sums | VDE-AR-N 4105 §7.3.2 | ✅ |
| Fuse/cable sizing (`recommendedFuseA`, `cableIzA`) | DIN VDE 0100-443, IEC 60364-4-41 | ✅ |
| Feed-in limit check | VDE-AR-N 4105 §7.2 | ✅ |
| AC output current + MCB recommendation | VDE-AR-N 4105 §8.1, IEC 60898 series | ✅ |
| Frame earthing / equipotential bonding | DIN VDE 0100-534 (TT/IT systems) | ✅ |
| Wallbox RCD type check | VDE-AR-N 4105 §7.2, IEC 60364-7-712 | ✅ |

The LS-Schalter info line is shown for the **active inverter only** (not every inventory item) and uses the stored `Inverters.mcbA` when present, falling back to the derived rating. Shared electrical helpers (`inverterOutputCurrentA`, `recommendedMcbA`, `mcbRatingForInverter`) live in `lib/db/electrical.dart`.

## Remaining backlog items

| # | Idea / Missing check | Reference(s) |
|---|----------------------|--------------|
| 1 | Single-phase grid: enforce ≤ 11.5 kVA feed-in limit (VDE-AR-N 4105 §7.2, Table C.3) | VDE-AR-N 4105 |
| 2 | Wallbox charge-current check against inverter AC capacity & cable rating | DIN VDE 0100-600, IEC 60364-7-712 §842.2 |
| 3 | MPPT voltage window: verify module string Voc (cold) ≥ `mppMinVoltage` and ≤ `mppMaxVoltage` of the active inverter(s). If out-of-range → warn or suggest reconfiguring strings / choosing a different inverter/module combo. | IEC 61727, VDE-AR-N 4105 §8.3 |
| 4 | DC/AC display: show real-time (or simulated) Pdc/Pac per string and total yield vs. rated power on the canvas / control panel. | — |

## Data model notes for VDE checks

The following columns were added in schema v5–v8 to support these validations:

- `Projects`: `tAmbientMinC` (default −25 °C, IEC cold condition), `maxFeedInKw`, `gridPhases`, `hasMainEquipotential`, `isBoltedMounting`.
- `Inverters`: `acPhases` (default 3 — all seeded inverters are three-phase per datasheet), `dcVoltageClass`, `iOutA` (max AC output current from datasheet), `mcbA` (recommended LS-Schalter rating, derived via IEC 60898 series and backfilled in v5→v6 migration).
- `SolarModules`: `frameClass` ('I'/'II', null = unknown → treated as 'I').
