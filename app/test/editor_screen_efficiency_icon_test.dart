import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/features/editor/editor_screen.dart';

import 'helpers.dart' show makeRoofCompanion;

/// Regression tests for the roof rows in the editor control panel:
///
/// 1. Every row exposes the efficiency-table icon (Icons.table_chart) and
///    tapping it opens the yield-efficiency dialog. This guard was added
///    after a UI refactor replaced `_roofEfficiencyRow` with the tappable
///    selection row and silently dropped the icon — no test covered it, so
///    nothing failed.
/// 2. Tapping a row selects it: the slim bar at the start of the row turns
///    from grey to the theme highlight color (single selection).
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.projects).insert(ProjectsCompanion.insert(
      name: 'Testprojekt',
      createdAt: 0,
      updatedAt: 0,
    ));
    await db.into(db.roofs).insert(makeRoofCompanion(projectId: 1));
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap(AppDatabase database) => MaterialApp(
        home: EditorScreen(
          db: database,
          projectId: 1,
          projectName: 'Testprojekt',
          readOnly: false,
        ),
      );

  /// Colors of the slim selection bars (4px-wide Containers with a
  /// BoxDecoration) currently in the tree.
  List<Color?> _barColors(WidgetTester tester) => tester
      .widgetList<Container>(find.byType(Container))
      .where((c) => c.decoration is BoxDecoration && (c.constraints?.maxWidth ?? double.infinity) <= 8)
      .map((c) => (c.decoration! as BoxDecoration).color)
      .toList();

  testWidgets('roof row shows efficiency-table icon and opens the dialog',
      (tester) async {
    // Wide layout so the control panel is always visible.
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(db));
    // Let the controller's initial load() finish.
    await tester.pumpAndSettle();

    // The icon is present on the roof row.
    final icon = find.byTooltip('Ertragstabelle (Ausrichtung & Neigung)');
    expect(icon, findsOneWidget);

    // Tapping it opens the efficiency table dialog.
    await tester.tap(icon);
    await tester.pumpAndSettle();

    expect(find.text('Ertrag nach Ausrichtung & Neigung'), findsOneWidget);
  });

  testWidgets('tapping the roof row selects it (slim bar turns highlight color)',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();

    // The selected bar uses primaryColor at 60% alpha (see _roofSelectionRow).
    final selectedBar = Theme.of(tester.element(find.byType(Scaffold)))
        .primaryColor
        .withValues(alpha: 0.6);

    // Before selection: no bar uses the highlight color.
    expect(_barColors(tester).where((c) => c == selectedBar), isEmpty);

    // Row is tappable via its label.
    await tester.tap(find.text('Testdach'));
    await tester.pumpAndSettle();

    // After selection: exactly one bar (the tapped row) is highlighted.
    expect(_barColors(tester).where((c) => c == selectedBar), hasLength(1));
  });
}
