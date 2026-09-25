import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../db/database.dart';

/// List of planning projects.
class ProjectsScreen extends StatefulWidget {
  final AppDatabase db;
  final bool readOnly;
  final void Function(int projectId, String name) onOpenProject;

  const ProjectsScreen({
    super.key,
    required this.db,
    required this.onOpenProject,
    this.readOnly = false,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projekte')),
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: _createProject,
              icon: const Icon(Icons.add),
              label: const Text('Neues Projekt'),
            ),
      body: StreamBuilder<List<Project>>(
        stream: widget.db.watchProjects(),
        builder: (context, snap) {
          final projects = snap.data ?? [];
          if (projects.isEmpty) {
            return const Center(
              child: Text('Noch keine Projekte – „Neues Projekt“ tippen.',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView(
            children: [
              for (final p in projects)
                ListTile(
                  leading: const Icon(Icons.home_work_outlined),
                  title: Text(p.name),
                  subtitle: Text(
                    p.address.isEmpty
                        ? 'Keine Adresse'
                        : p.address,
                  ),
                  isThreeLine: false,
                  onTap: () =>
                      widget.onOpenProject(p.id, p.name),
                  trailing: widget.readOnly
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteProject(p),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createProject() async {
    final name = await _promptText(
      context,
      'Neues Projekt',
      'Projektname',
    );
    if (name == null || name.isEmpty) return;
    if (!mounted) return;

    final address = await _promptText(
      context,
      'Neues Projekt',
      'Adresse (optional)',
    ) ??
        '';

    final now = DateTime.now().millisecondsSinceEpoch;
    await widget.db
        .into(widget.db.projects)
        .insert(ProjectsCompanion.insert(
          name: name,
          address: Value(address),
          createdAt: now,
          updatedAt: now,
        ));
  }

  Future<void> _deleteProject(Project p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('„${p.name}“ löschen?'),
        content: const Text(
            'Das Projekt und alle zugehörigen Dächer, Module und Strings werden entfernt.'),
        actions: [
          TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(false)),
          FilledButton(
              child: const Text('Löschen'),
              onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (ok != true) return;

    // Delete dependent rows, then the project itself.
    final roofs = await widget.db.roofsOf(p.id);
    for (final r in roofs) {
      await (widget.db.delete(widget.db.placedModules)
            ..where((t) => t.roofId.equals(r.id)))
          .go();
      await (widget.db.delete(widget.db.roofs)..where((t) => t.id.equals(r.id)))
          .go();
    }
    final strings = await widget.db.stringsOf(p.id);
    for (final s in strings) {
      await (widget.db.delete(widget.db.stringModules)
            ..where((t) => t.stringId.equals(s.id)))
          .go();
    }
    await (widget.db.delete(widget.db.moduleStrings)
          ..where((t) => t.projectId.equals(p.id)))
        .go();
    await (widget.db.delete(widget.db.obstacles)
          ..where((t) => t.projectId.equals(p.id)))
        .go();
    await (widget.db.delete(widget.db.projects)
          ..where((t) => t.id.equals(p.id)))
        .go();
  }

  Future<String?> _promptText(
      BuildContext context, String title, String label) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(ctx).pop()),
          FilledButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(controller.text)),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
