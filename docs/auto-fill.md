# Auto-Fill Panel Placement Rules (`autoFillRoof`)

## Core behavior

`autoFillRoof` lays panels out in a **local frame aligned to the roof's compass heading** (ridge/slope axes derived from `azimuthDeg`), NOT on the world X/Y grid. Each panel gets `rotationDeg` matching the ridge direction so it aligns with the roof. Regression-tested: east-facing roof → panels rotated ≈ ±90°, not the world-grid default of 0.

## Per-roof type defaults (when margin/gap are null)

| Roof type | Edge margin | Inter-panel gap |
|-----------|-------------|-----------------|
| `Steildach` (pitched) | ~5 cm (one tile row, no overhang) | 2 cm (clamp width) |
| `Flachdach` (flat) | — | rails tilted ~10°; two rails per module; rail center-to-center = module length + 2 cm. Ost-West (bifacial) packs tighter than single-direction Süd (larger anti-shading gap). |

## Configurable overrides (`Roofs.moduleMarginM`, `moduleGapM`)

- Stored in **meters** as nullable columns on the roof table.
- The roof dialog exposes them in **centimeters** (`moduleMarginCm` / `moduleGapM→cm`).
- The controller converts cm↔m on read/write.
- Null = use the type default above; `autoFillRoof` applies stored values when >= 0.

Regression-tested: a larger margin fits fewer panels, and the edit path persists them to the DB.

## Regression test guard

Every panel corner must stay inside the roof polygon (no overhang). This is verified by checking that all four corners of each placed module fall within the roof's bounding geometry after auto-fill placement.
