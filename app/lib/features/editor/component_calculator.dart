/// Component calculator for heat pump systems.
///
/// Evaluates formulas from `komponenten.md` §3 and computes per-system
/// completeness for a given project.
library;

import 'package:drift/drift.dart';
import '../../db/database.dart';
import '../../db/tables.dart' show ComponentType, ComponentTypeExt;

/// Result of evaluating a single component's formula.
class ComponentCalculation {
  final ComponentType type;
  final int quantity;
  final Map<String, dynamic> formulaResult;
  final List<String> warnings;

  const ComponentCalculation({
    required this.type,
    required this.quantity,
    this.formulaResult = const {},
    this.warnings = const [],
  });
}

/// Per-system completeness status.
class SystemCompleteness {
  final String systemName;
  final int totalComponents;
  final int completedComponents;
  final List<String> warnings;

  const SystemCompleteness({
    required this.systemName,
    required this.totalComponents,
    required this.completedComponents,
    this.warnings = const [],
  });

  double get completionPct =>
      totalComponents == 0 ? 0.0 : completedComponents / totalComponents;
}

/// Calculates heat pump component quantities and system completeness.
class ComponentCalculator {
  final AppDatabase db;

  const ComponentCalculator(this.db);

  /// Returns calculations for all 28 component types for a project.
  Future<Map<ComponentType, ComponentCalculation>> calculate(int projectId) async {
    final result = <ComponentType, ComponentCalculation>{};

    // Fetch project parameters once.
    final project = await (db.select(db.projects)
          ..where((t) => t.id.equals(projectId)))
        .getSingleOrNull();

    // Get all component statuses for this project.
    final statuses = await (db.select(db.componentStatusTable)
          ..where((t) => t.projectId.equals(projectId)))
        .get();

    // Get all inventory items.
    final allItems = await db.select(db.inventoryItems).get();

    // Build a map from inventory item id to status for quick lookup.
    final statusMap = <int, ComponentStatusTableData>{};
    for (final s in statuses) {
      statusMap[s.inventoryItemId] = s;
    }

    for (final item in allItems) {
      final type = _parseComponentType(item.componentType);
      if (type == null) continue;

      final status = statusMap[item.id];
      if (status == null) {
        // No status row yet — use defaults from formula.
        final calc = await _calculateSingle(
          type, _emptyStatus(), item,
          personen: project?.personen,
          etagen: project?.etagen,
          keller: project?.keller,
          baeder: project?.baeder,
          kuechen: project?.kuechen,
          fbhZonen: project?.fbhZonen,
          radiatoren: project?.radiatoren,
          garten: project?.garten,
          wpKw: project?.wpKw,
          hwSchleifeM: project?.hwSchleifeM,
          wpAnlage: project?.wpAnlage,
        );
        result[type] = calc;
      } else {
        final calc = await _calculateSingle(
          type, status, item,
          personen: project?.personen,
          etagen: project?.etagen,
          keller: project?.keller,
          baeder: project?.baeder,
          kuechen: project?.kuechen,
          fbhZonen: project?.fbhZonen,
          radiatoren: project?.radiatoren,
          garten: project?.garten,
          wpKw: project?.wpKw,
          hwSchleifeM: project?.hwSchleifeM,
          wpAnlage: project?.wpAnlage,
        );
        result[type] = calc;
      }
    }

    // Ensure all 28 component types are represented.
    for (final type in ComponentType.values) {
      if (!result.containsKey(type)) {
        result[type] = ComponentCalculation(
          type: type,
          quantity: 0,
          warnings: ['Kein Status zugewiesen'],
        );
      }
    }

    return result;
  }

  /// Returns an empty ComponentStatusTableData with defaults.
  ComponentStatusTableData _emptyStatus() {
    return ComponentStatusTableData(
      id: 0,
      projectId: 0,
      inventoryItemId: 0,
      status: 'Offen',
      required: false,
      quantity: 0,
    );
  }

  /// Returns per-system completeness for a project.
  Future<Map<String, SystemCompleteness>> getSystemCompleteness(
      int projectId) async {
    // Group by system.
    final wpComponents = <ComponentType>[];

    for (final type in ComponentType.values) {
      final id = type.idString;
      if (id.startsWith('HYD')) {
        wpComponents.add(type);
      } else if (id.startsWith('ELE.STK') || id.startsWith('ELE.SCH')) {
        wpComponents.add(type);
      }
    }

    final results = await Future.wait([
      _computeSystemCompleteness('PV-Anlage', const <ComponentType>[], projectId),
      _computeSystemCompleteness('Batteriespeicher', const <ComponentType>[], projectId),
      _computeSystemCompleteness('Wallbox', const <ComponentType>[], projectId),
      _computeSystemCompleteness('Wärmepumpe', wpComponents, projectId),
    ]);
    return {
      'PV': results[0],
      'BAT': results[1],
      'WB': results[2],
      'WP': results[3],
    };
  }

  Future<SystemCompleteness> _computeSystemCompleteness(
    String systemName,
    List<ComponentType> types,
    int projectId,
  ) async {
    final calculations = await calculate(projectId);
    final warnings = <String>[];
    int completed = 0;

    for (final type in types) {
      final calc = calculations[type];
      if (calc == null) {
        warnings.add('${type.displayName}: Kein Status');
        continue;
      }
      if (calc.quantity > 0) {
        final statuses = await (db.select(db.componentStatusTable)
              ..where((t) =>
                  t.projectId.equals(projectId) &
                  t.inventoryItemId
                      .equals(calc.formulaResult['inventoryItemId'] as int? ?? 0)))
            .getSingleOrNull();
        if (statuses != null &&
            (statuses.status == 'Eingebaut' ||
                statuses.status == 'In Planung')) {
          completed += calc.quantity;
        }
        if (statuses != null && statuses.status == 'Offen') {
          warnings.add('${type.displayName}: Offen (Pflichtkomponente)');
        }
      }
    }

    return SystemCompleteness(
      systemName: systemName,
      totalComponents: types.length,
      completedComponents: completed,
      warnings: warnings,
    );
  }

  /// Evaluates the formula for a single component type.
  Future<ComponentCalculation> _calculateSingle(
    ComponentType type,
    ComponentStatusTableData status,
    InventoryItem item, {
    int? personen,
    int? etagen,
    bool? keller,
    int? baeder,
    int? kuechen,
    int? fbhZonen,
    bool? radiatoren,
    bool? garten,
    double? wpKw,
    int? hwSchleifeM,
    bool? wpAnlage,
  }) async {
    // Defaults for missing project params.
    final k = keller ?? true;
    final b = baeder ?? 2;
    final kch = kuechen ?? 1;
    final fz = fbhZonen ?? 4;
    final rad = radiatoren ?? false;
    final g = garten ?? true;
    final hwS = hwSchleifeM ?? 28;
    final wpOn = wpAnlage ?? false;

    // Helper: read quantity from status or default to 0.
    int qty(int fallback) => status.quantity > 0 ? status.quantity : fallback;

    switch (type) {
      // ---- Hydraulische Komponenten ----

      case ComponentType.boilerTww:
        // Min: 1, Max: 1 + (etagen > 2 ? 1 : 0)
        return ComponentCalculation(
          type: type,
          quantity: qty(1),
          formulaResult: {
            'formula': 'Boiler_TWW = 1 + (etagen > 2 ? 1 : 0)',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.hwVerteiler:
        // Min: 1, Max: etagen + keller
        return ComponentCalculation(
          type: type,
          quantity: qty(1),
          formulaResult: {
            'formula': 'HW_Verteiler = 1 .. (etagen + keller)',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.zirkulationspumpe:
        // Min: hwSchleifeM > 15 ? 1 : 0, Max: etagen + keller
        final minZirk = hwS > 15 ? 1 : 0;
        return ComponentCalculation(
          type: type,
          quantity: qty(minZirk),
          formulaResult: {
            'formula': 'Zirkulationspumpe = hwSchleifeM > 15 ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.rueckflussverhinderer:
        // Min: wpAnlage ? 1 : 0, Max: Waermepumpe + garten
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'Rueckflussverhinderer = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.schmutzfanger:
        // Min: wpAnlage ? 1 : 0, Max: Waermepumpe + garten
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'Schmutzfänger = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.durchflusswaechter:
        // Min: wpAnlage ? 1 : 0, Max: Waermepumpe
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'Durchflusswächter = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.pufferspeicher:
        // Min: radiatoren ? 1 : (fbhZonen > 6 ? 1 : 0),
        // Max: Waermepumpe + radiatoren
        final minPuffer = rad ? 1 : (fz > 6 ? 1 : 0);
        return ComponentCalculation(
          type: type,
          quantity: qty(minPuffer),
          formulaResult: {
            'formula': 'Pufferspeicher = radiatoren ? 1 : (fbhZonen > 6 ? 1 : 0)',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.plattenwaermetauscher:
        // Min: Pufferspeicher, Max: Pufferspeicher (1:1)
        final pufferQty = rad ? 1 : (fz > 6 ? 1 : 0);
        return ComponentCalculation(
          type: type,
          quantity: qty(pufferQty),
          formulaResult: {
            'formula': 'Plattenwärmetauscher = Pufferspeicher (1:1)',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.safetyValve:
        // Min: (Waermepumpe - Hydraulikstation) + (radiatoren ? 1 : 0) + (Pufferspeicher > 0 ? 1 : 0)
        // Simplified: wpAnlage + radiatoren + pufferspeicher
        final minSv = (wpOn ? 1 : 0) + (rad ? 1 : 0) + (pufferspeicherQty(rad, fz));
        return ComponentCalculation(
          type: type,
          quantity: qty(minSv),
          formulaResult: {
            'formula': 'Sicherheitsventil = wpAnlage + radiatoren + (Pufferspeicher > 0 ? 1 : 0)',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.membranausdehnungsgefaess:
        // Min: same as safety valve, Max: = Sicherheitsventil_3bar
        final minMag = (wpOn ? 1 : 0) + (rad ? 1 : 0) + pufferspeicherQty(rad, fz);
        return ComponentCalculation(
          type: type,
          quantity: qty(minMag),
          formulaResult: {
            'formula': 'MAG = Sicherheitsventil_3bar (1:1)',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.entluftungsventil:
        // Min: (Waermepumpe - Hydraulikstation) + radiatoren + ceil(fbhZonen / 4)
        final minEv = (wpOn ? 1 : 0) + (rad ? 1 : 0) + ((fz + 3) ~/ 4);
        return ComponentCalculation(
          type: type,
          quantity: qty(minEv),
          formulaResult: {
            'formula': 'Entlüftungsventil = wpAnlage + radiatoren + ceil(fbhZonen / 4)',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.heizkreispumpe:
        // Min: (Waermepumpe - Hydraulikstation) + radiatoren
        final minHkp = (wpOn ? 1 : 0) + (rad ? 1 : 0);
        return ComponentCalculation(
          type: type,
          quantity: qty(minHkp),
          formulaResult: {
            'formula': 'Heizkreispumpe = wpAnlage + radiatoren',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.absperrventil:
        // Min: 2 × Pumpe_Heizkreis, Max: 2 × (Waermepumpe + radiatoren)
        final pumpQty = (wpOn ? 1 : 0) + (rad ? 1 : 0);
        final minAv = pumpQty * 2;
        return ComponentCalculation(
          type: type,
          quantity: qty(minAv),
          formulaResult: {
            'formula': 'Absperrventil = 2 × Pumpe_Heizkreis',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.fbhVerteiler:
        // Min: 1, Max: etagen + keller
        return ComponentCalculation(
          type: type,
          quantity: qty(1),
          formulaResult: {
            'formula': 'FBH-Verteiler = 1 .. (etagen + keller)',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.fbhSchleife:
        // Min: fbhZonen, Max: fbhZonen × 2
        return ComponentCalculation(
          type: type,
          quantity: qty(fz),
          formulaResult: {
            'formula': 'FBH-Schleife = fbhZonen .. (fbhZonen × 2)',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.mischbatterie:
        // Min: baeder + kuechen, Max: (baeder + kuechen) × (etagen + keller)
        final minMb = b + kch;
        return ComponentCalculation(
          type: type,
          quantity: qty(minMb),
          formulaResult: {
            'formula': 'Mischbatterie = baeder + kuechen',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.rfvGartenanschluss:
        // Min: garten, Max: garten × 3
        return ComponentCalculation(
          type: type,
          quantity: qty(g ? 1 : 0),
          formulaResult: {
            'formula': 'RFV Garten = garten ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.fuellwasserZuleitung:
        // Min: wpAnlage ? 1 : 0, Max: Waermepumpe + radiatoren
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'Füllwasser-Zuleitung = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.kaltwasserVerbraucher:
        // Min: kuechen + keller, Max: (baeder + kuechen) × 2 + garten
        final minKw = kch + (k ? 1 : 0);
        return ComponentCalculation(
          type: type,
          quantity: qty(minKw),
          formulaResult: {
            'formula': 'KW-Verbraucher = kuechen + keller',
            'inventoryItemId': item.id,
          },
        );

      // ---- Elektrische Komponenten ----

      case ComponentType.lsSchalter:
        // Min: wpAnlage ? 1 : 0, Max: = lsSchalter (1:1)
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'LS-Schalter WP = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.fiSchutzschalter:
        // Min: wpAnlage ? 1 : 0, Max: = lsSchalter (1:1)
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'FI-Schutzschalter = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.zuleitungStarkstrom:
        // Min: wpAnlage ? 1 : 0, Max: = lsSchalter (1:1)
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'Zuleitung Starkstrom = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.trennschalter:
        // Min: wpAnlage ? 1 : 0, Max: = lsSchalter (1:1)
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'Trennschalter = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.klemmenleiste:
        // Min: wpAnlage ? 1 : 0, Max: = lsSchalter (1:1)
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'Klemmenleiste = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.peAnschluss:
        // Min: wpAnlage ? 1 : 0, Max: = lsSchalter (1:1)
        return ComponentCalculation(
          type: type,
          quantity: qty(wpOn ? 1 : 0),
          formulaResult: {
            'formula': 'PE-Anschluss = wpAnlage ? 1 : 0',
            'inventoryItemId': item.id,
          },
        );

      case ComponentType.hpaAnschluss:
        // Min: 1, Max: etagen + keller
        return ComponentCalculation(
          type: type,
          quantity: qty(1),
          formulaResult: {
            'formula': 'HPA-Anschluss = 1 .. (etagen + keller)',
            'inventoryItemId': item.id,
          },
        );
    }
  }

  /// Helper: returns the pufferspeicher quantity based on project params.
  int pufferspeicherQty(bool radiatoren, int fbhZonen) {
    return radiatoren ? 1 : (fbhZonen > 6 ? 1 : 0);
  }



  ComponentType? _parseComponentType(String componentType) {
    for (final type in ComponentType.values) {
      if (type.idString == componentType) return type;
    }
    return null;
  }
}
