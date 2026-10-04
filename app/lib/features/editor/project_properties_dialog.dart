// drift's `Column` collides with Flutter's, so only import what we need.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../db/database.dart';
import '../editor/editor_controller.dart' show EditorController;

/// Result of the project-properties dialog: every field the user may change
/// for an existing project (identity, site coordinates and household /
/// planning parameters). [maxFeedInKw] is a `Value` so that "not specified"
/// (empty field) can be distinguished from the previous value.
class ProjectPropertiesResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int gridPhases;
  final Value<double?> maxFeedInKw;
  final bool hasMainEquipotential;
  final bool isBoltedMounting;

  // Haushalt (komponenten.md §1).
  final int personen;
  final int etagen;
  final bool keller;
  final int baeder;
  final int kuechen;

  // PV.
  final bool pvAnlage;
  final double pvKwp;

  // Batteriespeicher.
  final bool batAnlage;
  final double batKwh;
  final int batUnits;
  final double batDcA;
  final double batAcKw;
  final bool batAussen;

  // Wallbox.
  final bool wbAnlage;
  final double wbKw;
  final bool wbAussen;
  final bool wbKomm;
  final bool wbUeberschuss;
  final bool bza;
  final int wbLeitungM;

  // Wärmepumpe.
  final bool wpAnlage;
  final double wpKw;
  final int fbhZonen;
  final bool radiatoren;
  final bool garten;
  final int hwSchleifeM;

  const ProjectPropertiesResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.gridPhases,
    required this.maxFeedInKw,
    required this.hasMainEquipotential,
    required this.isBoltedMounting,
    required this.personen,
    required this.etagen,
    required this.keller,
    required this.baeder,
    required this.kuechen,
    required this.pvAnlage,
    required this.pvKwp,
    required this.batAnlage,
    required this.batKwh,
    required this.batUnits,
    required this.batDcA,
    required this.batAcKw,
    required this.batAussen,
    required this.wbAnlage,
    required this.wbKw,
    required this.wbAussen,
    required this.wbKomm,
    required this.wbUeberschuss,
    required this.bza,
    required this.wbLeitungM,
    required this.wpAnlage,
    required this.wpKw,
    required this.fbhZonen,
    required this.radiatoren,
    required this.garten,
    required this.hwSchleifeM,
  });

  /// Applies [result] to the project via one batched controller write.
  static Future<void> apply(
      EditorController c, ProjectPropertiesResult result) {
    return c.updateProjectProperties(
      name: result.name,
      address: result.address,
      latitude: result.latitude,
      longitude: result.longitude,
      gridPhases: result.gridPhases,
      maxFeedInKw: result.maxFeedInKw,
      hasMainEquipotential: result.hasMainEquipotential,
      isBoltedMounting: result.isBoltedMounting,
      personen: result.personen,
      etagen: result.etagen,
      keller: result.keller,
      baeder: result.baeder,
      kuechen: result.kuechen,
      pvAnlage: result.pvAnlage,
      pvKwp: result.pvKwp,
      batAnlage: result.batAnlage,
      batKwh: result.batKwh,
      batUnits: result.batUnits,
      batDcA: result.batDcA,
      batAcKw: result.batAcKw,
      batAussen: result.batAussen,
      wbAnlage: result.wbAnlage,
      wbKw: result.wbKw,
      wbAussen: result.wbAussen,
      wbKomm: result.wbKomm,
      wbUeberschuss: result.wbUeberschuss,
      bza: result.bza,
      wbLeitungM: result.wbLeitungM,
      wpAnlage: result.wpAnlage,
      wpKw: result.wpKw,
      fbhZonen: result.fbhZonen,
      radiatoren: result.radiatoren,
      garten: result.garten,
      hwSchleifeM: result.hwSchleifeM,
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
  late final TextEditingController _feedIn;

  // Numeric text fields (parsed on confirm, fall back to previous value).
  late final TextEditingController _pvKwp;
  late final TextEditingController _batKwh;
  late final TextEditingController _batDcA;
  late final TextEditingController _batAcKw;
  late final TextEditingController _wbKw;
  late final TextEditingController _wpKw;

  // Integer text fields.
  late final TextEditingController _personen;
  late final TextEditingController _etagen;
  late final TextEditingController _baeder;
  late final TextEditingController _kuechen;
  late final TextEditingController _batUnits;
  late final TextEditingController _wbLeitungM;
  late final TextEditingController _fbhZonen;
  late final TextEditingController _hwSchleifeM;

  // Switches.
  bool _keller = false,
      _hasHpa = false,
      _isBolted = true,
      _pvAnlage = false,
      _batAnlage = false,
      _batAussen = true,
      _wbAnlage = false,
      _wbAussen = true,
      _wbKomm = true,
      _wbUeberschuss = false,
      _bza = false,
      _wpAnlage = false,
      _radiatoren = false,
      _garten = true;

  int? _gridPhasesValue;

  @override
  void initState() {
    super.initState();
    final p = widget.project;

    _name = TextEditingController(text: p.name);
    _address = TextEditingController(text: p.address);
    _lat = TextEditingController(text: p.latitude.toStringAsFixed(4));
    _lon = TextEditingController(text: p.longitude.toStringAsFixed(4));
    _feedIn =
        TextEditingController(text: p.maxFeedInKw?.toStringAsFixed(1) ?? '');

    _pvKwp = TextEditingController(text: p.pvKwp.toStringAsFixed(1));
    _batKwh = TextEditingController(text: p.batKwh.toStringAsFixed(1));
    _batDcA = TextEditingController(text: p.batDcA.toStringAsFixed(0));
    _batAcKw = TextEditingController(text: p.batAcKw.toStringAsFixed(1));
    _wbKw = TextEditingController(text: p.wbKw.toStringAsFixed(1));
    _wpKw = TextEditingController(text: p.wpKw.toStringAsFixed(1));

    _personen = TextEditingController(text: p.personen.toString());
    _etagen = TextEditingController(text: p.etagen.toString());
    _baeder = TextEditingController(text: p.baeder.toString());
    _kuechen = TextEditingController(text: p.kuechen.toString());
    _batUnits = TextEditingController(text: p.batUnits.toString());
    _wbLeitungM = TextEditingController(text: p.wbLeitungM.toString());
    _fbhZonen = TextEditingController(text: p.fbhZonen.toString());
    _hwSchleifeM = TextEditingController(text: p.hwSchleifeM.toString());

    _keller = p.keller;
    _hasHpa = p.hasMainEquipotential;
    _isBolted = p.isBoltedMounting;
    _pvAnlage = p.pvAnlage;
    _batAnlage = p.batAnlage;
    _batAussen = p.batAussen;
    _wbAnlage = p.wbAnlage;
    _wbAussen = p.wbAussen;
    _wbKomm = p.wbKomm;
    _wbUeberschuss = p.wbUeberschuss;
    _bza = p.bza;
    _wpAnlage = p.wpAnlage;
    _radiatoren = p.radiatoren;
    _garten = p.garten;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _address,
      _lat,
      _lon,
      _feedIn,
      _pvKwp,
      _batKwh,
      _batDcA,
      _batAcKw,
      _wbKw,
      _wpKw,
      _personen,
      _etagen,
      _baeder,
      _kuechen,
      _batUnits,
      _wbLeitungM,
      _fbhZonen,
      _hwSchleifeM,
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
      gridPhases: _gridPhasesValue ?? p.gridPhases,
      maxFeedInKw: Value(
          _feedIn.text.trim().isEmpty ? null : _num(_feedIn, 0.0)),
      hasMainEquipotential: _hasHpa,
      isBoltedMounting: _isBolted,
      personen: _int(_personen, p.personen),
      etagen: _int(_etagen, p.etagen),
      keller: _keller,
      baeder: _int(_baeder, p.baeder),
      kuechen: _int(_kuechen, p.kuechen),
      pvAnlage: _pvAnlage,
      pvKwp: _num(_pvKwp, p.pvKwp),
      batAnlage: _batAnlage,
      batKwh: _num(_batKwh, p.batKwh),
      batUnits: _int(_batUnits, p.batUnits),
      batDcA: _num(_batDcA, p.batDcA),
      batAcKw: _num(_batAcKw, p.batAcKw),
      batAussen: _batAussen,
      wbAnlage: _wbAnlage,
      wbKw: _num(_wbKw, p.wbKw),
      wbAussen: _wbAussen,
      wbKomm: _wbKomm,
      wbUeberschuss: _wbUeberschuss,
      bza: _bza,
      wbLeitungM: _int(_wbLeitungM, p.wbLeitungM),
      wpAnlage: _wpAnlage,
      wpKw: _num(_wpKw, p.wpKw),
      fbhZonen: _int(_fbhZonen, p.fbhZonen),
      radiatoren: _radiatoren,
      garten: _garten,
      hwSchleifeM: _int(_hwSchleifeM, p.hwSchleifeM),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
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

              _Section('Standort & Netz'),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: p.gridPhases,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('EINPHASIG')),
                      DropdownMenuItem(value: 3, child: Text('DREIPHASIG')),
                    ],
                    onChanged: (v) => setState(() => _gridPhasesValue = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _feedIn,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Max. Einspeisung (kW)'),
                  ),
                ),
              ]),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Haupt-Potenzialausgleich'),
                value: _hasHpa,
                onChanged: (v) => setState(() => _hasHpa = v),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Schraubmontage'),
                value: _isBolted,
                onChanged: (v) => setState(() => _isBolted = v),
              ),

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
              ),

              _Section('Anlagen'),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('PV-Anlage geplant'),
                value: _pvAnlage,
                onChanged: (v) => setState(() => _pvAnlage = v),
              ),
              if (_pvAnlage)
                TextField(
                  controller: _pvKwp,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(labelText: 'PV-Größe (kWp)'),
                ),

              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Batteriespeicher geplant'),
                value: _batAnlage,
                onChanged: (v) => setState(() => _batAnlage = v),
              ),
              if (_batAnlage) ...[
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _batKwh,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Speicher (kWh)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _batUnits,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Einheiten'),
                    ),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _batDcA,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'DC-Sicherung (A)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _batAcKw,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'AC-Leistung (kW)'),
                    ),
                  ),
                ]),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Speicher außen'),
                  value: _batAussen,
                  onChanged: (v) => setState(() => _batAussen = v),
                ),
              ],

              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Wallbox geplant'),
                value: _wbAnlage,
                onChanged: (v) => setState(() => _wbAnlage = v),
              ),
              if (_wbAnlage) ...[
                TextField(
                  controller: _wbKw,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Ladeleistung (kW)'),
                ),
                TextField(
                  controller: _wbLeitungM,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Leitung (m)'),
                ),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Wallbox außen'),
                  value: _wbAussen,
                  onChanged: (v) => setState(() => _wbAussen = v),
                ),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kommunikation (LAN/WLAN/OCPP)'),
                  value: _wbKomm,
                  onChanged: (v) => setState(() => _wbKomm = v),
                ),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('PV-Überschussladen'),
                  value: _wbUeberschuss,
                  onChanged: (v) => setState(() => _wbUeberschuss = v),
                ),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('BZA (Notstrom)'),
                  value: _bza,
                  onChanged: (v) => setState(() => _bza = v),
                ),
              ],

              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Wärmepumpe geplant'),
                value: _wpAnlage,
                onChanged: (v) => setState(() => _wpAnlage = v),
              ),
              if (_wpAnlage) ...[
                TextField(
                  controller: _wpKw,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(labelText: 'WP-Leistung (kW)'),
                ),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _fbhZonen,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'FBH-Zonen'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _hwSchleifeM,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'HW-Schleife (m)'),
                    ),
                  ),
                ]),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Radiatoren'),
                  value: _radiatoren,
                  onChanged: (v) => setState(() => _radiatoren = v),
                ),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Garten'),
                  value: _garten,
                  onChanged: (v) => setState(() => _garten = v),
                ),
              ],
            ],
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
