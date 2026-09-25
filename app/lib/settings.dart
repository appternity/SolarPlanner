import 'dart:convert';
import 'dart:io';

/// Per-device app settings, persisted as JSON in the app documents folder.
///
/// [mode] is the core of the sync design:
///  * `writer` – this device edits the local working copy and publishes
///    snapshots into the sync folder (e.g. OneDrive).
///  * `reader` – this device opens the published snapshot read-only and
///    reloads it when the sync folder changes.
class AppSettings {
  static const writer = 'writer';
  static const reader = 'reader';

  final String mode;
  /// Path (Windows) or content URI (Android) of the sync folder.
  final String syncFolder;

  const AppSettings({required this.mode, required this.syncFolder});

  bool get isWriter => mode == writer;

  static File _fileFor(Directory docs) => File('${docs.path}/settings.json');

  static Future<AppSettings?> load(Directory docs) async {
    final f = _fileFor(docs);
    if (!await f.exists()) return null;
    try {
      final map = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      return AppSettings(
        mode: map['mode'] as String,
        syncFolder: map['syncFolder'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Directory docs) async {
    await _fileFor(docs).writeAsString(
      jsonEncode({'mode': mode, 'syncFolder': syncFolder}),
    );
  }
}
