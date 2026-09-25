import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Abstract access to the sync folder (e.g. a OneDrive folder).
///
/// Two implementations exist because the sync folder is a real directory
/// on Windows but a SAF content URI on Android:
///  * [PathSyncBackend] – plain file I/O (Windows)
///  * [UriSyncBackend] – via the Android document API (MethodChannel)
abstract class SyncBackend {
  /// Lists file names directly inside the sync folder.
  Future<List<String>> listFiles();

  /// Reads a file, or returns null if it does not exist.
  Future<Uint8List?> readFile(String name);

  /// Creates or replaces a file.
  Future<void> writeFile(String name, List<int> bytes);

  /// Size and last-modified time, or null if the file does not exist.
  Future<FileStat?> statFile(String name);
}

class FileStat {
  final int size;
  final int modifiedMs;
  const FileStat({required this.size, required this.modifiedMs});
}

/// Plain file-system backend (Windows: the OneDrive folder is a real dir).
class PathSyncBackend implements SyncBackend {
  final String folder;

  PathSyncBackend(this.folder);

  @override
  Future<List<String>> listFiles() async {
    final dir = Directory(folder);
    if (!await dir.exists()) return [];
    return dir
        .listSync()
        .whereType<File>()
        .map((f) => p.basename(f.path))
        .toList();
  }

  @override
  Future<Uint8List?> readFile(String name) async {
    final f = File(p.join(folder, name));
    if (!await f.exists()) return null;
    return f.readAsBytes();
  }

  @override
  Future<void> writeFile(String name, List<int> bytes) async {
    final f = File(p.join(folder, name));
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<FileStat?> statFile(String name) async {
    final f = File(p.join(folder, name));
    if (!await f.exists()) return null;
    final st = await f.stat();
    return FileStat(
      size: st.size,
      modifiedMs: st.modified.millisecondsSinceEpoch,
    );
  }
}
