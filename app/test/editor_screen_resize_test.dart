import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/features/editor/editor_screen.dart';

/// Regression tests for the draggable divider between canvas and control
/// panel: dragging its left edge resizes the right pane, with 340 px as the
/// minimum width.
void main() {
  const handleKey = ValueKey('panel-resize-handle');

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.projects).insert(ProjectsCompanion.insert(
      name: 'Testprojekt',
      createdAt: 0,
      updatedAt: 0,
    ));
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

  /// The panel is the widest finite fixed-width SizedBox in the wide layout
  /// (the control panel contains `SizedBox(width: double.infinity)` children).
  double panelWidth(WidgetTester tester) {
    final widths = find.byType(SizedBox).evaluate()
        .map((e) => (e.widget as SizedBox).width ?? 0)
        .where((w) => w.isFinite && w >= 340);
    return widths.reduce(max);
  }

  testWidgets('dragging the handle left widens the panel', (tester) async {
    // Wide layout so the control panel is a side pane.
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();

    expect(find.byKey(handleKey), findsOneWidget);

    // Hovering the handle shows the resize cursor (MouseRegion reverts to
    // the default cursor automatically when the pointer leaves).
    final mouseRegion = tester.widget<MouseRegion>(
      find.ancestor(
        of: find.byKey(handleKey),
        matching: find.byType(MouseRegion),
      ).first,
    );
    expect(mouseRegion.cursor, SystemMouseCursors.resizeLeftRight);

    expect(panelWidth(tester), 340.0);

    // Drag the handle left by 120 px → panel widens to 460.
    await tester.drag(find.byKey(handleKey), const Offset(-120, 0));
    await tester.pumpAndSettle();

    expect(panelWidth(tester), 460.0);
  });

  testWidgets('dragging the handle right clamps at the minimum width', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();

    // Widen first, then drag far right — must stop at the 340 minimum.
    await tester.drag(find.byKey(handleKey), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(panelWidth(tester), 540.0);

    await tester.drag(find.byKey(handleKey), const Offset(1000, 0));
    await tester.pumpAndSettle();

    expect(panelWidth(tester), 340.0);
  });

  testWidgets('widening beyond the window clamps instead of overflowing',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();

    // Drag far left: the panel may only grow to window - handle - canvas min.
    await tester.drag(find.byKey(handleKey), const Offset(-2000, 0));
    await tester.pumpAndSettle();

    // No RenderFlex overflow exception may have been reported.
    expect(tester.takeException(), isNull);
    expect(panelWidth(tester), 1400.0 - 8.0 - 200.0);
  });
}
