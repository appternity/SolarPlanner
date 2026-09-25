# Module Labels (`{roofId}.{stringId}.{moduleId}`)

## Format & semantics (all 1-based, session state only — NOT persisted)

Every placed module that belongs to a string gets an identifier shown on the canvas as white text in a semi-transparent black band along its top edge. The label is rendered **in the module's local rotated frame** so it follows panel orientation. Modules without a string get no label.

| Part | Meaning |
|------|---------|
| `roofId` | Rank of the module's roof among roofs that carry ≥1 placed module (sorted by `Roofs.id`). Empty roofs do NOT consume a rank. |
| `stringId` | `mppIndex + 1` of the module's string — i.e., the MPPT tracker number on the inverter (global per project, not per string). |
| `moduleId` | Position within that tracker: modules of all strings on the same `mppIndex` are numbered continuously (strings ordered by id, then by series `position`). |

## Rendering (`_drawModuleLabel`, `roof_canvas.dart`)

- Band height: `min(h*0.9, 13/zoom)`
- Font size: `12/zoom` (~constant ~12px on screen at any zoom)
- Shrinks to fit the module width

Only drawn when the module is ≥ ~14 px on screen (`min(w,h)*zoom >= 14`) so tiny panels don't get unreadable text.

## Regression test coverage (`editor_controller_test.dart`, group 'moduleLabels')

The tests verify:
- Correct format and uniqueness of labels across all placed modules
- Gap-free roof ranking (an empty middle roof does NOT break numbering)
- Continuous numbering across parallel strings on one MPPT tracker
- Null label for unassigned modules (no string membership)
