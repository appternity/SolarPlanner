# AGENTS.md — SolarPlanner

Implementation of any task list MUST follow the Superpowers workflow: worktree → TDD (red-green-refactor) → subagent-driven execution → code review → finish-branch.

## Role & code style (IMPORTANT)

You are an **expert Flutter developer**. Write clean, idiomatic Dart following Flutter best practices.

- Understand state management (Provider, Riverpod, Bloc, GetX), widget lifecycles, performance optimization, and modern Flutter patterns (Riverpod v2+, GoRouter, isolated packages).
- Always include type hints, proper error handling, null safety, and comments where necessary.
- When providing complete files or large code blocks, use markdown code blocks with language identifiers.
- For complex problems, break the solution into steps **before** writing code.

## Git

- **Never commit unless the user explicitly asks.** The user controls when and what gets committed; leave changes in the working tree. The only exception are contents in `.github\workflows\*.yml`.

## Project layout

```
SolarPlanner/
├── app/                      # Flutter app (run `flutter` commands from here)
│   ├── lib/db/               # Drift schema + migrations
│   └── ...                   # UI, controllers, services
├── docs/                     # Architecture reference (see below)
├── data/datenblatt/          # Medallion: bronze/ (PDFs), silver/ (JSON extracts)
├── data/systemuebersicht/    # HAK-Bestandsaufnahme + PV-Stromlaufplan (s. docs-Index unten)
├── src/solarplanner/         # Python auxiliary files
└── AGENTS.md                 # This file — slim index + role guide
```

- Run all `flutter` commands from **`app/`**.
- Open question: `src/solarplanner/__init__.py` looks like a leftover hello-world; root scripts + `data/` may need cleanup or docs.

## Architecture reference (docs/)

Deep-dive documentation organized by topic — read these for implementation details, schema evolution history, and bug-fix rationale:

| File | Covers |
|------|--------|
| [`docs/architecture-overview.md`](./docs/architecture-overview.md) | Roof model v2, VDE validation checks, module naming/labels, active selection persistence, string assignment gotchas, canvas painter architecture, test infrastructure notes. **Start here for the full system picture.** |
| [`docs/db-facts.md`](./docs/db-facts.md) | Drift 2.35 API patterns (companions, `customSelect`, `into`), migration idempotency guards, raw row reading from SQL strings. |
| [`docs/auto-fill.md`](./docs/auto-fill.md) | Panel placement rules per roof type, margin/gap configuration, regression test guard for no-overhang. |
| [`docs/vde-norm-ideas.md`](./docs/vde-norm-ideas.md) | Implemented VDE checks (Voc, MPPT sums, fuse/cable sizing), remaining backlog items with standard references. |
| [`docs/seed-data.md`](./docs/seed-data.md) | Datasheet sources for inverters/modules, name-based backfill strategy for existing DBs. |
| [`docs/canvas-gestures.md`](./docs/canvas-gestures.md) | Pointer event wiring (pan+zoom gotcha), world painter clipping, move semantics & module drift fix. |
| [`docs/module-labels.md`](./docs/module-labels.md) | Label format `{roofId}.{stringId}.{moduleId}`, rendering rules, regression test coverage. |
| [`data/systemuebersicht/HAUSANSCHLUSSKASTEN_INVENTAR.md`](./data/systemuebersicht/HAUSANSCHLUSSKASTEN_INVENTAR.md) | **Bestandsaufnahme HAK** (Foto 2026-09-27): Zähler AEGIS M132 (bidirektional, Stadtwerke/GLIEMATO), Hauptschalter, LS-Reihen, FI-Gruppen, HPA-Schiene, freie Plätze. Offene Punkte: Nennströme ablesen, maxFeedInKw erfragen. |
| [`data/systemuebersicht/STROMLAUFPLAN_PV.md`](./data/systemuebersicht/STROMLAUFPLAN_PV.md) | **PV-Stromlaufplan Netzbetreiber → Module** (8–25 kWp, 3~): AC-Seite (Kuppelstelle, LS-Stufung, FI Typ B), DC-Seite (String-Spannungsfenster Voc_cold/Voc_hot, MPPT-Parallelsummen, DC-Sicherungen), Erdung/HPA (VDE 0100-600), optionale UV PV, Normen-Checkliste, Leistungsklassen-Matrix. **Dauerhafte Referenz für alle PV-Planungen — bei Bestand-/Normänderungen hier aktualisieren.** |
| [`data/systemuebersicht/STROMLAUFPLAN_WALLBOX.md`](./data/systemuebersicht/STROMLAUFPLAN_WALLBOX.md) | **Wallbox-Stromlaufplan Netzbetreiber → Ladeeinrichtung** (IC-CPD, 3,7–22 kW): LS C-Charakteristik + **FI Typ B (Pflicht, DC-Fehlerströme des EVs)**, H07V-U-Zuleitung außen (Spannungsfall ≤ 3 %), RCD-Watchdog, Erdung/HPA, optionale Kommunikation (LAN/WLAN/OCPP) + PV-Überschussladen am Bestand-Zähler, DIN EN 62351-Prüfplan. **Dauerhafte Referenz für alle Wallbox-Planungen — bei Bestand-/Normänderungen hier aktualisieren.** |
| [`data/systemuebersicht/STROMLAUFPLAN.md`](./data/systemuebersicht/STROMLAUFPLAN.md) | **Gesamtanlage-Stromlaufplan**: kombiniert PV (8–25 kWp) + Batteriespeicher (≤ 20 kWh, AC-coupled) + Wärmepumpe (~4,36 kW) + Wallbox (7–22 kW). Ein Blockschaltbild mit einmaligen Komponenten (Zähler, Hauptschalter, HPA) und redundanten LS/FI-Stromkreisen je Anlage (R4). Erdungstabelle, DC/AC-Trennung, Kommunikation, 18-Punkte-Normen-Checkliste. **Dauerhafte Referenz für die Gesamtanlage — bei Änderungen an Teilplänen hier synchronisieren.** |

## Quick reference — common pitfalls

- **Drift companion:** Use `Value<T>` for optional fields; never pass a bare value or `Constant`.
- **`customSelect`:** The `variables:` parameter is a named argument of type `List<Variable>`, not positional.
- **Roof move drift:** Modules must be repositioned from `_moveStartModulePos` (fixed at gesture start), NOT by accumulating deltas on their current positions.
- **Canvas label z-order:** Draw roof labels in the final pass after all other objects, before `canvas.restore()`.
- **Widget test tall dialogs:** Unfocus focused fields before pumping; use `scrollUntilVisible + tapAt` for actions outside scrollable areas.
