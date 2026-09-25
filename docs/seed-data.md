# Seed Data — Datasheets & `seed.dart` Contract

## Inverter inventory (`data/datenblatt/wechselrichter/`)

| Product | File source | Key specs (per datasheet) | MPPT config | Seeded name format |
|---------|-------------|---------------------------|-------------|--------------------|
| GoodWe ET PLUS+ | `hybridwechselrichter_goodwe_kn_et_plus_datenblatt.md` | GW5KN-ET / 6.5KN-ET / 8KN-ET / 10KN-ET; hybrid; min V=180 (start-up), max V=1000, I_in/MPP=16 A, I_sc/MPP=21.2 A | **2 MPPT × 1 string** | `GW5KN-ET PLUS+`, etc. |
| SMA STPxx-50 | `STPxx-50-DS-de-21.md` | STP 12/15/20/25-50; hybrid | **3 MPPT × 2 strings** | `SMA STP 12-5.0`, etc. |
| SMA STPHxx-60 | `STPHxx-60-DS-de-10.md` | STPH5/6/8/10/12/15-60 (marketing: Hybrid X 5..15); hybrid; three-phase per datasheet | **3 MPPT × 1 string** | `STPH5-60 (Hybrid X 5)`, etc. |

> Note: The earlier seed had two wrong single entries ("ET PLUS+ GW8KN" and a mislabeled `Sungrow` "STP 12") which were replaced. Seed only runs on an empty DB (`seedIfEmpty`). Existing databases are updated in place — pre-existing rows (e.g., GoodWe id=1, SMA STP-12 id=2) are UPDATEd to their proper names/values to preserve FKs from `module_strings`.

## Module inventory (`data/datenblatt/module/`)

| Product | File source | Key specs (per datasheet) |
|---------|-------------|---------------------------|
| Trina Solar Vertex S NEG9RC.27 | `VertexS_NEG9RC.27_DE_2023_B_web.md` | TSM-415/420, 425, 430, 435/440; bifacial double-glass N-type i-TOPCon; 144 cells; all 1762×1134×30 mm; 21.0 kg; Voc temp coeff −0.24 %/K. Range products use their **max** Pmax and top-of-range electrical values. |
| JA Solar Deep Blue 4.0 JAM54D41 | `JAM54D41 430-455 LB_25-yr warranty.md` | JAM54D41-430/435/440/445/450/455/LB; n-type bifacial double glass; 108 cells; all 1762×1134×30 mm; 22 kg; Voc coeff −0.26 %/K |
| JinkoSolar Tiger Neo 54HL4R-(V) | `Datenblatt-Tiger_Neo_...md` | 435-440W / 445-450W / 455-460W; N-type TOPCon mono-facial; 108 cells; all 1762×1134×30 mm; 21 kg; Voc coeff −0.25 %/K. Range products use max Pmax + top-of-range electrical values. |

> Note: The earlier seed had a mislabeled "VertexS NEG9RC.27 435" (wrongly attributed to `NEG (Canadian Solar)`) which was removed and replaced by the four correct Trina Solar products. In existing DBs that row was deleted only when no `placed_modules` referenced it (it had none).

## Frame class backfill (schema v6, name-based)

Datasheet values are persisted in existing DBs by **name-based backfill** (seed only runs on empty DBs):
- `frameClass='II'`: Jinko Tiger Neo — datasheet "Protection Class II"
- `frameClass='I'`: Trina TSM, anodized frame
- JA Solar JAM54D41 stays NULL (class not stated in its datasheet)

Both the local working DB and the OneDrive share copy were updated in place (2026-07).
