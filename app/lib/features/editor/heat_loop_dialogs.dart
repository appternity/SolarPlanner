import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../db/database.dart' show HeatLoop;

/// Result of the add/edit heat loop dialog.
class HeatLoopFormResult {
  final String name;
  final String loopType;
  final double nominalKw;
  final int flowTempC;

  const HeatLoopFormResult({
    required this.name,
    required this.loopType,
    required this.nominalKw,
    required this.flowTempC,
  });
}

/// Shows the dialog to add a new heat loop. Returns null if cancelled.
Future<HeatLoopFormResult?> showAddHeatLoopDialog(BuildContext context) {
  return showDialog<HeatLoopFormResult>(
    context: context,
    builder: (_) => const _HeatLoopDialog(),
  );
}

/// Shows the dialog to edit an existing heat loop. Returns null if cancelled.
Future<HeatLoopFormResult?> showEditHeatLoopDialog(
  BuildContext context,
  HeatLoop loop,
) {
  return showDialog<HeatLoopFormResult>(
    context: context,
    builder: (_) => _HeatLoopDialog(existing: loop),
  );
}

/// Asks for confirmation before deleting a heat loop. Returns true if confirmed.
Future<bool> confirmDeleteHeatLoop(BuildContext context, HeatLoop loop) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('„${loop.name}“ löschen?'),
      content: const Text(
          'Der Heizkreis und alle zugehörigen hydraulischen Berechnungen '
          'werden entfernt. Dies kann nicht rückgängig gemacht werden.'),
      actions: [
        TextButton(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(context).pop(false)),
        TextButton(
            child: const Text('Löschen'),
            onPressed: () => Navigator.of(context).pop(true)),
      ],
    ),
  );
  return ok ?? false;
}

class _HeatLoopDialog extends StatefulWidget {
  const _HeatLoopDialog({this.existing});

  final HeatLoop? existing;

  @override
  State<_HeatLoopDialog> createState() => _HeatLoopDialogState();
}

class _HeatLoopDialogState extends State<_HeatLoopDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nominalCtrl;
  late final TextEditingController _flowTempCtrl;
  late String _loopType;

  static const List<String> _loopTypes = [
    'radiator',
    'fußbodenheizung',
    'konvektor',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
        text: widget.existing?.name ?? 'Neuer Heizkreis');
    _loopType = widget.existing?.loopType ?? 'radiator';
    _nominalCtrl = TextEditingController(
        text: widget.existing?.nominalKw.toString() ?? '0');
    _flowTempCtrl = TextEditingController(
        text: widget.existing?.flowTempC.toString() ?? '55');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nominalCtrl.dispose();
    _flowTempCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null
          ? 'Neuen Heizkreis erstellen'
          : 'Heizkreis bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              autofocus: widget.existing == null,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'z.B. Erdgeschoss Radiatoren',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _loopType,
              decoration: const InputDecoration(
                labelText: 'Typ',
              ),
              items: _loopTypes.map((type) {
                final label = type == 'radiator'
                    ? 'Radiatoren'
                    : type == 'fußbodenheizung'
                        ? 'Fußbodenheizung'
                        : 'Konvektoren';
                return DropdownMenuItem(
                  value: type,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (v) => setState(() => _loopType = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nominalCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              decoration: const InputDecoration(
                labelText: 'Nennleistung (kW)',
                hintText: 'z.B. 12',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _flowTempCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: false),
              decoration: const InputDecoration(
                labelText: 'Vorlauftemperatur (°C)',
                hintText: 'z.B. 55',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Abbrechen'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FilledButton(
          child: const Text('Speichern'),
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Bitte einen Namen eingeben.')),
              );
              return;
            }
            double nominalKw;
            try {
              nominalKw = double.parse(_nominalCtrl.text);
            } on FormatException {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Ungültige Nennleistung.')),
              );
              return;
            }
            int flowTempC;
            try {
              flowTempC = int.parse(_flowTempCtrl.text);
            } on FormatException {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Ungültige Vorlauftemperatur.')),
              );
              return;
            }
            Navigator.of(context).pop(HeatLoopFormResult(
              name: name,
              loopType: _loopType,
              nominalKw: nominalKw,
              flowTempC: flowTempC,
            ));
          },
        ),
      ],
    );
  }
}
