# SolarPlanner (Flutter app)

A cross-platform Flutter app for planning photovoltaic roof installations.
Pick a project, draw/adjust roof sections in plan view, place solar modules on
them, group them into strings per inverter/MPPT, and review the results.

## Writer / Reader sync model

The app runs in one of two roles (chosen during first-run setup):

- **Writer** — edits the local working database
  (`solarplanner.db` in the app documents folder) and *publishes* a consistent
  snapshot into a shared sync folder (e.g. a OneDrive/Nextcloud directory).
- **Reader** — opens the latest snapshot **read-only**. It watches the sync
  folder (file watcher on desktop, polling on Android) and automatically pulls +
  reopens the database when a newer snapshot appears.

The sync folder is addressed through a small backend abstraction
(`lib/sync/`): `PathSyncBackend` for plain local paths and a SAF-based
`UriBackend` (MethodChannel `solar_planner/sync`) for Android.

## Getting started

```sh
flutter pub get
flutter run          # first launch walks through the setup flow (role + sync folder)
```

### Regenerating the database code

The Drift schema lives in `lib/db/tables.dart`; generated code is
`lib/db/database.g.dart`. After changing the schema:

```sh
dart run build_runner build --delete-conflicting-outputs
```

### Analyze & test

```sh
flutter analyze   # should report no issues
flutter test      # geometry unit tests (no platform channels)
```

## Project layout

- `lib/main.dart` — entry point; opens the DB (working copy or snapshot) and
  starts either setup or the main app.
- `lib/app.dart` — root widget; owns the DB instance so a reader can swap in a
  freshly pulled snapshot (close + reopen).
- `lib/settings.dart` — persisted role/sync-folder settings.
- `lib/db/` — Drift schema (`tables.dart`), database + queries
  (`database.dart` / `database.g.dart`), and seed data (`seed.dart`).
- `lib/core/geo.dart` — plan-view geometry (points, polygons, area, centroid).
- `lib/features/` — UI: setup flow, inventory (modules/inverters/batteries/wallboxes),
  projects list, and the roof editor (canvas + controller).
- `lib/sync/` — sync backend abstraction, path & SAF URI backends, and the
  publish/pull service.

## Notes

- Reader mode opens SQLite in read-only mode (`OpenMode.readOnly`), so a
  snapshot can never be modified by accident.
- Publishing uses `VACUUM INTO` to produce a consistent standalone copy, plus a
  small `meta.json` with version info.
