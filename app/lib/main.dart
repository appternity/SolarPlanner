import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'db/database.dart';
import 'db/seed.dart';
import 'features/setup/setup_screen.dart';
import 'settings.dart';
import 'sync/sync_service.dart';
import 'sync/uri_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final docs = await getApplicationDocumentsDirectory();
  final settings = await AppSettings.load(docs);
  if (settings == null) {
    runApp(SetupFlow(
      docs: docs,
      onDone: (s) => _start(s, docs),
    ));
    return;
  }
  await _start(settings, docs);
}

Future<void> _start(AppSettings settings, Directory docs) async {
  final sync = SyncService(
    settings: settings,
    backend: createSyncBackend(settings.syncFolder),
    docs: docs,
  );

  late final AppDatabase db;
  if (settings.isWriter) {
    db = AppDatabase.open(sync.localWorkingPath);
    // Force the (lazy) open so migrations run before we seed.
    await db.select(db.projects).get();
    await seedIfEmpty(db);
  } else {
    // Reader: make sure a local snapshot copy exists, then open it
    // read-only. If the writer has published something newer, pull it.
    if (!File(sync.localSnapshotPath).existsSync()) {
      final tmp = AppDatabase.open(sync.localSnapshotPath);
      await tmp.select(tmp.projects).get();
      await tmp.close();
    }
    await sync.pullIfNewer();
    db = AppDatabase.open(sync.localSnapshotPath, readOnly: true);
  }

  runApp(SolarPlannerApp(settings: settings, db: db, sync: sync));
}
