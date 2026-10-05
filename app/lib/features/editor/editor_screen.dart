import 'package:flutter/material.dart';

import '../../db/database.dart';
import 'editor_controller.dart';
import '../../core/efficiency_table.dart';
import 'roof_canvas.dart';
import 'roof_dialogs.dart' show confirmDeleteRoof, showAddRoofDialog, showEditRoofDialog;
import 'efficiency_dialog.dart';
import 'project_properties_dialog.dart'
    show ProjectPropertiesResult, showProjectPropertiesDialog;


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

  /// Width of the vertical system-tab rail pinned to the left edge.
  static const double _railWidth = 264;

  /// Index of the active system tab (0 = Projekt, 1 = PV, 2 = Speicher,
  /// 3 = Wallbox, 4 = Wärmepumpe). Only the Projekt and PV tabs are
  /// functional so far.
  int _activeSystem = 0;

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
      body: Row(
        children: [
          _SystemTabRail(
            activeIndex: _activeSystem,
            onSelect: (i) => setState(() => _activeSystem = i),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: switch (_activeSystem) {
              0 => _ProjectTabBody(controller: _controller, readOnly: widget.readOnly),
              1 => _buildPvBody(),
              _ => const _SystemPlaceholder(),
            },
          ),
        ],
      ),
    );
  }

  /// The PV planning surface: roof canvas + control panel (wide) or canvas
  /// with a bottom-sheet panel (narrow). Unchanged from the pre-tab layout.
  Widget _buildPvBody() {
    final isWide = MediaQuery.sizeOf(context).width > 900;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (isWide) {
          // Clamp to the space actually available: dragging the panel wider
          // than (window - rail) - handle - canvas minimum would overflow.
          final maxPanelWidth = MediaQuery.sizeOf(context).width -
              _railWidth -
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

/// The four systems a project can contain (see data/systemuebersicht/
/// komponenten.md: PV, BAT/WB/WP). Only the PV tab is functional so far;
/// the rest are placeholders that will host their own planning UI later.
class _SystemTab {
  final String label;
  final IconData icon;

  const _SystemTab(this.label, this.icon);

  static const List<_SystemTab> all = [
    _SystemTab('Projekt', Icons.folder_special),
    _SystemTab('PV', Icons.wb_sunny),
    _SystemTab('Batteriespeicher', Icons.battery_charging_full),
    _SystemTab('Wallbox', Icons.electric_car),
    _SystemTab('Wärmepumpe', Icons.thermostat),
  ];
}

/// Vertical tab rail pinned to the left edge of the window. Selecting a row
/// switches the main content area between system tabs. The active tab gets a
/// slim colored accent bar, mirroring the roof-selection rows in the panel.
class _SystemTabRail extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const _SystemTabRail({required this.activeIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _EditorScreenState._railWidth,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          for (var i = 0; i < _SystemTab.all.length; i++)
            _railItem(context, i),
        ],
      ),
    );
  }

  Widget _railItem(BuildContext context, int index) {
    final tab = _SystemTab.all[index];
    final selected = index == activeIndex;
    return InkWell(
      onTap: () => onSelect(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 28,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              tab.icon,
              size: 18,
              color:
                  selected ? Theme.of(context).primaryColor : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tab.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty content area shown for system tabs that are not implemented yet.
class _SystemPlaceholder extends StatelessWidget {
  const _SystemPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Noch in Arbeit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Dieses System wird noch nicht geplant.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// Body of the "Projekt" tab: project identity, site conditions (VDE),
/// and system toggles. Replaces the old _ProjectSection that was embedded
/// in the PV control panel.
class _ProjectTabBody extends StatelessWidget {
  final EditorController controller;
  final bool readOnly;

  const _ProjectTabBody({required this.controller, required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.project;
        if (p == null) return const SizedBox.shrink();
        final coord = '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Identität & Standort ───────────────────────────────
            const _SectionTitle('Identität'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (p.address.isNotEmpty)
                        Text(p.address, style: const TextStyle(fontSize: 13)),
                      Text(coord, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                if (!readOnly)
                  IconButton(
                    key: const ValueKey('project-edit-button'),
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Projekt-Eigenschaften bearbeiten',
                    onPressed: () async {
                      final result = await showProjectPropertiesDialog(context, p);
                      if (result != null) {
                        await ProjectPropertiesResult.apply(controller, result);
                      }
                    },
                  ),
              ],
            ),

            const Divider(),

            // ── Systemübersicht (Diagramm) ───────────────────────
            const _SectionTitle('Systemübersicht'),
            Container(
              width: double.infinity,
              height: 560,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _SystemOverview(
                pvActive: p.pvAnlage,
                batActive: p.batAnlage,
                wbActive: p.wbAnlage,
                wpActive: p.wpAnlage,
              ),
            ),

            const Divider(),

            // ── Hausanschluss & Erdung (VDE-Prüfungen) ───────────
            _SiteConditions(controller: controller, readOnly: readOnly),

            const Divider(),

            // ── Systeme ────────────────────────────────────────────
            const _SectionTitle('Systeme'),
            Text(
              'Hier aktivieren oder deaktivieren Sie die geplanten Systeme.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),

            _SystemToggleRow(
              icon: Icons.wb_sunny,
              label: 'PV-Anlage',
              enabled: p.pvAnlage,
              detail: p.pvKwp > 0 ? '${p.pvKwp.toStringAsFixed(1)} kWp geplant' : 'Keine Planung',
              onChanged: readOnly ? null : (v) => controller.updateProjectProperties(pvAnlage: v),
            ),
            _SystemToggleRow(
              icon: Icons.battery_charging_full,
              label: 'Batteriespeicher',
              enabled: p.batAnlage,
              detail: p.batKwh > 0 ? '${p.batKwh.toStringAsFixed(1)} kWh' : 'Keine Planung',
              onChanged: readOnly ? null : (v) => controller.updateProjectProperties(batAnlage: v),
            ),
            _SystemToggleRow(
              icon: Icons.electric_car,
              label: 'Wallbox',
              enabled: p.wbAnlage,
              detail: p.wbKw > 0 ? '${p.wbKw.toStringAsFixed(1)} kW' : 'Keine Planung',
              onChanged: readOnly ? null : (v) => controller.updateProjectProperties(wbAnlage: v),
            ),
            _SystemToggleRow(
              icon: Icons.thermostat,
              label: 'Wärmepumpe',
              enabled: p.wpAnlage,
              detail: p.wpKw > 0 ? '${p.wpKw.toStringAsFixed(1)} kW' : 'Keine Planung',
              onChanged: readOnly ? null : (v) => controller.updateProjectProperties(wpAnlage: v),
            ),
          ],
        );
      },
    );
  }
}

/// Hausanschluss & Erdung settings (VDE-Prüfungen).
///
/// Shows grid phase selection, max feed-in limit, and grounding flags.
class _SiteConditions extends StatefulWidget {
  final EditorController controller;
  final bool readOnly;

  const _SiteConditions({required this.controller, required this.readOnly});

  @override
  State<_SiteConditions> createState() => _SiteConditionsState();
}

class _SiteConditionsState extends State<_SiteConditions> {
  late final TextEditingController _feedIn =
      TextEditingController(text: widget.controller.project?.maxFeedInKw
          ?.toStringAsFixed(1) ??
          '');

  @override
  void dispose() {
    _feedIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final p = c.project;
        if (p == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Hausanschluss & Erdung'),
            Text(
              'VDE-relevante Standortparameter für die Planungsprüfungen.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),

            // Grid phases + max feed-in (side by side)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: p.gridPhases,
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
                      labelText: 'Max. Einspeisung (kW)',
                      isDense: true,
                    ),
                    enabled: !widget.readOnly,
                    onSubmitted: (v) => c.updateSiteConditions(
                        maxFeedInKw:
                            v.trim().isEmpty ? null : double.tryParse(v.trim())),
                  ),
                ),
              ],
            ),

            // Grounding / equipotential switches
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title:
                  const Text('Haupt-Potenzialausgleich', style: TextStyle(fontSize: 13)),
              value: p.hasMainEquipotential,
              onChanged:
                  widget.readOnly ? null : (v) => c.updateSiteConditions(hasMainEquipotential: v),
            ),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title:
                  const Text('Schraubmontage', style: TextStyle(fontSize: 13)),
              value: p.isBoltedMounting,
              onChanged:
                  widget.readOnly ? null : (v) => c.updateSiteConditions(isBoltedMounting: v),
            ),
          ],
        );
      },
    );
  }
}

/// A single system toggle row with icon, label, detail text and a switch.
class _SystemToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final String detail;
  final ValueChanged<bool>? onChanged;

  const _SystemToggleRow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.detail,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Theme.of(context).primaryColor : Colors.grey.shade400;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        secondary: Icon(icon, color: color),
        title: Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: enabled ? FontWeight.w600 : FontWeight.normal)),
        subtitle: Text(detail, style: const TextStyle(fontSize: 12)),
        value: enabled,
        onChanged: onChanged,
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

// ────────────────────────────────────────────────────────────────
//  System overview diagram (matches data/systemuebersicht/Systemuebersicht.png)
// ────────────────────────────────────────────────────────────────

/// Interactive system overview diagram using a [Stack] of icon tiles plus
/// a custom painter for the connecting wires.
///
/// Layout (proportional to available space):
///
/// ```text
///   PV-Module ──┐                    INTERNET          ÖFFENTLICHES
///               ▼                         │             STROMNETZ
///   Generator ── Wechsler.                Router               Zähler
///               │                         │                    │
///   ────────────┴─────────────────────────┴────────────────────┘  ← AC-Bus
///               │         │          │           │
///            Batterie    Wallbox   Verbraucher  Wärmepumpe
/// ```
class _SystemOverview extends StatelessWidget {
  final bool pvActive;
  final bool batActive;
  final bool wbActive;
  final bool wpActive;

  const _SystemOverview({
    required this.pvActive,
    required this.batActive,
    required this.wbActive,
    required this.wpActive,
  });

  static const _active = Color(0xFF4CAF50);
  static const _inactive = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Column x-centers (proportional)
        final pvX = w * 0.14;
        final batX = w * 0.32;
        final wbX = w * 0.50;
        final wpX = w * 0.68;
        final gridX = w * 0.88;

        // Row y-centers (proportional)
        final topY = h * 0.16;
        final midY = h * 0.48; // AC bus line
        const tileSize = 52.0;

        Color c(bool active) => active ? _active : _inactive;

        Widget tile({
          required IconData icon,
          required String label,
          required bool active,
        }) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: c(active), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 28, color: c(active)),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 9, color: c(active)),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        return Stack(
          children: [
            // Connecting lines (behind tiles)
            Positioned.fill(
              child: CustomPaint(
                painter: _SystemOverviewPainter(
                  pvActive: pvActive,
                  batActive: batActive,
                  wbActive: wbActive,
                  wpActive: wpActive,
                ),
              ),
            ),

            // ── Top row: PV modules, Internet/Grid ──────────────
            Positioned(
              left: pvX - tileSize / 2,
              top: topY - tileSize / 2 - 14,
              child: tile(
                icon: Icons.brightness_medium_rounded,
                label: 'PV-Module',
                active: pvActive,
              ),
            ),

            // ── Middle row: Inverter, Battery, Wallbox, WP, Grid ─
            Positioned(
              left: pvX - tileSize / 2,
              top: midY - tileSize / 2 - 14,
              child: tile(
                icon: Icons.electric_bolt_rounded,
                label: 'Wechselrichter',
                active: pvActive,
              ),
            ),

            Positioned(
              left: batX - tileSize / 2,
              top: midY + h * 0.18 - tileSize / 2,
              child: tile(
                icon: Icons.battery_charging_full_rounded,
                label: 'Batterie',
                active: batActive,
              ),
            ),

            Positioned(
              left: wbX - tileSize / 2,
              top: midY + h * 0.18 - tileSize / 2,
              child: tile(
                icon: Icons.ev_station_rounded,
                label: 'Wallbox',
                active: wbActive,
              ),
            ),

            Positioned(
              left: wpX - tileSize / 2,
              top: midY + h * 0.18 - tileSize / 2,
              child: tile(
                icon: Icons.thermostat_rounded,
                label: 'Wärmepumpe',
                active: wpActive,
              ),
            ),

            Positioned(
              left: gridX - tileSize / 2,
              top: midY - tileSize / 2 - 14,
              child: tile(
                icon: Icons.electrical_services_rounded,
                label: 'Netz',
                active: true, // always on
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Draws only the connecting lines between tiles in [_SystemOverview].
/// Tile positions must match the shared layout constants used by both
/// the widget and this painter.
class _SystemOverviewPainter extends CustomPainter {
  final bool pvActive;
  final bool batActive;
  final bool wbActive;
  final bool wpActive;

  const _SystemOverviewPainter({
    required this.pvActive,
    required this.batActive,
    required this.wbActive,
    required this.wpActive,
  });

  static const _active = Color(0xFF4CAF50);
  static const _inactive = Colors.grey;

  // ── Shared layout constants (must match _SystemOverview) ─────
  static const pvXf = 0.14;
  static const batXf = 0.32;
  static const wbXf = 0.50;
  static const wpXf = 0.68;
  static const gridXf = 0.88;
  static const topYf = 0.16;
  static const midYf = 0.48;
  static const botYf = 0.68;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tile centers (same as _SystemOverview)
    final pvX = w * pvXf;
    final batX = w * batXf;
    final wbX = w * wbXf;
    final wpX = w * wpXf;
    final gridX = w * gridXf;
    final topY = h * topYf;
    final midY = h * midYf;
    final botY = h * botYf;

    // Tile half-height (tile is 52×52, label adds ~14px below)
    const halfTile = 26.0;

    // ── AC bus bar (horizontal, at midY) ─────────────────────
    final acPaint = Paint()
      ..strokeWidth = 3
      ..color = Colors.black87;
    canvas.drawLine(Offset(pvX, midY), Offset(gridX, midY), acPaint);

    // ── PV: modules (top) → inverter position on bus ─────────
    final pvColor = pvActive ? _active : _inactive;
    // Vertical line from PV tile bottom to bus
    final pvDown = Paint()
      ..strokeWidth = 2
      ..color = pvColor;
    canvas.drawLine(Offset(pvX, topY + halfTile), Offset(pvX, midY), pvDown);

    // ── Battery: tile bottom → bus (AC coupled) ───────────────
    final batColor = batActive ? _active : _inactive;
    canvas.drawLine(Offset(batX, topY + halfTile), Offset(batX, midY),
        Paint()..strokeWidth = 2..color = batColor);

    // ── Wallbox: bus → tile top (AC) ─────────────────────────
    final wbColor = wbActive ? _active : _inactive;
    canvas.drawLine(Offset(wbX, midY), Offset(wbX, botY - halfTile),
        Paint()..strokeWidth = 2..color = wbColor);

    // ── Heat pump: bus → tile top (AC) ───────────────────────
    final wpColor = wpActive ? _active : _inactive;
    canvas.drawLine(Offset(wpX, midY), Offset(wpX, botY - halfTile),
        Paint()..strokeWidth = 2..color = wpColor);

    // ── Grid: bus → tile (right side) ────────────────────────
    canvas.drawLine(Offset(gridX, midY), Offset(w - 12, midY),
        Paint()..strokeWidth = 3..color = Colors.black87);

    // ── "AC 3~" label above the bus bar ───────────────────────
    final acLabel = TextPainter(
      text: const TextSpan(
        text: 'AC 3~',
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    acLabel.paint(
        canvas, Offset((pvX + gridX) / 2 - acLabel.width / 2, midY - 18));

    // ── Legend (bottom-center) ────────────────────────────────
    final legendY = h - 14.0;
    canvas.drawCircle(Offset(w * 0.35, legendY), 4,
        Paint()..color = _active);
    final aktivLabel = TextPainter(
      text: const TextSpan(text: 'aktiv', style: TextStyle(fontSize: 9)),
      textDirection: TextDirection.ltr,
    )..layout();
    aktivLabel.paint(canvas, Offset(w * 0.35 + 8, legendY - 6));
    canvas.drawCircle(Offset(w * 0.52, legendY), 4,
        Paint()..color = _inactive);
    final inaktivLabel = TextPainter(
      text: const TextSpan(text: 'inaktiv', style: TextStyle(fontSize: 9)),
      textDirection: TextDirection.ltr,
    )..layout();
    inaktivLabel.paint(canvas, Offset(w * 0.52 + 8, legendY - 6));
  }

  @override
  bool shouldRepaint(covariant _SystemOverviewPainter oldDelegate) =>
      pvActive != oldDelegate.pvActive ||
          batActive != oldDelegate.batActive ||
      wbActive != oldDelegate.wbActive ||
          wpActive != oldDelegate.wpActive;
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
