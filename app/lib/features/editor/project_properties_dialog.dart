// drift's `Column` collides with Flutter's, so only import what we need.
import 'package:flutter/material.dart';

import '../../db/database.dart';
import '../editor/editor_controller.dart' show EditorController;

/// Result of the project-properties dialog: every field that still lives in
/// the editor's "Projekt" tab (identity, site coordinates and household /
/// planning parameters). System-specific fields were moved to the individual
/// system tabs (PV / Batteriespeicher / Wallbox / Wärmepumpe).
///
class ProjectPropertiesResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;


  // Haushalt (komponenten.md §1).
  final int personen;
  final int etagen;
  final bool keller;
  final int baeder;
  final int kuechen;

  const ProjectPropertiesResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,

    required this.personen,
    required this.etagen,
    required this.keller,
    required this.baeder,
    required this.kuechen,
  });

  /// Applies [result] to the project via one batched controller write.
  static Future<void> apply(
      EditorController c, ProjectPropertiesResult result) {
    return c.updateProjectProperties(
      name: result.name,
      address: result.address,
      latitude: result.latitude,
      longitude: result.longitude,

      personen: result.personen,
      etagen: result.etagen,
      keller: result.keller,
      baeder: result.baeder,
      kuechen: result.kuechen,
    );
  }
}

/// Opens the project-properties dialog prefilled from [project]. Returns null
/// when cancelled. The name must not be empty to confirm.
Future<ProjectPropertiesResult?> showProjectPropertiesDialog(
    BuildContext context, Project project) {
  return showDialog<ProjectPropertiesResult>(
    context: context,
    builder: (ctx) => _ProjectPropertiesDialog(project: project),
  );
}

class _ProjectPropertiesDialog extends StatefulWidget {
  final Project project;

  const _ProjectPropertiesDialog({required this.project});

  @override
  State<_ProjectPropertiesDialog> createState() => _ProjectPropertiesState();
}

class _ProjectPropertiesState extends State<_ProjectPropertiesDialog> {
  // Text fields.
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _lat;
  late final TextEditingController _lon;
  // Numeric/integer text fields (parsed on confirm, fall back to previous
  // value). System-specific numeric fields live in the system tabs now.

  late final TextEditingController _personen;
  late final TextEditingController _etagen;
  late final TextEditingController _baeder;
  late final TextEditingController _kuechen;

  // Switch (system toggles and site conditions live in the Projekt tab).
  bool _keller = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;

    _name = TextEditingController(text: p.name);
    _address = TextEditingController(text: p.address);
    _lat = TextEditingController(text: p.latitude.toStringAsFixed(4));
    _lon = TextEditingController(text: p.longitude.toStringAsFixed(4));
    _personen = TextEditingController(text: p.personen.toString());
    _etagen = TextEditingController(text: p.etagen.toString());
    _baeder = TextEditingController(text: p.baeder.toString());
    _kuechen = TextEditingController(text: p.kuechen.toString());

    _keller = p.keller;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _address,
      _lat,
      _lon,
      _personen,
      _etagen,
      _baeder,
      _kuechen,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Parses a decimal field (German comma accepted); falls back to [fallback]
  /// when the text is empty or invalid so a half-cleared field never stores
  /// garbage.
  double _num(TextEditingController c, double fallback) {
    final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
    return (v == null || !v.isFinite) ? fallback : v;
  }

  int _int(TextEditingController c, int fallback) =>
      int.tryParse(c.text.trim()) ?? fallback;

  void _confirm() {
    final p = widget.project;
    Navigator.of(context).pop(ProjectPropertiesResult(
      name: _name.text.trim(),
      address: _address.text.trim(),
      latitude: _num(_lat, p.latitude),
      longitude: _num(_lon, p.longitude),
      personen: _int(_personen, p.personen),
      etagen: _int(_etagen, p.etagen),
      keller: _keller,
      baeder: _int(_baeder, p.baeder),
      kuechen: _int(_kuechen, p.kuechen),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Projekt-Eigenschaften'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Section('Allgemein'),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Projektname'),
              ),
              TextField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Adresse'),
              ),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _lat,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Breitengrad'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lon,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Längengrad'),
                  ),
                ),
              ]),

              _Section('Haushalt'),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _personen,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Personen'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _etagen,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Etagen'),
                  ),
                ),
              ]),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _baeder,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bäder'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _kuechen,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Küchen'),
                  ),
                ),
              ]),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Keller'),
                value: _keller,
                onChanged: (v) => setState(() => _keller = v),
              ),            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen')),
        FilledButton(
          // The name is required; disable saving while it is empty.
          onPressed: _name.text.trim().isEmpty ? null : _confirm,
          child: const Text('Speichern'),
        ),
      ],
    );
  }

  // Keep the build method's access to [_name] alive for the onPressed closure
  // (lint: unused field would otherwise fire on _confirm-only usage).
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
