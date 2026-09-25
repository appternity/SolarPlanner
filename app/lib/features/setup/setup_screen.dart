import 'dart:io';

import 'package:android_file_picker/android_file_picker.dart'
    show
        AndroidSAFAccessMode,
        AndroidSAFGrant,
        AndroidSAFOptions,
        FilePickerAndroidOptions;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../settings.dart';

/// First-start wizard: choose writer/reader mode and the sync folder
/// (e.g. a folder inside OneDrive).
class SetupFlow extends StatefulWidget {
  final Directory docs;
  final Future<void> Function(AppSettings) onDone;

  const SetupFlow({super.key, required this.docs, required this.onDone});

  @override
  State<SetupFlow> createState() => _SetupFlowState();
}

class _SetupFlowState extends State<SetupFlow> {
  String _mode = AppSettings.writer;
  String? _syncFolder;
  bool _picking = false;

  Future<void> _pickFolder() async {
    setState(() => _picking = true);
    try {
      // On Android we request a SAF tree URI (content://…) with a persistent
      // read/write grant so the sync backend can access the folder later.
      // On Windows this simply returns the real directory path.
      final path = await FilePicker.getDirectoryPath(
        initialDirectory: _syncFolder,
        dialogTitle: 'Sync-Ordner wählen (z. B. in OneDrive)',
        androidOptions: const FilePickerAndroidOptions(
          safOptions: AndroidSAFOptions(
            grant: AndroidSAFGrant.lifetime,
            accessMode: AndroidSAFAccessMode.readWrite,
          ),
        ),
      );
      if (path != null && path.isNotEmpty) {
        setState(() => _syncFolder = path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Ordner konnte nicht gewählt werden: $e')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _start() async {
    if (_syncFolder == null || _syncFolder!.isEmpty) return;
    final settings = AppSettings(mode: _mode, syncFolder: _syncFolder!);
    await settings.save(widget.docs);
    await widget.onDone(settings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solarplaner Einrichtung',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00695C),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Willkommen beim Solarplaner')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Dieses Gerät arbeitet in einem von zwei Modi:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: AppSettings.writer,
                      icon: Icon(Icons.edit),
                      label: Text('Schreiber'),
                    ),
                    ButtonSegment(
                      value: AppSettings.reader,
                      icon: Icon(Icons.visibility),
                      label: Text('Leser'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) =>
                      setState(() => _mode = s.first),
                ),
                const SizedBox(height: 8),
                Text(
                  _mode == AppSettings.writer
                      ? 'Auf diesem Gerät können Daten bearbeitet werden. Änderungen werden als Snapshots in den Sync-Ordner veröffentlicht.'
                      : 'Dieses Gerät zeigt den veröffentlichten Snapshot schreibgeschützt an und aktualisiert sich, wenn der Schreiber veröffentlicht.',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text('Sync-Ordner',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _picking ? null : _pickFolder,
                        child: _picking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Ordner wählen …'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _syncFolder ?? 'Kein Ordner gewählt',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed:
                      (_syncFolder != null && _syncFolder!.isNotEmpty)
                          ? _start
                          : null,
                  child: const Text('Loslegen'),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
