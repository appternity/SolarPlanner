import 'package:flutter/services.dart';

import 'sync_backend.dart';

/// Android backend: the sync folder is a SAF content URI
/// (e.g. a folder inside the OneDrive or Google Drive app).
///
/// File operations are delegated to the native document API via a
/// MethodChannel (see `MainActivity.kt`). The channel contract mirrors the
/// Kotlin side: `parent`/`dir`/`uri` keys, raw byte arrays for read/write,
/// and a `{size, mtime}` map for `statFile`.
class UriSyncBackend implements SyncBackend {
  static const MethodChannel _channel = MethodChannel('solar_planner/sync');

  final String treeUri;

  UriSyncBackend(this.treeUri);

  Future<String?> _resolveChild(String name) async {
    return _channel.invokeMethod<String>('resolveChild', {
      'parent': treeUri,
      'name': name,
    });
  }

  @override
  Future<List<String>> listFiles() async {
    final names = await _channel.invokeMethod<List>('listFiles', {
      'dir': treeUri,
    });
    return names?.cast<String>().toList() ?? [];
  }

  @override
  Future<Uint8List?> readFile(String name) async {
    final uri = await _resolveChild(name);
    if (uri == null) return null;
    final bytes = await _channel.invokeMethod<List<int>>('readFile', {
      'uri': uri,
    });
    if (bytes == null) return null;
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> writeFile(String name, List<int> bytes) async {
    var uri = await _resolveChild(name);
    uri ??= await _channel.invokeMethod<String>('createFile', {
      'parent': treeUri,
      'name': name,
      'mimeType': 'application/octet-stream',
    });
    if (uri == null) {
      throw StateError('Could not create file "$name" in sync folder');
    }
    // Send a Uint8List so the standard codec encodes it as a byte array,
    // which the Kotlin side decodes as a ByteArray.
    await _channel.invokeMethod('writeFile', {
      'uri': uri,
      'data': Uint8List.fromList(bytes),
    });
  }

  @override
  Future<FileStat?> statFile(String name) async {
    final uri = await _resolveChild(name);
    if (uri == null) return null;
    final result = await _channel.invokeMethod<Map>('statFile', {
      'uri': uri,
    });
    if (result == null) return null;
    final size = result['size'];
    final mtime = result['mtime'];
    if (size == null || mtime == null) return null;
    return FileStat(
      size: (size as num).toInt(),
      modifiedMs: (mtime as num).toInt(),
    );
  }
}

/// Creates the backend appropriate for the given sync folder location.
SyncBackend createSyncBackend(String syncFolder) {
  if (syncFolder.startsWith('content://')) {
    return UriSyncBackend(syncFolder);
  }
  return PathSyncBackend(syncFolder);
}
