import 'package:flutter/material.dart';

import '../../db/database.dart';
import 'editor_controller.dart';
import '../../core/efficiency_table.dart';
import 'roof_canvas.dart';
import 'roof_dialogs.dart' show confirmDeleteRoof, showAddRoofDialog, showEditRoofDialog;
import 'efficiency_dialog.dart';


/// Full-screen project editor: roof canvas + control panel.
class EditorScreen extends StatefulWidget {
  final AppDatabase db;
  final int projectId;
  final String projectName;
  final bool readOnly;

  const EditorScreen({
    super.key,
    required this.db,
    required this.projectId,
    required this.projectName,
    required this.readOnly,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final EditorController _controller = EditorController(
    db: widget.db,
    projectId: widget.projectId,
    readOnly: widget.readOnly,
  );

  /// Width of the right-hand control panel. The initial value doubles as the
  /// minimum — the user can drag its left edge to widen it. Clamped in build
  /// so panel + handle never squeeze the canvas into a Row overflow.
  double _panelWidth = _minPanelWidth;

  static const double _minPanelWidth = 340;
  static const double _handleWidth = 8;

  /// The canvas must keep at least this much room next to the panel.
  static const double _minCanvasWidth = 200;

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 900;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          if (!widget.readOnly) ...[
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Strings automatisch zuweisen',
              onPressed: _controller.autoAssignStrings,
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (isWide) {
            // Clamp to the space actually available: dragging the panel wider
            // than window - handle - canvas minimum would overflow the Row.
            final maxPanelWidth = MediaQuery.sizeOf(context).width -
                _handleWidth -
                _minCanvasWidth;
            final panelWidth =
                _panelWidth.clamp(_minPanelWidth, maxPanelWidth);
            return Row(
              children: [
                Expanded(child: RoofCanvas(controller: _controller)),
                _PanelResizeHandle(
                  onDragDeltaX: (dx) {
                    // Dragging the handle right shrinks the panel, left widens it.
                    setState(() {
                      _panelWidth = (_panelWidth - dx)
                          .clamp(_minPanelWidth, double.infinity);
                    });
                  },
                ),
                SizedBox(
                  width: panelWidth,
                  child: _ControlPanel(
                    controller: _controller,
                    readOnly: widget.readOnly,
                  ),
                ),
              ],
            );
          }
          return Stack(
            children: [
              Positioned.fill(child: RoofCanvas(controller: _controller)),
              Positioned(
                right: 12,
                bottom: 96,
                child: FloatingActionButton(
                  heroTag: 'panel',
                  onPressed: () => _showPanel(),
                  child: const Icon(Icons.tune),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: _ControlPanel(
          controller: _controller,
          readOnly: widget.readOnly,
        ),
      ),
    );
  }
}

/// Thin draggable divider between the canvas and the control panel.
///
/// The visible line is 1 px wide; an 8 px hit area makes it easy to grab.
/// Reports horizontal drag deltas so the parent can resize the panel
/// (drag right = narrower, left = wider).
class _PanelResizeHandle extends StatelessWidget {
  final ValueChanged<double> onDragDeltaX;

  const _PanelResizeHandle({required this.onDragDeltaX});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Shows the resize cursor while hovering, reverts to default on leave.
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        key: const ValueKey('panel-resize-handle'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDragDeltaX(details.delta.dx),
        child: Container(
          width: 8,
          alignment: Alignment.centerRight,
          color: Colors.transparent,
          child: Container(
            width: 1,
            color:
                Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

/// Side panel / bottom sheet with all editor controls.
class _ControlPanel extends StatelessWidget {
  final EditorController controller;
  final bool readOnly;

  const _ControlPanel({required this.controller, required this.readOnly});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Mode
        const _SectionTitle('Modus'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _modeChip('Auswählen', Icons.touch_app, c.mode == EditorMode.select, () => c.setMode(EditorMode.select)),
            if (!readOnly) ...[
              _modeChip('Modul platzieren', Icons.add_photo_alternate, c.mode == EditorMode.placeModule, () => c.setMode(EditorMode.placeModule)),
              _modeChip('Hindernis hinzufügen', Icons.park, c.mode == EditorMode.addObstacle, () => c.setMode(EditorMode.addObstacle)),
            ],
          ],
        ),
        const Divider(),

        // Roofs
        const _SectionTitle('Dächer'),
        // Per-roof yield efficiency. Each row has a slim colored bar on the left
        // that highlights when that roof is selected (single-selection).
        for (final r in c.roofs)
          _roofSelectionRow(context, c, r, readOnly),
        const SizedBox(height: 8),
        if (!readOnly)
          OutlinedButton.icon(
            icon: const Icon(Icons.add_home, size: 18),
            label: const Text('Dach hinzufügen'),
            onPressed: () async {
              final result = await showAddRoofDialog(context);
              if (result != null) {
                await c.addRoof(result);
              }
            },
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.grid_on, size: 18),
                label: const Text('Automatisch füllen'),
                onPressed: c.selectedRoofId == null || readOnly
                    ? null
                    : () => c.autoFillRoof(c.selectedRoofId!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Bearbeiten'),
                onPressed: c.selectedRoofId == null || readOnly
                    ? null
                    : () async {
                      final roof = c.roofById(c.selectedRoofId!);
                      if (roof == null) return;
                      final result = await showEditRoofDialog(context, roof);
                      if (result != null) {
                        await c.updateRoof(roof.id, result);
                      }
                    },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Löschen'),
                onPressed: c.selectedRoofId == null || readOnly
                    ? null
                    : () async {
                      final roof = c.roofById(c.selectedRoofId!);
                      if (roof == null) return;
                      final confirmed = await confirmDeleteRoof(context, roof);
                      if (confirmed) {
                        await c.deleteRoof(roof.id);
                      }
                    },
              ),
            ),
          ],
        ),
        const Divider(),

        // Module type
        const _SectionTitle('Modultyp'),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<int>(
            initialValue: c.activeModuleTypeId,
            isExpanded: true,
            items: [
              for (final m in c.moduleTypes)
                DropdownMenuItem(
                  value: m.id,
                  child: Text('${m.name} (${m.pMaxW.toStringAsFixed(0)} W)',
                      overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: readOnly ? null : (v) {
              c.setActiveModuleType(v);
            },
          ),
        ),
        const Divider(),

        // Inverter & strings
        const _SectionTitle('Wechselrichter'),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<int>(
            initialValue: c.activeInverterId,
            isExpanded: true,
            items: [
              for (final i in c.inverters)
                DropdownMenuItem(
                  value: i.id,
                  child: Text(
                      '${i.name} (${i.powerKw.toStringAsFixed(1)} kW, ${i.mppCount} MPPT)',
                      overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: readOnly ? null : (v) {
              c.setActiveInverter(v);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: c.activeMppIndex ?? 0,
                items: [
                  for (var i = 0;
                      i < (c.activeInverter?.mppCount ?? 1);
                      i++)
                    DropdownMenuItem(value: i, child: Text('MPPT ${i + 1}')),
                ],
                onChanged: readOnly
                    ? null
                    : (v) {
                        c.activeMppIndex = v;
                        c.notifyNow();
                      },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cable, size: 18),
                label: const Text('Ausgew. zuweisen'),
                onPressed: c.selectedPlacedId == null || readOnly
                    ? null
                    : c.assignSelectedToActiveString,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('Alle Strings automatisch zuweisen'),
          onPressed: readOnly ? null : c.autoAssignStrings,
        ),
        const SizedBox(height: 8),
        for (final s in c.strings)
          _stringRow(c.summaryOf(s), readOnly: readOnly,
              onDelete: () => c.deleteString(s.id)),
        const Divider(),

        // Site conditions (VDE checks)
        _SiteConditions(controller: c, readOnly: readOnly),
        const Divider(),

        // VDE checks
        _ViolationsPanel(controller: c),
        const Divider(),

        // Selection
        const _SectionTitle('Auswahl'),
        if (c.selectedPlacedId != null)
          _selectionInfo(
            'Modul #${c.selectedPlacedId}',
            readOnly ? null : () => c.deletePlaced(c.selectedPlacedId!),
          )
        else if (c.selectedObstacleId != null)
          _selectionInfo(
            'Hindernis #${c.selectedObstacleId}',
            readOnly ? null : () => c.deleteObstacle(c.selectedObstacleId!),
          )
        else if (c.selectedRoofId != null)
          _selectionInfo('Dach #${c.selectedRoofId}', null)
        else
          const Text('Tippe ein Objekt auf der Leinwand, um es auszuwählen.',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        const Divider(),

        // Stats
        const _SectionTitle('Anlage'),
        Text(
          'Module: ${c.placed.length}   Strings: ${c.strings.length}\n'
          'DC: ${c.totalKwp.toStringAsFixed(2)} kWp / AC: '
          '${c.totalAcKw.toStringAsFixed(1)} kW'
          '${c.totalAcKw > 0
              ? ' (Verhältnis ${(c.totalKwp / c.totalAcKw).toStringAsFixed(2)})'
              : ''}',
          style: const TextStyle(fontSize: 13),
        ),
        if (readOnly)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Schreibgeschützt (Leser-Modus)',
              style: TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _modeChip(
      String label, IconData icon, bool active, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: active,
      onSelected: (_) => onTap(),
    );
  }

  Widget _stringRow(StringSummary summary,
      {required bool readOnly, required VoidCallback onDelete}) {
    return Dismissible(
      key: ValueKey('string-${summary.moduleString.id}'),
      onDismissed: readOnly ? null : (_) => onDelete(),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(summary.moduleString.name),
        subtitle: Text(
          '${summary.moduleCount} Module · '
          'Voc kalt ${summary.vocCold.toStringAsFixed(0)} V / '
          'heiß ${summary.vocHot.toStringAsFixed(0)} V',
        ),
        trailing: readOnly
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
              ),
      ),
    );
  }

  Widget _selectionInfo(String label, VoidCallback? onDelete) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
      ],
    );
  }
}

/// Display name of a roof (falls back to its id).
String _roofLabel(Roof r) =>
r.name.isEmpty ? 'Dach #${r.id}' : r.name;

/// A tapable row with a slim colored bar on the left that highlights when
/// that roof is selected. Shows module count and efficiency info.

/// A tapable row with a slim colored bar on the left that highlights when
/// that roof is selected. Shows module count and efficiency info.
Widget _roofSelectionRow(
    BuildContext context, EditorController c, Roof r, bool readOnly) {
  final isSelected = c.selectedRoofId == r.id;
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 8,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withValues(alpha: 0.6)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
    title: Text(_roofLabel(r), style: const TextStyle(fontSize: 13)),
    subtitle: Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        '${c.placed.where((m) => m.roofId == r.id).length} ${
            c.placed.where((m) => m.roofId == r.id).length > 1
                ? "Modules"
                : "Module"} — ${EfficiencyTable.efficiencyPercent(
                    azimuthDeg: r.azimuthDeg,
                    pitchDeg: r.pitchDeg)
                .toStringAsFixed(0)} %',
        style: const TextStyle(fontSize: 12),
      ),
    ),
    trailing: IconButton(
      icon: const Icon(Icons.table_chart, size: 18),
      tooltip: 'Ertragstabelle (Ausrichtung & Neigung)',
      visualDensity: VisualDensity.compact,
      onPressed: () => showEfficiencyTableDialog(context),
    ),
    onTap: readOnly ? null : () {
      if (c.selectedRoofId == r.id) {
        c.selectedRoofId = null;
      } else {
        c.selectedRoofId = r.id;
      }
      c.notifyNow();
    },
    tileColor: isSelected
        ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
        : null,
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
      ),
    );
  }
}

/// Site-condition inputs used by the VDE checks (temperatures, grid phases,
/// feed-in limit, equipotential / mounting flags).
class _SiteConditions extends StatefulWidget {
  final EditorController controller;
  final bool readOnly;

  const _SiteConditions({required this.controller, required this.readOnly});

  @override
  State<_SiteConditions> createState() => _SiteConditionsState();
}

class _SiteConditionsState extends State<_SiteConditions> {
  late final TextEditingController _tMin =
      TextEditingController(text: widget.controller.project?.tAmbientMinC.toStringAsFixed(0));
  late final TextEditingController _tMax =
      TextEditingController(text: widget.controller.project?.tAmbientMaxC.toStringAsFixed(0));
  late final TextEditingController _feedIn =
      TextEditingController(text: widget.controller.project?.maxFeedInKw
          ?.toStringAsFixed(1) ??
          '');

  @override
  void dispose() {
    _tMin.dispose();
    _tMax.dispose();
    _feedIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final p = c.project;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Standort (VDE-Prüfungen)'),
        // T_min/T_max are fixed planning constants (IEC cold condition
        // −25 °C / 40 °C) — shown read-only.
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tMin,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'T_min (°C)',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _tMax,
                enabled: false,
                decoration:
                    const InputDecoration(labelText: 'T_max (°C)', isDense: true),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: p?.gridPhases ?? 3,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('EINPHASIG')),
                  DropdownMenuItem(value: 3, child: Text('DREIPHASIG')),
                ],
                onChanged:
                    widget.readOnly ? null : (v) => c.updateSiteConditions(gridPhases: v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _feedIn,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Max. Einspeisung (kW)', isDense: true),
                onSubmitted: (v) => c.updateSiteConditions(
                    maxFeedInKw:
                        v.trim().isEmpty ? null : double.tryParse(v.trim())),
              ),
            ),
          ],
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Haupt-Potenzialausgleich',
              style: TextStyle(fontSize: 13)),
          value: p?.hasMainEquipotential ?? false,
          onChanged:
              widget.readOnly ? null : (v) => c.updateSiteConditions(hasMainEquipotential: v),
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title:
              const Text('Schraubmontage', style: TextStyle(fontSize: 13)),
          value: p?.isBoltedMounting ?? true,
          onChanged:
              widget.readOnly ? null : (v) => c.updateSiteConditions(isBoltedMounting: v),
        ),
      ],
    );
  }
}

/// Lists the results of all VDE planning checks for the current state.
class _ViolationsPanel extends StatelessWidget {
  final EditorController controller;

  const _ViolationsPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final violations = controller.validateProject();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Prüfungen (VDE)'),
        if (violations.isEmpty)
          const Text('Keine Auffälligkeiten.',
              style: TextStyle(color: Colors.green, fontSize: 13))
        else
          for (final v in violations)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    v.severity == 'error'
                        ? Icons.error_outline
                        : v.severity == 'warning'
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline,
                    size: 16,
                    color: v.severity == 'error'
                        ? Colors.red
                        : v.severity == 'warning'
                            ? Colors.orange
                            : Colors.blueGrey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child:
                        Text(v.message, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
