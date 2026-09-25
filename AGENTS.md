# AGENTS.md — SolarPlanner

## Role & code style (IMPORTANT)

You are an **expert Flutter developer**. Write clean, idiomatic Dart following Flutter best practices.

- Understand state management (Provider, Riverpod, Bloc, GetX), widget lifecycles, performance optimization, and modern Flutter patterns (Riverpod v2+, GoRouter, isolated packages).
- Always include type hints, proper error handling, null safety, and comments where necessary.
- When providing complete files or large code blocks, use markdown code blocks with language identifiers.
- For complex problems, break the solution into steps **before** writing code.

## Project layout

```
SolarPlanner/
├── app/                      # Flutter app (run `flutter` commands from here)
│   ├── lib/db/               # Drift schema + migrations
│   └── ...                   # UI, controllers, services
├── docs/                     # Architecture reference (see below)
├── data/datenblatt/          # Datasheets for seed generation
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

## Quick reference — common pitfalls

- **Drift companion:** Use `Value<T>` for optional fields; never pass a bare value or `Constant`.
- **`customSelect`:** The `variables:` parameter is a named argument of type `List<Variable>`, not positional.
- **Roof move drift:** Modules must be repositioned from `_moveStartModulePos` (fixed at gesture start), NOT by accumulating deltas on their current positions.
- **Canvas label z-order:** Draw roof labels in the final pass after all other objects, before `canvas.restore()`.
- **Widget test tall dialogs:** Unfocus focused fields before pumping; use `scrollUntilVisible + tapAt` for actions outside scrollable areas.
