// ignore: unused_import
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/core/geo.dart' show Pt;
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/db/tables.dart' show RoofType, TileMaterial;
import 'package:solar_planner/features/editor/editor_controller.dart';
import 'package:solar_planner/features/editor/roof_canvas.dart';



void main() {
  late AppDatabase db;
  late EditorController c;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.projects).insert(ProjectsCompanion.insert(
      name: 'Testprojekt',
      createdAt: 0,
      updatedAt: 0,
    ));

    c = EditorController(db: db, projectId: 1, readOnly: false);

    // Add a roof so the canvas has something to draw.
    await c.addRoof(RoofFormResult(
      name: 'Sichtbares Dach',
      lengthM: 10.0,
      widthM: 5.0,
      pitchDeg: 30.0,
      azimuthDeg: 180,
      type: RoofType.pitched,
      rafterStraight: true,
      hasCounterBatten: false,
      tileMaterial: TileMaterial.clay,
      hasSpareTiles: false,
      hasInsulation: false,
    ));
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('canvas renders without exceptions', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: RoofCanvas(controller: c)),
      ),
    ));

    // Pump a few frames to let the canvas paint.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // No exceptions should have been thrown.
    expect(tester.takeException(), isNull);

    // The canvas should be present in the widget tree.
    expect(find.byType(RoofCanvas), findsOneWidget);

    // The zoom buttons should be visible.
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.fit_screen), findsOneWidget);

    // The compass rose should be present (it's a CustomPaint).
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('canvas shows zoom controls and compass', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: RoofCanvas(controller: c)),
      ),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Zoom in button.
    expect(find.byTooltip('Hineinzoomen'), findsOneWidget);
    // Zoom out button.
    expect(find.byTooltip('Herauszoomen'), findsOneWidget);
    // Fit button.
    expect(find.byTooltip('Ansicht anpassen'), findsOneWidget);

    // No exceptions.
    expect(tester.takeException(), isNull);
  });

  testWidgets('zoom in and out buttons work', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: RoofCanvas(controller: c)),
      ),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap zoom in.
    await tester.tap(find.byTooltip('Hineinzoomen'));
    await tester.pumpAndSettle();

    // Tap zoom out.
    await tester.tap(find.byTooltip('Herauszoomen'));
    await tester.pumpAndSettle();

    // No exceptions.
    expect(tester.takeException(), isNull);
  });

  testWidgets('fit button works without exceptions', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: RoofCanvas(controller: c)),
      ),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap fit.
    await tester.tap(find.byTooltip('Ansicht anpassen'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('canvas with no roofs renders without exceptions', (tester) async {
    // Use a fresh controller with no roofs.
    final emptyC = EditorController(db: db, projectId: 1, readOnly: false);
    await emptyC.load();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: RoofCanvas(controller: emptyC)),
      ),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.byType(RoofCanvas), findsOneWidget);

    emptyC.dispose();
  });

  testWidgets('canvas repaints when controller notifies', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: RoofCanvas(controller: c)),
      ),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Trigger a notification (e.g., select the roof).
    c.selectedRoofId = c.roofs.first.id;
    c.notifyNow();

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });

  testWidgets('dragging a roof on the canvas moves it (gesture wiring)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: RoofCanvas(controller: c)),
      ),
    ));

    // Let the canvas paint and auto-fit so the roof is on screen.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final roofBefore = Pt.decode(c.roofs.first.polygon);
    expect(roofBefore, isNotEmpty);

    // The canvas fills the 800x600 test surface. After _fitView the roof is
    // centered, so dragging from the center of the canvas starts on the roof.
    final start = tester.getCenter(find.byType(RoofCanvas));

    // Simulate a real single-pointer drag: press, move in small steps (so the
    // scale recognizer reports updates), release.
    final gesture = await tester.startGesture(start);
    for (var i = 1; i <= 5; i++) {
      await gesture.moveBy(const Offset(20, 10));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));

    // The roof must have moved (world delta = screen delta / zoom).
    final roofAfter = Pt.decode(c.roofs.first.polygon);
    final dxWorld =
        (roofAfter[0].x - roofBefore[0].x).abs();
    final dyWorld = (roofAfter[0].y - roofBefore[0].y).abs();
    expect(dxWorld + dyWorld, greaterThan(1e-6),
        reason: 'dragging on the roof should move it');

    expect(tester.takeException(), isNull);
  });

  testWidgets('dragging on whitespace in select mode pans the canvas',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(child: RoofCanvas(controller: c)),
      ),
    ));

    // Let the canvas paint and auto-fit so the roof is centered.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // The roof is centered after _fitView, so a corner of the canvas is empty
    // space. Dragging there must pan (not move any object).
    // Top-left corner, well away from the centered roof.
    final start = Offset(20, 20);

    // Capture the roof position to confirm it does NOT move.
    final roofBefore = Pt.decode(c.roofs.first.polygon);

    // Simulate a single-pointer drag on whitespace.
    final gesture = await tester.startGesture(start);
    for (var i = 1; i <= 5; i++) {
      await gesture.moveBy(const Offset(30, 20));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));

    // The roof must NOT have moved (we dragged whitespace, not the object).
    final roofAfter = Pt.decode(c.roofs.first.polygon);
    for (var i = 0; i < roofBefore.length; i++) {
      expect(roofAfter[i].x, closeTo(roofBefore[i].x, 1e-9),
          reason: 'whitespace drag must not move the roof');
      expect(roofAfter[i].y, closeTo(roofBefore[i].y, 1e-9));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('world painter is clipped to the canvas bounds', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SizedBox.expand(child: RoofCanvas(controller: c))),
    ));
    await tester.pump();

    // The world painter uses Size.infinite, so it must be directly wrapped in
    // a ClipRect — otherwise paint leaks onto sibling widgets (e.g. the
    // control panel next to the canvas).
    final infinitePaint = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.size == Size.infinite,
    );
    expect(infinitePaint, findsOneWidget);

    // First ancestor visited is the direct parent — it must be the ClipRect.
    final element = tester.element(infinitePaint);
    Element? directParent;
    element.visitAncestorElements((ancestor) {
      directParent = ancestor;
      return false; // stop after the first (direct) parent
    });
    expect(directParent!.widget, isA<ClipRect>());
  });
}
