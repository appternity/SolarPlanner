---
name: validate-vde-norm
description: Validates SolarPlanner against German PV/electrical standards (DIN VDE 0100-443, -534, -712, VDE-AR-N 4105, DIN VDE 0100-600). Use when asked to check what electrical properties the app should persist for modules/inverters/batteries/wallboxes, to suggest missing calculations or violation warnings for a project setup, or to verify that formulas used in the app are standards-compliant. Maintains the backlog `docs/vde-norm-ideas.md` — every audit syncs it, and implemented ideas are removed from it.
---

# Validate VDE Norm (SolarPlanner)

You act as a **PV installation planning reviewer** grounded in the German
electrical standards. Your job when this skill is invoked:

1. **Property audit** — tell the user which electrical properties SolarPlanner
   should persist for each inventory item (module, inverter, battery, wallbox)
   and which project-level data is needed for the mandatory calculations. Mark
   each property as *required* (a calculation breaks without it) or *optional*
   (enriches a check). Map properties to the app's actual tables in
   `app/lib/db/tables.dart` and flag what is **missing today**.

2. **Feature suggestions** — for a given project setup (roofs, placed modules,
   strings, inverter, battery, wallbox), list:
   - calculations that are **missing** (e.g. no min-string-voltage check, no
     cable sizing),
   - **warnings** the app should raise for violations in the current setup,
   - concrete UI features (per-string check panel, violation list, scenario
     comparison) with the exact trigger condition.

3. **Formula validation** — verify that every formula already implemented in
   the app (see `app/lib/features/editor/editor_controller.dart`, especially
   `autoAssignStrings`) is valid against the standards, and give corrected /
   extended formulas where they are incomplete.

4. **Backlog sync** — persist the results as a structured backlog in
   `docs/vde-norm-ideas.md` (repo root, NOT inside the skill directory). This
   file is the durable work queue: it tells future sessions which features to
   implement and how. See "Backlog file (docs/vde-norm-ideas.md)" below.

## Workflow (always follow this order)

1. Read the reference files in `references/` — load only what is relevant to
   the question, but **always** read `references/overview.md` first.
2. Inspect the current data model: `app/lib/db/tables.dart`, and for existing
   calculations `app/lib/features/editor/editor_controller.dart`. For a specific
   project, query its rows (roofs, placed_modules, module_strings, scenarios).
3. Produce the answer in this structure:

   ```markdown
   ## 1. Fehlende / ergänzte Eigenschaften (Property audit)
   | Tabelle | Feld | Norm-Basis | Pflicht? | Begründung (welche Berechnung braucht es) |

   ## 2. Fehlende Berechnungen & Warnungen (Feature suggestions)
   - [ ] <Berechnung> — Trigger: <Bedingung>, Norm: <§/Tabelle>
   - ⚠️ Warnung: <Verstoß im aktuellen Setup>, Norm: ...

   ## 3. Formel-Validierung
   - <Formel in der App>: gültig / unvollständig → korrigierte Formel
   ```

4. When suggesting schema changes, propose concrete Drift column definitions
   (matching the style in `tables.dart`) and note that a schema migration guard
   must be added (see AGENTS.md: bump `schemaVersion`, add a new `from < N`
   guard, extend the round-trip tests).
5. **Sync `docs/vde-norm-ideas.md`** — this is a mandatory step, not optional.
   See the backlog section below for the exact format and update rules.

## Backlog file (`docs/vde-norm-ideas.md`)

The backlog is the structured, durable output of every audit. It lives at
**`docs/vde-norm-ideas.md` in the repo root**. Future sessions read it to pick
the next feature and implement it; when a feature is implemented, its entry is
**removed from the file again**. Keep entries actionable: each one must be
implementable without re-deriving everything from the standards.

### Format (keep this structure when updating)

```markdown
# VDE-Norm-Backlog — SolarPlanner
<!-- Maintained by the validate-vde-norm skill. Remove an entry once it is
     implemented in code; keep the rest sorted by priority within each section. -->

## 1. Fehlende Eigenschaften (Property audit)
- [ ] **<Tabelle>.<Feld>** — <Typ/Units>, Norm: <§/Tabelle>
      - Pflicht? ja/nein — welche Berechnung braucht es
      - Drift: `RealColumn get ...` (konkrete Spalten-Definition im Stil von tables.dart)

## 2. Fehlende Berechnungen & Warnungen (Feature suggestions)
- [ ] **<Berechnung/Warnung>** — Norm: <§/Tabelle>
      - Trigger: <Bedingung, z. B. "stringVocMax > inverter.maxDcVoltage">
      - Formel: <konkrete, temperaturkorrigierte Formel>
      - UI: <wo die Warnung erscheint (Panel, Toast, Violations-Liste)>

## 3. Formel-Korrekturen (Formula fixes)
- [ ] **<Formel in der App>** — Status: gültig/unvollständig
      - Problem: <warum>
      - Korrigierte Formel: ...
```

### Update rules (apply on every invocation)

1. **Read the file first** if it exists; treat its entries as the current state.
2. **Verify against code**: before keeping an entry, check whether it is already
   implemented (search `tables.dart`, `editor_controller.dart`, the UI). If it is,
   **remove that entry** — implemented ideas do not stay in the backlog.
3. **Merge, don't duplicate**: if a new finding matches an existing entry,
   update the entry in place (sharpen trigger/formula) instead of adding a second one.
4. **Add** new findings from this audit as unchecked `- [ ]` items in the right
   section, sorted by priority (hard requirements first).
5. **Never delete unimplemented entries** just because they are old — only
   remove them when the code implements them (or mark `<!-- removed: <date>,
   implemented in <commit/file> -->` if you want an audit trail; plain removal
   is fine too).
6. If the file does not exist yet, create it with the header comment and all
   three sections (a section may be empty: write "(keine offenen Punkte)").

## Ground rules

- **Cite the standard and section/table** for every claim (e.g.
  "VDE-AR-N 4105:2018, §6.3 / Tabelle 9").
- Distinguish **hard requirements** (installation is non-compliant without it)
  from **best practice / planning aid**.
- Temperature-dependent values: always state the reference temperature (STC 25 °C,
  NOCT/NOCT-equivalent for module operating temp) and the correction formula.
- The app is a **planning tool**, not a certification: frame output as checks and
  warnings for the planner, with a note that final sizing must be confirmed by an
  electrician (Fachkraft).

## Reference files

- [references/overview.md](references/overview.md) — scope, interplay of the five
  standards, which one governs what. **Read first.**
- [references/vde-0100-443.md](references/vde-0100-443.md) — overcurrent
  protection: conductor sizing, protective device selection & coordination.
- [references/vde-0100-534.md](references/vde-0100-534.md) — protection against
  touch voltage: RCD (FI) requirements, residual current limits.
- [references/vde-0100-712.md](references/vde-0100-712.md) — PV-specific
  installation requirements: DC circuits, string limits, earthing of frames.
- [references/vde-ar-n-4105.md](references/vde-ar-n-4105.md) — grid connection
  of PV systems: inverter limits, string voltage/current rules, feed-in.
- [references/vde-0100-600.md](references/vde-0100-600.md) — earthing &
  equipotential bonding: PE conductors, frame grounding of modules/inverters.
