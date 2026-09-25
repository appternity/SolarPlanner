import 'dart:async';

import 'package:flutter/material.dart';

import 'db/database.dart';
import 'features/editor/editor_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/projects/projects_screen.dart';
import 'settings.dart';
import 'sync/sync_service.dart';

/// Root widget of the application.
///
/// Owns the [AppDatabase] instance so that, in reader mode, a freshly pulled
/// snapshot can be swapped in (close + reopen) without rebuilding the whole
/// widget tree from [main]. The shell's publish/refresh buttons call back into
/// this state so there is a single code path for both.
class SolarPlannerApp extends StatefulWidget {
  final AppSettings settings;
  final AppDatabase db;
  final SyncService sync;

  const SolarPlannerApp({
    super.key,
    required this.settings,
    required this.db,
    required this.sync,
  });

  @override
  State<SolarPlannerApp> createState() => _SolarPlannerAppState();
}

class _SolarPlannerAppState extends State<SolarPlannerApp> {
  int _page = 0;

  /// The currently open database. In reader mode this is replaced (close +
  /// reopen) whenever a newer snapshot is pulled.
  late AppDatabase _db;

  StreamSubscription? _watchSub;

  @override
  void initState() {
    super.initState();
    _db = widget.db;

    // Reader: automatically pick up new snapshots and swap the DB in.
    if (!widget.settings.isWriter) {
      _watchSub = widget.sync.watchChanges().listen((_) => refresh());
    }
  }

  @override
  void dispose() {
    _watchSub?.cancel();
    super.dispose();
  }

  /// Writer: publish the working database as a new snapshot.
  Future<void> publish() async {
    await widget.sync.publish(_db);
  }

  /// Reader: pull a newer snapshot and, if one was fetched, close the current
  /// database and reopen it read-only so every stream observes the new data.
  Future<bool> refresh() async {
    final sync = widget.sync;
    try {
      final changed = await sync.pullIfNewer();
      if (!changed) return false;

      // Swap in the fresh snapshot. Close first so no connection is left
      // pointing at the replaced file, then reopen read-only.
      await _db.close();
      final fresh = AppDatabase.open(sync.localSnapshotPath, readOnly: true);
      if (!mounted) {
        // App was torn down mid-refresh; don't leak the new connection.
        await fresh.close();
        return true;
      }
      setState(() => _db = fresh);
      return true;
    } catch (_) {
      // A failed pull leaves the previous (still valid) DB in place. If the
      // connection was already closed during a partial failure, reopen it so
      // the UI keeps working.
      if (!mounted) return false;
      try {
        final reopened = AppDatabase.open(sync.localSnapshotPath, readOnly: true);
        setState(() => _db = reopened);
      } catch (_) {
        // Nothing sensible to do; keep whatever we have.
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solarplaner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00695C),
        useMaterial3: true,
      ),
      home: _Shell(
        settings: widget.settings,
        db: _db,
        page: _page,
        onNavigate: (i) => setState(() => _page = i),
        onPublish: publish,
        onRefresh: refresh,
      ),
    );
  }
}

class _Shell extends StatefulWidget {
  final AppSettings settings;
  final AppDatabase db;
  final int page;
  final ValueChanged<int> onNavigate;
  final Future<void> Function() onPublish;
  final Future<bool> Function() onRefresh;
  const _Shell({
    required this.settings,
    required this.db,
    required this.page,
    required this.onNavigate,
    required this.onPublish,
    required this.onRefresh,
  });

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  bool _busy = false;

  Future<void> _run(Future Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 900;

    final body = widget.page == 0
        ? InventoryScreen(db: widget.db, readOnly: !widget.settings.isWriter)
        : ProjectsScreen(
            db: widget.db,
            onOpenProject: _openProject,
          );

    final actions = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Chip(
          avatar: Icon(
            widget.settings.isWriter ? Icons.cloud_upload : Icons.cloud_download,
            size: 18,
          ),
          label: Text(widget.settings.isWriter ? 'Schreiber' : 'Leser'),
        ),
      ),
      if (widget.settings.isWriter)
        IconButton(
          icon: const Icon(Icons.cloud_upload_outlined),
          tooltip: 'Snapshot in Sync-Ordner veröffentlichen',
          onPressed: _busy ? null : () => _run(_publishWithStatus),
        )
      else
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Auf neuen Snapshot prüfen',
          onPressed: _busy ? null : () => _run(_refreshWithStatus),
        ),
      const SizedBox(width: 8),
    ];

    if (isWide) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Solarplaner'),
          actions: actions,
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: widget.page,
              onDestinationSelected: (i) => widget.onNavigate(i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: Text('Inventar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: Text('Projekte'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solarplaner'),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.page,
        onDestinationSelected: (i) => widget.onNavigate(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventar',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projekte',
          ),
        ],
      ),
    );
  }

  void _openProject(int id, String name) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          db: widget.db,
          projectId: id,
          projectName: name,
          readOnly: !widget.settings.isWriter,
        ),
      ),
    );
  }

  Future<void> _publishWithStatus() async {
    try {
      await widget.onPublish();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Snapshot in Sync-Ordner veröffentlicht')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veröffentlichen fehlgeschlagen: $e')),
        );
      }
    }
  }

  Future<void> _refreshWithStatus() async {
    final changed = await widget.onRefresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(changed ? 'Neuer Snapshot geladen' : 'Bereits aktuell')),
      );
    }
  }
}
