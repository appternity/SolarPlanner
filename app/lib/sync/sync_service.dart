import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../db/database.dart' as appdb;
import '../settings.dart';
import 'sync_backend.dart';

/// Implements the writer/reader snapshot sync.
///
/// Writer device:
///   * edits the local working copy (`solarplanner.db` in app documents)
///   * [publish] copies it as a consistent snapshot into the sync folder
///     (atomic replace, plus a `meta.json` with version info)
///
/// Reader device:
///   * [pullIfNewer] downloads the snapshot when it changed and replaces
///     the local read-only cache; the app reopens the database afterwards
///   * [watchChanges] emits when the sync folder changes (file watcher on
///     Windows, polling on Android)
class SyncService {
  static const snapshotName = 'solarplanner.db';
  static const metaName = 'meta.json';

  final AppSettings settings;
  final SyncBackend backend;
  final Directory docs;

  SyncService({
    required this.settings,
    required this.backend,
    required this.docs,
  });

  String get localWorkingPath => p.join(docs.path, 'solarplanner.db');
  String get localSnapshotPath => p.join(docs.path, 'snapshot.db');
  File get _lastPullFile => File(p.join(docs.path, 'last_pull.txt'));

  // ------------------------------------------------------------------
  // Writer
  // ------------------------------------------------------------------

  /// Publishes the current working database as a new snapshot.
  Future<void> publish(appdb.AppDatabase db) async {
    final tmp = File(p.join(docs.path, 'snapshot_tmp.db'));
    // VACUUM INTO produces a consistent, standalone copy of the database.
    await db.customStatement('VACUUM INTO ?', [tmp.path]);
    final bytes = await tmp.readAsBytes();
    await tmp.delete();

    await backend.writeFile(snapshotName, bytes);
    await backend.writeFile(
      metaName,
      Uint8List.fromList(
        _json(
          version: DateTime.now().millisecondsSinceEpoch,
          device: Platform.localHostname,
          size: bytes.length,
        ).codeUnits,
      ),
    );
  }

  // ------------------------------------------------------------------
  // Reader
  // ------------------------------------------------------------------

  /// Downloads the snapshot if it is newer than the last pull.
  /// Returns true when a new snapshot was fetched.
  Future<bool> pullIfNewer() async {
    final stat = await backend.statFile(snapshotName);
    if (stat == null) return false;

    var lastPull = 0;
    if (await _lastPullFile.exists()) {
      lastPull = int.tryParse(await _lastPullFile.readAsString()) ?? 0;
    }
    if (stat.modifiedMs <= lastPull) return false;

    final bytes = await backend.readFile(snapshotName);
    if (bytes == null) return false;

    // Atomic replace of the local cache file.
    final tmp = File('$localSnapshotPath.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    final target = File(localSnapshotPath);
    if (await target.exists()) await target.delete();
    await tmp.rename(target.path);
    await _lastPullFile.writeAsString('${stat.modifiedMs}');
    return true;
  }

  /// Emits whenever the remote snapshot may have changed.
  Stream<void> watchChanges() {
    if (backend is PathSyncBackend) {
      final dir = Directory((backend as PathSyncBackend).folder);
      if (!dir.existsSync()) return const Stream.empty();
      return dir.watch().map<void>((_) {});
    }
    // Android: poll the snapshot's modification time.
    return _pollEvery(const Duration(seconds: 30));
  }

  Stream<void> _pollEvery(Duration period) async* {
    var last = 0;
    while (true) {
      try {
        final stat = await backend.statFile(snapshotName);
        if (stat != null && stat.modifiedMs != last) {
          last = stat.modifiedMs;
          yield null;
        }
      } catch (_) {
        // Network/Drive not available right now – keep polling.
      }
      await Future<void>.delayed(period);
    }
  }

  String _json({required int version, required String device, required int size}) {
    return '{"version":$version,"device":"$device","size":$size,"at":"${DateTime.now().toIso8601String()}"}';
  }
}
