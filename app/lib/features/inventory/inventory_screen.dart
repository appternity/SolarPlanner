import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../db/database.dart';

/// Felddefinition für das generische Artikelformular.
class ItemField {
  final String label;
  final String key;
  final bool number;
  final bool required;

  const ItemField(this.label, this.key,
      {this.number = false, this.required = false});
}

double _num(String? s) =>
    double.tryParse((s ?? '').trim().replaceAll(',', '.')) ?? 0;

double? _numOrNull(String? s) {
  final t = (s ?? '').trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

int _int(String? s) => _num(s).toInt();

/// Generischer Formular-Dialog, aufgebaut aus [ItemField]-Spezifikationen.
class ItemFormDialog extends StatefulWidget {
  final String title;
  final List<ItemField> fields;
  final Map<String, String> initial;
  final Future<void> Function(Map<String, String> values) onSave;
  final Future<void> Function()? onDelete;

  const ItemFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.initial,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      _controllers[f.key] =
          TextEditingController(text: widget.initial[f.key] ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final f in widget.fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _controllers[f.key],
                    decoration: InputDecoration(
                      labelText: f.label,
                      border: const OutlineInputBorder(),
                      isDense: true,
                      errorText: f.required &&
                              (_controllers[f.key]!.text.trim().isEmpty)
                          ? 'Pflichtfeld'
                          : null,
                    ),
                    keyboardType: f.number
                        ? const TextInputType.numberWithOptions(
                            decimal: true, signed: true)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.onDelete != null)
          TextButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Löschen'),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await widget.onDelete!();
              if (mounted) navigator.pop();
            },
          ),
        TextButton(
          child: const Text('Abbrechen'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          child: const Text('Speichern'),
          onPressed: () async {
            final navigator = Navigator.of(context);
            final values = <String, String>{
              for (final f in widget.fields)
                f.key: _controllers[f.key]!.text.trim(),
            };
            await widget.onSave(values);
            if (mounted) navigator.pop();
          },
        ),
      ],
    );
  }
}

/// Inventar-Screen mit Tabs für die vier Artikeltypen.
class InventoryScreen extends StatefulWidget {
  final AppDatabase db;
  final bool readOnly;

  const InventoryScreen({super.key, required this.db, this.readOnly = false});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.readOnly;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Module'),
              Tab(text: 'Wechselrichter'),
              Tab(text: 'Batterien'),
              Tab(text: 'Wallboxen'),
            ],
          ),
        ),
        floatingActionButton: readOnly
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _addCurrentTab(),
                icon: const Icon(Icons.add),
                label: const Text('Hinzufügen'),
              ),
        body: TabBarView(
          children: [
            _ModuleTab(db: widget.db, readOnly: readOnly, onEdit: _editModule),
            _InverterTab(db: widget.db, readOnly: readOnly, onEdit: _editInverter),
            _BatteryTab(db: widget.db, readOnly: readOnly, onEdit: _editBattery),
            _WallboxTab(db: widget.db, readOnly: readOnly, onEdit: _editWallbox),
          ],
        ),
      ),
    );
  }

  void _addCurrentTab() {
    switch (_tab.index) {
      case 0:
        _editModule(null);
      case 1:
        _editInverter(null);
      case 2:
        _editBattery(null);
      case 3:
        _editWallbox(null);
    }
  }

  // ------------------------------------------------------------------
  // Module
  // ------------------------------------------------------------------

  static const _moduleFields = [
    ItemField('Name', 'name', required: true),
    ItemField('Hersteller', 'manufacturer'),
    ItemField('Pmax (W)', 'pMaxW', number: true, required: true),
    ItemField('Vmp (V)', 'vmp', number: true),
    ItemField('Imp (A)', 'imp', number: true),
    ItemField('Voc (V)', 'voc', number: true, required: true),
    ItemField('Isc (A)', 'isc', number: true, required: true),
    ItemField('Voc-Temp. Koeff. (%/K)', 'vocTempCoeff', number: true),
    ItemField('Breite (mm)', 'widthMm', number: true, required: true),
    ItemField('Höhe (mm)', 'heightMm', number: true, required: true),
    ItemField('Stärke (mm)', 'thicknessMm', number: true),
    ItemField('Gewicht (kg)', 'weightKg', number: true),
  ];

  void _editModule(SolarModule? m) {
    if (widget.readOnly && m != null) return;
    showDialog(
      context: context,
      builder: (_) => ItemFormDialog(
        title: m == null ? 'Modul hinzufügen' : 'Modul bearbeiten',
        fields: _moduleFields,
        initial: {
          'name': m?.name ?? '',
          'manufacturer': m?.manufacturer ?? '',
          'pMaxW': m?.pMaxW.toString() ?? '',
          'vmp': m?.vmp.toString() ?? '',
          'imp': m?.imp.toString() ?? '',
          'voc': m?.voc.toString() ?? '',
          'isc': m?.isc.toString() ?? '',
          'vocTempCoeff': m?.vocTempCoeff.toString() ?? '',
          'widthMm': m?.widthMm.toString() ?? '',
          'heightMm': m?.heightMm.toString() ?? '',
          'thicknessMm': m?.thicknessMm.toString() ?? '',
          'weightKg': m?.weightKg?.toString() ?? '',
        },
        onSave: (v) async {
          final c = SolarModulesCompanion(
            name: Value(v['name']!),
            manufacturer: Value(v['manufacturer'] ?? ''),
            pMaxW: Value(_num(v['pMaxW'])),
            vmp: Value(_num(v['vmp'])),
            imp: Value(_num(v['imp'])),
            voc: Value(_num(v['voc'])),
            isc: Value(_num(v['isc'])),
            vocTempCoeff: Value(_num(v['vocTempCoeff'])),
            widthMm: Value(_num(v['widthMm'])),
            heightMm: Value(_num(v['heightMm'])),
            thicknessMm: Value(_num(v['thicknessMm'])),
            weightKg: Value(_numOrNull(v['weightKg'])),
          );
          if (m == null) {
            await widget.db.into(widget.db.solarModules).insert(c);
          } else {
            await (widget.db.update(widget.db.solarModules)
                  ..where((t) => t.id.equals(m.id)))
                .write(c);
          }
        },
        onDelete: m == null
            ? null
            : () async =>
                await (widget.db.delete(widget.db.solarModules)
                      ..where((t) => t.id.equals(m.id)))
                    .go(),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Wechselrichter
  // ------------------------------------------------------------------

  static const _inverterFields = [
    ItemField('Name', 'name', required: true),
    ItemField('Hersteller', 'manufacturer'),
    ItemField('Leistung (kW)', 'powerKw', number: true, required: true),
    ItemField('MPPT-Tracker', 'mppCount', number: true),
    ItemField('Max. Strings pro MPPT', 'maxStringsPerMpp', number: true),
    ItemField('Min. Eingangsspannung (V)', 'minInputVoltage', number: true),
    ItemField('Max. Eingangsspannung (V)', 'maxInputVoltage', number: true),
    ItemField('Max. Eingangsstrom pro MPPT (A)', 'maxInputCurrentPerMpp',
        number: true),
    ItemField('Max. Kurzschlussstrom pro MPPT (A)',
        'maxShortCircuitCurrentPerMpp', number: true),
    ItemField('Hybrid (1 = ja, 0 = nein)', 'isHybrid', number: true),
  ];

  void _editInverter(Inverter? m) {
    if (widget.readOnly && m != null) return;
    showDialog(
      context: context,
      builder: (_) => ItemFormDialog(
        title: m == null ? 'Wechselrichter hinzufügen' : 'Wechselrichter bearbeiten',
        fields: _inverterFields,
        initial: {
          'name': m?.name ?? '',
          'manufacturer': m?.manufacturer ?? '',
          'powerKw': m?.powerKw.toString() ?? '',
          'mppCount': m?.mppCount.toString() ?? '',
          'maxStringsPerMpp': m?.maxStringsPerMpp.toString() ?? '',
          'minInputVoltage': m?.minInputVoltage?.toString() ?? '',
          'maxInputVoltage': m?.maxInputVoltage?.toString() ?? '',
          'maxInputCurrentPerMpp': m?.maxInputCurrentPerMpp?.toString() ?? '',
          'maxShortCircuitCurrentPerMpp':
              m?.maxShortCircuitCurrentPerMpp?.toString() ?? '',
          'isHybrid': m?.isHybrid == true ? '1' : '0',
        },
        onSave: (v) async {
          final c = InvertersCompanion(
            name: Value(v['name']!),
            manufacturer: Value(v['manufacturer'] ?? ''),
            powerKw: Value(_num(v['powerKw'])),
            mppCount: Value(_int(v['mppCount'])),
            maxStringsPerMpp: Value(_int(v['maxStringsPerMpp'])),
            minInputVoltage: Value(_numOrNull(v['minInputVoltage'])),
            maxInputVoltage: Value(_numOrNull(v['maxInputVoltage'])),
            maxInputCurrentPerMpp:
                Value(_numOrNull(v['maxInputCurrentPerMpp'])),
            maxShortCircuitCurrentPerMpp: Value(
                _numOrNull(v['maxShortCircuitCurrentPerMpp'])),
            isHybrid: Value(_num(v['isHybrid']) > 0),
          );
          if (m == null) {
            await widget.db.into(widget.db.inverters).insert(c);
          } else {
            await (widget.db.update(widget.db.inverters)
                  ..where((t) => t.id.equals(m.id)))
                .write(c);
          }
        },
        onDelete: m == null
            ? null
            : () async =>
                await (widget.db.delete(widget.db.inverters)
                      ..where((t) => t.id.equals(m.id)))
                    .go(),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Batterien
  // ------------------------------------------------------------------

  static const _batteryFields = [
    ItemField('Name', 'name', required: true),
    ItemField('Hersteller', 'manufacturer'),
    ItemField('Nutzbare Kapazität (kWh)', 'capacityKwh', number: true,
        required: true),
    ItemField('Nennspannung (V)', 'nominalVoltage', number: true),
    ItemField('Chemie', 'chemistry'),
  ];

  void _editBattery(Battery? m) {
    if (widget.readOnly && m != null) return;
    showDialog(
      context: context,
      builder: (_) => ItemFormDialog(
        title: m == null ? 'Batterie hinzufügen' : 'Batterie bearbeiten',
        fields: _batteryFields,
        initial: {
          'name': m?.name ?? '',
          'manufacturer': m?.manufacturer ?? '',
          'capacityKwh': m?.capacityKwh.toString() ?? '',
          'nominalVoltage': m?.nominalVoltage?.toString() ?? '',
          'chemistry': m?.chemistry ?? '',
        },
        onSave: (v) async {
          final c = BatteriesCompanion(
            name: Value(v['name']!),
            manufacturer: Value(v['manufacturer'] ?? ''),
            capacityKwh: Value(_num(v['capacityKwh'])),
            nominalVoltage: Value(_numOrNull(v['nominalVoltage'])),
            chemistry: Value(v['chemistry'] ?? ''),
          );
          if (m == null) {
            await widget.db.into(widget.db.batteries).insert(c);
          } else {
            await (widget.db.update(widget.db.batteries)
                  ..where((t) => t.id.equals(m.id)))
                .write(c);
          }
        },
        onDelete: m == null
            ? null
            : () async =>
                await (widget.db.delete(widget.db.batteries)
                      ..where((t) => t.id.equals(m.id)))
                    .go(),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Wallboxen
  // ------------------------------------------------------------------

  static const _wallboxFields = [
    ItemField('Name', 'name', required: true),
    ItemField('Hersteller', 'manufacturer'),
    ItemField('Leistung (kW)', 'powerKw', number: true, required: true),
    ItemField('Phasen (1 oder 3)', 'phases', number: true),
    ItemField('LS-Schalter (A)', 'breakerA', number: true),
    ItemField('FI-Nennstrom (A)', 'rcdRatedA', number: true),
  ];

  void _editWallbox(Wallbox? m) {
    if (widget.readOnly && m != null) return;
    showDialog(
      context: context,
      builder: (_) => ItemFormDialog(
        title: m == null ? 'Wallbox hinzufügen' : 'Wallbox bearbeiten',
        fields: _wallboxFields,
        initial: {
          'name': m?.name ?? '',
          'manufacturer': m?.manufacturer ?? '',
          'powerKw': m?.powerKw.toString() ?? '',
          'phases': m?.phases.toString() ?? '',
          'breakerA': m?.breakerA.toString() ?? '',
          'rcdRatedA': m?.rcdRatedA.toString() ?? '',
        },
        onSave: (v) async {
          final c = WallboxesCompanion(
            name: Value(v['name']!),
            manufacturer: Value(v['manufacturer'] ?? ''),
            powerKw: Value(_num(v['powerKw'])),
            phases: Value(_int(v['phases'])),
            breakerA: Value(_numOrNull(v['breakerA'])),
            rcdRatedA: Value(_numOrNull(v['rcdRatedA'])),
          );
          if (m == null) {
            await widget.db.into(widget.db.wallboxes).insert(c);
          } else {
            await (widget.db.update(widget.db.wallboxes)
                  ..where((t) => t.id.equals(m.id)))
                .write(c);
          }
        },
        onDelete: m == null
            ? null
            : () async =>
                await (widget.db.delete(widget.db.wallboxes)
                      ..where((t) => t.id.equals(m.id)))
                    .go(),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Tabs
// ----------------------------------------------------------------------

class _ModuleTab extends StatelessWidget {
  final AppDatabase db;
  final bool readOnly;
  final void Function(SolarModule) onEdit;

  const _ModuleTab({required this.db, required this.onEdit, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SolarModule>>(
      stream: db.watchModules(),
      builder: (context, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const _EmptyHint(text: 'Noch keine Module – „Hinzufügen“ tippen.');
        }
        return ListView(
          children: [
            for (final m in items)
              ListTile(
                title: Text(m.name),
                subtitle: Text(
                  '${m.manufacturer} · ${m.pMaxW.toStringAsFixed(0)} W · '
                  'Voc ${m.voc.toStringAsFixed(2)} V · '
                  '${(m.widthMm / 1000).toStringAsFixed(2)} × '
                  '${(m.heightMm / 1000).toStringAsFixed(2)} m',
                ),
                trailing: readOnly
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(m),
                      ),
              ),
          ],
        );
      },
    );
  }
}

class _InverterTab extends StatelessWidget {
  final AppDatabase db;
  final bool readOnly;
  final void Function(Inverter) onEdit;

  const _InverterTab({required this.db, required this.onEdit, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Inverter>>(
      stream: db.watchInverters(),
      builder: (context, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const _EmptyHint(text: 'Noch keine Wechselrichter – „Hinzufügen“ tippen.');
        }
        return ListView(
          children: [
            for (final m in items)
              ListTile(
                title: Text(m.name),
                subtitle: Text(
                  '${m.manufacturer} · ${m.powerKw.toStringAsFixed(1)} kW · '
                  '${m.mppCount} MPPT × ${m.maxStringsPerMpp} Strings'
                  '${m.isHybrid ? ' · Hybrid' : ''}',
                ),
                trailing: readOnly
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(m),
                      ),
              ),
          ],
        );
      },
    );
  }
}

class _BatteryTab extends StatelessWidget {
  final AppDatabase db;
  final bool readOnly;
  final void Function(Battery) onEdit;

  const _BatteryTab({required this.db, required this.onEdit, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Battery>>(
      stream: db.watchBatteries(),
      builder: (context, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const _EmptyHint(text: 'Noch keine Batterien – „Hinzufügen“ tippen.');
        }
        return ListView(
          children: [
            for (final m in items)
              ListTile(
                title: Text(m.name),
                subtitle: Text(
                  '${m.manufacturer} · ${m.capacityKwh.toStringAsFixed(1)} kWh · ${m.chemistry}',
                ),
                trailing: readOnly
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(m),
                      ),
              ),
          ],
        );
      },
    );
  }
}

class _WallboxTab extends StatelessWidget {
  final AppDatabase db;
  final bool readOnly;
  final void Function(Wallbox) onEdit;

  const _WallboxTab({required this.db, required this.onEdit, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Wallbox>>(
      stream: db.watchWallboxes(),
      builder: (context, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const _EmptyHint(text: 'Noch keine Wallboxen – „Hinzufügen“ tippen.');
        }
        return ListView(
          children: [
            for (final m in items)
              ListTile(
                title: Text(m.name),
                subtitle: Text(
                  '${m.manufacturer} · ${m.powerKw.toStringAsFixed(1)} kW · ${m.phases}-phasig',
                ),
                trailing: readOnly
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(m),
                      ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(text,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center),
      ),
    );
  }
}
