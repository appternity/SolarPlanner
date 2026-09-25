import 'package:flutter/material.dart';

import '../../db/database.dart';
import '../../db/tables.dart' show RoofType, TileMaterial, RoofTypeX, TileMaterialX;

/// Result of the add/edit roof dialog.
class RoofFormResult {
  final String name;

  /// Only set when adding a new roof (fixed afterwards).
  final double? lengthM;

  /// Only set when adding a new roof (fixed afterwards).
  final double? widthM;

  /// Only set when adding a new roof (fixed afterwards).
  final RoofType? type;

  // Editable settings.
  final double pitchDeg;
  final int azimuthDeg;

  // Flachdach (cm) – null = unchanged.
  final double? flatBaseHeightCm;
  final double? flatAttikaHeightCm;
  final double? flatAttikaWidthCm;

  // Steildach (cm) – null = unchanged.
  final double? rafterWidthCm;
  final double? rafterDepthCm;
  final double? rafterSpacingCm;
  final double? battenThicknessCm;
  final bool rafterStraight;
  final bool hasCounterBatten;
  final int? tilesVisibleWidth;
  final int? tilesVisibleHeight;
  final double? tileOverlapCm;
  final TileMaterial tileMaterial;
  final bool hasSpareTiles;
  final bool hasInsulation;
  final double? insulationThicknessCm;

  // Module layout (auto-fill), in centimeters – null = use the type default.
  final double? moduleMarginCm;
  final double? moduleGapCm;

  const RoofFormResult({
    required this.name,
    this.lengthM,
    this.widthM,
    required this.pitchDeg,
    required this.azimuthDeg,
    this.type,
    this.flatBaseHeightCm,
    this.flatAttikaHeightCm,
    this.flatAttikaWidthCm,
    this.rafterWidthCm,
    this.rafterDepthCm,
    this.rafterSpacingCm,
    this.battenThicknessCm,
    required this.rafterStraight,
    required this.hasCounterBatten,
    this.tilesVisibleWidth,
    this.tilesVisibleHeight,
    this.tileOverlapCm,
    required this.tileMaterial,
    required this.hasSpareTiles,
    required this.hasInsulation,
    this.insulationThicknessCm,
    this.moduleMarginCm,
    this.moduleGapCm,
  });

  bool get isAdd => type != null;
}

/// Shows the dialog to add a new roof. Returns null if cancelled.
Future<RoofFormResult?> showAddRoofDialog(BuildContext context) {
  return showDialog<RoofFormResult>(
      context: context, builder: (_) => const _RoofDialog());
}

/// Shows the dialog to edit an existing roof. Returns null if cancelled.
Future<RoofFormResult?> showEditRoofDialog(BuildContext context, Roof roof) {
  return showDialog<RoofFormResult>(
      context: context, builder: (_) => _RoofDialog(existing: roof));
}

/// Asks for confirmation before deleting a roof. Returns true if confirmed.
Future<bool> confirmDeleteRoof(BuildContext context, Roof roof) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('„${roof.name}“ löschen?'),
      content: const Text(
          'Das Dach und alle darauf platzierten Module werden entfernt. '
          'Dies kann nicht rückgängig gemacht werden.'),
      actions: [
        TextButton(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(context).pop(false)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Löschen'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class _RoofDialog extends StatefulWidget {
  final Roof? existing;

  const _RoofDialog({this.existing});

  @override
  State<_RoofDialog> createState() => _RoofDialogState();
}

class _RoofDialogState extends State<_RoofDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _lengthCtrl;
  late TextEditingController _widthCtrl;
  late TextEditingController _pitchCtrl;
  late TextEditingController _azimuthCtrl;

  // Type: fixed once the roof exists.
  late RoofType _type;

  bool get _isAdd => widget.existing == null;

  // Flachdach (cm).
  late TextEditingController _flatBaseHeightCtrl;
  late TextEditingController _flatAttikaHeightCtrl;
  late TextEditingController _flatAttikaWidthCtrl;

  // Steildach (cm).
  late TextEditingController _rafterWidthCtrl;
  late TextEditingController _rafterDepthCtrl;
  late TextEditingController _rafterSpacingCtrl;
  late TextEditingController _battenThicknessCtrl;
  bool _rafterStraight = true;
  bool _hasCounterBatten = false;
  late TextEditingController _tilesWidthCtrl;
  late TextEditingController _tilesHeightCtrl;
  late TextEditingController _tileOverlapCtrl;
  TileMaterial _tileMaterial = TileMaterial.clay;
  bool _hasSpareTiles = false;
  bool _hasInsulation = false;
  late TextEditingController _insulationCtrl;

  // Module layout (auto-fill), in meters.
  late TextEditingController _moduleMarginCtrl;
  late TextEditingController _moduleGapCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _nameCtrl = TextEditingController(text: (r?.name ?? '').trim());
    _lengthCtrl = TextEditingController(text: fmtNum(r?.lengthM));
    _widthCtrl = TextEditingController(text: fmtNum(r?.widthM));
    _pitchCtrl = TextEditingController(
        text: (r?.pitchDeg ?? 30).toStringAsFixed(1));
    _azimuthCtrl = TextEditingController(text: (r?.azimuthDeg ?? 180).round().toString());
    _type = r == null ? RoofType.pitched : RoofTypeX.parse(r.type);
    _flatBaseHeightCtrl = TextEditingController(text: fmtNum(r?.flatBaseHeightCm));
    _flatAttikaHeightCtrl = TextEditingController(text: fmtNum(r?.flatAttikaHeightCm));
    _flatAttikaWidthCtrl = TextEditingController(text: fmtNum(r?.flatAttikaWidthCm));
    _rafterWidthCtrl = TextEditingController(text: fmtNum(r?.rafterWidthCm));
    _rafterDepthCtrl = TextEditingController(text: fmtNum(r?.rafterDepthCm));
    _rafterSpacingCtrl = TextEditingController(text: fmtNum(r?.rafterSpacingCm));
    _battenThicknessCtrl = TextEditingController(text: fmtNum(r?.battenThicknessCm));
    _rafterStraight = r?.rafterStraight ?? true;
    _hasCounterBatten = r?.hasCounterBatten ?? false;
    _tilesWidthCtrl = TextEditingController(text: r?.tilesVisibleWidth?.toString() ?? '');
    _tilesHeightCtrl = TextEditingController(text: r?.tilesVisibleHeight?.toString() ?? '');
    _tileOverlapCtrl = TextEditingController(text: fmtNum(r?.tileOverlapCm));
    _tileMaterial = r == null ? TileMaterial.clay : TileMaterialX.parse(r.tileMaterial);
    _hasSpareTiles = r?.hasSpareTiles ?? false;
    _hasInsulation = r?.hasInsulation ?? false;
    _insulationCtrl = TextEditingController(text: fmtNum(r?.insulationThicknessCm));
    // Stored in meters; display as centimeters.
    _moduleMarginCtrl =
        TextEditingController(text: fmtNum(r?.moduleMarginM != null ? r!.moduleMarginM! * 100 : null));
    _moduleGapCtrl =
        TextEditingController(text: fmtNum(r?.moduleGapM != null ? r!.moduleGapM! * 100 : null));
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _lengthCtrl,
      _widthCtrl,
      _pitchCtrl,
      _azimuthCtrl,
      _flatBaseHeightCtrl,
      _flatAttikaHeightCtrl,
      _flatAttikaWidthCtrl,
      _rafterWidthCtrl,
      _rafterDepthCtrl,
      _rafterSpacingCtrl,
      _battenThicknessCtrl,
      _tilesWidthCtrl,
      _tilesHeightCtrl,
      _tileOverlapCtrl,
      _insulationCtrl,
      _moduleMarginCtrl,
      _moduleGapCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Parses a numeric field (German comma or dot accepted).
  static double? parseNum(String text) {
    final t = text.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  static int? parseInt(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  static String fmtNum(double? v) =>
      v == null ? '' : (v.truncateToDouble() == v ? v.toInt().toString()
          : v.toStringAsFixed(1));

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    double? posNum(TextEditingController c, {bool required = true}) {
      final v = parseNum(c.text);
      if (v == null) return null;
      if (required && v <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alle Maße müssen größer als 0 sein.')));
        return null;
      }
      return v;
    }

    // Geometry is only editable when adding a new roof; in edit mode these
    // stay null (the rectangle is fixed once created).
    final lengthM = _isAdd ? posNum(_lengthCtrl) : null;
    final widthM = _isAdd ? posNum(_widthCtrl) : null;
    final pitchDeg = parseNum(_pitchCtrl.text);
    final azimuthRaw = parseNum(_azimuthCtrl.text);

    // In add mode length/width are required; in edit mode they stay null.
    if (_isAdd && (lengthM == null || widthM == null)) return;
    if (pitchDeg == null || azimuthRaw == null) {
      return; // invalid input
    }

    int? posInt(TextEditingController c) {
      final v = parseInt(c.text);
      return (v == null || v <= 0) ? null : v;
    }

    Navigator.of(context).pop(RoofFormResult(
      name: _nameCtrl.text.trim(),
      lengthM: lengthM,
      widthM: widthM,
      pitchDeg: pitchDeg,
      azimuthDeg: (azimuthRaw % 360).round(),
      type: _isAdd ? _type : null,
      flatBaseHeightCm: parseNum(_flatBaseHeightCtrl.text),
      flatAttikaHeightCm: parseNum(_flatAttikaHeightCtrl.text),
      flatAttikaWidthCm: parseNum(_flatAttikaWidthCtrl.text),
      rafterWidthCm: parseNum(_rafterWidthCtrl.text),
      rafterDepthCm: parseNum(_rafterDepthCtrl.text),
      rafterSpacingCm: parseNum(_rafterSpacingCtrl.text),
      battenThicknessCm: parseNum(_battenThicknessCtrl.text),
      rafterStraight: _rafterStraight,
      hasCounterBatten: _hasCounterBatten,
      tilesVisibleWidth: posInt(_tilesWidthCtrl),
      tilesVisibleHeight: posInt(_tilesHeightCtrl),
      tileOverlapCm: parseNum(_tileOverlapCtrl.text),
      tileMaterial: _tileMaterial,
      hasSpareTiles: _hasSpareTiles,
      hasInsulation: _hasInsulation,
      insulationThicknessCm: parseNum(_insulationCtrl.text),
      moduleMarginCm: parseNum(_moduleMarginCtrl.text),
      moduleGapCm: parseNum(_moduleGapCtrl.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.roofing),
      title: Text(_isAdd ? 'Dach hinzufügen' : '„${widget.existing!.name}“ bearbeiten'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // -- Common fields --------------------------------------
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null),
                if (_isAdd) ...[
                  Row(children: [
                    Expanded(
                      child: _numField('Länge (m)', _lengthCtrl, required: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numField('Breite (m)', _widthCtrl, required: true),
                    ),
                  ]),
                ] else ...[
                  // Dimensions are fixed once the roof exists; show them
                  // read-only so the user knows what they're editing.
                  const _SectionLabel('Abmessungen (nicht änderbar)'),
                  Row(children: [
                    Expanded(
                      child: _readOnlyField('Länge (m)',
                          widget.existing!.lengthM),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          _readOnlyField('Breite (m)', widget.existing!.widthM),
                    ),
                  ]),
                ],
                Row(children: [
                  Expanded(
                      child: _numField('Neigung (°)', _pitchCtrl, required: true)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numField('Himmelsrichtung (°)', _azimuthCtrl,
                        required: true, hint: '0=N 90=O 180=S'),
                  ),
                ]),

                // -- Type -----------------------------------------------
                const SizedBox(height: 8),
                Text(_isAdd ? 'Dachtyp' : 'Dachtyp (nicht änderbar)',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                SegmentedButton<RoofType>(
                  segments: const [
                    ButtonSegment(
                        value: RoofType.flat, label: Text('Flachdach')),
                    ButtonSegment(
                        value: RoofType.pitched, label: Text('Steildach')),
                  ],
                  selected: {_type},
                  onSelectionChanged: _isAdd
                      ? (s) => setState(() => _type = s.first)
                      : null,
                ),

                // -- Type-specific fields -------------------------------
                if (_type == RoofType.flat) ...[
                  const _SectionLabel('Flachdach (cm)'),
                  Row(children: [
                    Expanded(
                      child: _numField('Höhe tiefster Punkt über Boden (cm)',
                          _flatBaseHeightCtrl),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _numField('Attikahöhe (cm)', _flatAttikaHeightCtrl)),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _numField('Attikabreite (cm)', _flatAttikaWidthCtrl)),
                  ]),
                ] else ...[
                  const _SectionLabel('Steildach (cm)'),
                  Row(children: [
                    Expanded(
                        child: _numField('Sparren Breite (cm)', _rafterWidthCtrl)),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _numField('Sparren Tiefe (cm)', _rafterDepthCtrl)),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _numField('Sparrenabstand (cm)', _rafterSpacingCtrl)),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _numField('Dachlattendicke (cm)', _battenThicknessCtrl)),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _switch('Sparren gerade', _rafterStraight,
                            (v) => setState(() => _rafterStraight = v))),
                    Expanded(
                        child: _switch('Konterlattung', _hasCounterBatten,
                            (v) => setState(() => _hasCounterBatten = v))),
                  ]),

                  const _SectionLabel('Ziegel'),
                  Row(children: [
                    Expanded(
                      child: _intField('Anzahl Ziegel sichtbare Breite', _tilesWidthCtrl),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                      child: _intField('Anzahl Ziegel sichtbare Höhe', _tilesHeightCtrl),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _numField('Ziegelüberdeckung (cm)', _tileOverlapCtrl)),
                  ]),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<TileMaterial>(
                        initialValue: _tileMaterial,
                        decoration: const InputDecoration(
                            labelText: 'Ziegeltyp', border: OutlineInputBorder()),
                        items: [
                          for (final m in TileMaterial.values)
                            DropdownMenuItem(value: m, child: Text(m.label)),
                        ],
                        onChanged: (v) => setState(
                            () => _tileMaterial = v ?? TileMaterial.clay),
                      ),
                    ),
                  ]),
                  Row(children: [
                    Expanded(
                        child: _switch('Ersatzziegel vorhanden', _hasSpareTiles,
                            (v) => setState(() => _hasSpareTiles = v))),
                    Expanded(
                        child: _switch('Dämmung', _hasInsulation,
                            (v) => setState(() {
                              if (!v && _insulationCtrl.text.isNotEmpty) {
                                _insulationCtrl.clear();
                              }
                              _hasInsulation = v;
                            }))),
                  ]),
                  if (_hasInsulation)
                    Row(children: [
                      Expanded(
                        child: _numField('Dicke Aufsparrendämmung (cm)',
                            _insulationCtrl),
                      ),
                    ]),
                ],

                // -- Module layout (auto-fill) --------------------------
                const _SectionLabel('Modulabstand (Auto-Ausfüllen, cm)'),
                Row(children: [
                  Expanded(
                    child: _numField('Randabstand (cm)', _moduleMarginCtrl,
                        hint: 'leer = Standard'),
                  ),
                ]),
                Row(children: [
                  Expanded(
                    child: _numField('Abstand zwischen Modulen (cm)',
                        _moduleGapCtrl, hint: 'leer = Standard'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen')),
        FilledButton(
          onPressed: _submit,
          child: Text(_isAdd ? 'Hinzufügen' : 'Speichern'),
        ),
      ],
    );
  }

  Widget _numField(String label, TextEditingController ctrl,
      {bool required = false, String? hint}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (v) {
        final t = v?.trim() ?? '';
        if (!required && t.isEmpty) return null;
        final value = parseNum(t);
        if (value == null) return 'Ungültige Zahl';
        if (required && value <= 0) return 'Größer als 0';
        return null;
      },
    );
  }

  /// A non-editable field showing a fixed value (e.g. roof dimensions in edit
  /// mode). Styled to look disabled so the user knows it can't be changed.
  Widget _readOnlyField(String label, double value) {
    return TextFormField(
      controller: TextEditingController(text: fmtNum(value)),
      enabled: false,
      readOnly: true,
      decoration:
          InputDecoration(labelText: label, suffixIcon: const Icon(Icons.lock)),
    );
  }

  Widget _intField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        final t = v?.trim() ?? '';
        if (t.isEmpty) return null;
        final value = parseInt(t);
        if (value == null || value <= 0) return 'Ungültige Zahl';
        return null;
      },
    );
  }

  Widget _switch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
