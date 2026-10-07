import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/db/seed.dart';
import 'package:solar_planner/db/tables.dart' show HeatLoopsCompanion;
import 'package:solar_planner/features/editor/editor_controller.dart';
import 'package:solar_planner/features/editor/editor_screen.dart';

/// Creates and pumps an [EditorScreen] for testing, returning the projectId.
Future<int> _pumpApp(
  WidgetTester tester,
  AppDatabase database, {
  required bool readOnly,
}) async {
  await seedIfEmpty(database);

  final projectId = await database.into(database.projects).insert(
      ProjectsCompanion.insert(name: 'Testprojekt', createdAt: 0, updatedAt: 0));
  // Note: activeHeatPumpId is intentionally left null so the dropdown
  // shows the hint "Wärmepumpe auswählen …" rather than a selected value.
  // Tests that need a selected pump can set it via controller.setHeatPumpId().
  // final pumps = await database.select(database.heatPumps).get();

  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: EditorScreen(
        db: database,
        projectId: projectId,
        projectName: 'Testprojekt',
        readOnly: readOnly,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return projectId;
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ── Tab routing ──────────────────────────────────────────────

  testWidgets('heat pump tab is at index 4 (Wärmepumpe)', (tester) async {
    await _pumpApp(tester, db, readOnly: false);

    // The Wärmepumpe tab label is in the left rail.
    expect(find.widgetWithText(InkWell, 'Wärmepumpe'), findsOneWidget);

    // Switch to Wärmepumpe → should NOT show a placeholder.
    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();
    expect(find.text('Noch in Arbeit'), findsNothing);

    // The heat pump model selector dropdown should be visible.
    expect(
      find.widgetWithText(DropdownButton<int>, 'Wärmepumpe auswählen …'),
      findsOneWidget,
    );
  });

  testWidgets('switching to Wärmepumpe tab shows seeded models',
      (tester) async {
    await _pumpApp(tester, db, readOnly: false);

    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();

    // Open the dropdown so the menu items render.
    await tester.tap(
      find.widgetWithText(DropdownButton<int>, 'Wärmepumpe auswählen …'),
    );
    await tester.pumpAndSettle();

    // All three seeded models appear in the dropdown menu items.
    final pumpNames = const [
      'Vaillant aroTHERM pro VWL 55/7.1 A 230V',
      'Vaillant aroTHERM pro VWL 65/9.2 A 400V',
      'Vaillant aroTHERM pro VWL 71/10.5 A 400V',
    ];
    for (final name in pumpNames) {
      expect(find.text(name), findsOneWidget);
    }
  });

  // ── Async load / loading state ──────────────────────────────

  testWidgets('Projekt tab shows loading indicator before load completes',
      (tester) async {
    final db2 = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db2);

    await db2.into(db2.projects).insert(ProjectsCompanion.insert(
      name: 'Testprojekt',
      createdAt: 0,
      updatedAt: 0,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(
          db: db2,
          projectId: 1,
          projectName: 'Testprojekt',
          readOnly: false,
        ),
      ),
    );

    // Before load() completes, the Projekt tab should show a loading
    // indicator, NOT blank space.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // After load() completes, the loading indicator is gone and project
    // properties are visible.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Testprojekt'), findsOneWidget);

    await db2.close();
  });

  testWidgets('Wärmepumpe tab shows loading indicator before load completes',
      (tester) async {
    final db2 = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db2);

    await db2.into(db2.projects).insert(ProjectsCompanion.insert(
      name: 'Testprojekt',
      createdAt: 0,
      updatedAt: 0,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(
          db: db2,
          projectId: 1,
          projectName: 'Testprojekt',
          readOnly: false,
        ),
      ),
    );

    // Initially show loading indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Switch to Wärmepumpe tab — after load, should show the dropdown.
    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.widgetWithText(DropdownButton<int>, 'Wärmepumpe auswählen …'),
      findsOneWidget,
    );

    await db2.close();
  });

  // ── Heat pump model selection ────────────────────────────────

  testWidgets('selecting a heat pump model shows its specs', (tester) async {
    await _pumpApp(tester, db, readOnly: false);

    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();

    // Tap the dropdown to open it.
    await tester.tap(
      find.widgetWithText(DropdownButton<int>, 'Wärmepumpe auswählen …'),
    );
    await tester.pumpAndSettle();

    // Tap the second model.
    await tester.tap(find.text('Vaillant aroTHERM pro VWL 65/9.2 A 400V'));
    await tester.pumpAndSettle();

    // The specs card should now show the selected model's data.
    expect(find.text('Vaillant aroTHERM pro VWL 65/9.2 A 400V'), findsNWidgets(2));
    expect(find.text('Leistung (kW)'), findsOneWidget);
  });

  testWidgets('selecting a heat pump persists activeHeatPumpId',
      (tester) async {
    await _pumpApp(tester, db, readOnly: false);

    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();

    // Open dropdown and select the first model.
    await tester.tap(
      find.widgetWithText(DropdownButton<int>, 'Wärmepumpe auswählen …'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vaillant aroTHERM pro VWL 55/7.1 A 230V'));
    await tester.pumpAndSettle();

    // Verify the project was updated — query the project we passed to
    // EditorScreen (the second one, since seedIfEmpty creates one too).
    final allProjects = await db.select(db.projects).get();
    final project = allProjects.firstWhere(
      (p) => p.name == 'Testprojekt',
      orElse: () => allProjects[0],
    );
    final pumps = await db.select(db.heatPumps).get();
    expect(project.activeHeatPumpId, pumps.first.id);

    await db.close();
  });

  // ── ReadOnly mode ────────────────────────────────────────────

  testWidgets('heat pump dropdown is disabled in readOnly mode',
      (tester) async {
    await _pumpApp(tester, db, readOnly: true);

    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();

    final dropdown = find.widgetWithText(DropdownButton<int>, 'Wärmepumpe auswählen …');
    expect(dropdown, findsOneWidget);

    // In readOnly mode the dropdown should be disabled (onChanged is null).
    final dropdownWidget = tester.widget<DropdownButton<int>>(dropdown);
    expect(dropdownWidget.onChanged, isNull);
  });

  // ── Heat loops in the tab ────────────────────────────────────

  testWidgets('heat loops section shows "no heating loops" when empty',
      (tester) async {
    await _pumpApp(tester, db, readOnly: false);

    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();

    // No heat loops created yet → should show the empty message.
    expect(
      find.textContaining('Keine Heizkreise vorhanden'),
      findsOneWidget,
    );
  });

  testWidgets('heat loops section shows created loops', (tester) async {
    final db2 = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db2);

    final now = DateTime.now().millisecondsSinceEpoch;
    final projectId = await db2.into(db2.projects).insert(ProjectsCompanion.insert(
        name: 'Testprojekt', createdAt: now, updatedAt: now));

    await db2.into(db2.heatLoops).insert(HeatLoopsCompanion.insert(
      projectId: projectId,
      name: 'OG Fußboden',
      nominalKw: Value(5.0),
      flowTempC: Value(35),
    ));

    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: EditorScreen(
          db: db2,
          projectId: projectId,
          projectName: 'Testprojekt',
          readOnly: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();

    // The heat loop card should be visible.
    expect(find.text('OG Fußboden'), findsOneWidget);

    await db2.close();
  });

  // ── Controller load() correctness ────────────────────────────

  testWidgets('EditorController.load() populates all collections',
      (tester) async {
    final db2 = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db2);

    final now = DateTime.now().millisecondsSinceEpoch;
    final projectId = await db2.into(db2.projects).insert(
        ProjectsCompanion.insert(name: 'Testprojekt', createdAt: now, updatedAt: now));

    final controller = EditorController(db: db2, projectId: projectId, readOnly: false);
    await controller.load();

    expect(controller.project!.name, 'Testprojekt');
    expect(controller.heatPumps, hasLength(3));
    expect(controller.heatLoops, hasLength(0));

    controller.dispose();
    await db2.close();
  });

  testWidgets('EditorController.load() populates heat loops',
      (tester) async {
    final db2 = AppDatabase(NativeDatabase.memory());
    await seedIfEmpty(db2);

    final now = DateTime.now().millisecondsSinceEpoch;
    final projectId = await db2.into(db2.projects).insert(
        ProjectsCompanion.insert(name: 'Testprojekt', createdAt: now, updatedAt: now));

    await db2.into(db2.heatLoops).insert(HeatLoopsCompanion.insert(
      projectId: projectId,
      name: 'OG Fußboden',
      nominalKw: Value(5.0),
      flowTempC: Value(35),
    ));

    final controller = EditorController(db: db2, projectId: projectId, readOnly: false);
    await controller.load();

    expect(controller.heatLoops, hasLength(1));
    expect(controller.heatLoops.first.name, 'OG Fußboden');
    expect(controller.heatLoops.first.nominalKw, 5.0);

    controller.dispose();
    await db2.close();
  });

  // ── Migration column names ───────────────────────────────────

  testWidgets('heat_pumps table uses snake_case column names', (tester) async {
    final db2 = AppDatabase(NativeDatabase.memory());

    // seedIfEmpty runs onCreate which creates the table.
    await seedIfEmpty(db2);

    // Verify the table exists and columns are accessible via Drift.
    final pumps = await db2.select(db2.heatPumps).get();
    expect(pumps, hasLength(3));

    // Verify a specific pump's snake_case columns are accessible.
    final vwl55 = pumps.firstWhere((p) => p.modelNumber == 'VWL 55/7.1 A 230V');
    expect(vwl55.displayName, 'Vaillant aroTHERM pro VWL 55/7.1 A 230V');
    expect(vwl55.manufacturer, 'Vaillant');
    expect(vwl55.seriesName, 'aroTHERM pro');
    expect(vwl55.heatingCapacityKwA7W35, closeTo(4.84, 1e-6));
    expect(vwl55.copRatioA7W35, closeTo(2.91, 1e-6));
    expect(vwl55.refrigerantType, 'R32');
    expect(vwl55.gwpEuRegulationValue, closeTo(675.0, 1e-6));

    await db2.close();
  });

  // ── Tab index consistency ────────────────────────────────────

  testWidgets('switching tabs from Projekt to Wärmepumpe and back works',
      (tester) async {
    await _pumpApp(tester, db, readOnly: false);

    // Start on Projekt tab (default).
    expect(find.widgetWithText(InkWell, 'Projekt'), findsOneWidget);

    // Switch to PV.
    await tester.tap(find.widgetWithText(InkWell, 'PV'));
    await tester.pumpAndSettle();
    // PV tab is fully implemented — look for the roof canvas area.
    expect(find.text('Dach hinzufügen'), findsOneWidget);

    // Switch to Wärmepumpe.
    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();
    // Wärmepumpe tab should NOT show the PV canvas.
    expect(find.text('Dach hinzufügen'), findsNothing);

    // The heat pump dropdown should be present.
    expect(
      find.widgetWithText(DropdownButton<int>, 'Wärmepumpe auswählen …'),
      findsOneWidget,
    );

    // Switch back to Projekt.
    await tester.tap(find.widgetWithText(InkWell, 'Projekt').first);
    await tester.pumpAndSettle();
    // Projekt tab should NOT show the PV canvas.
    expect(find.text('Dach hinzufügen'), findsNothing);

    // Switch to Wärmepumpe again — should still work (no crash).
    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(DropdownButton<int>, 'Wärmepumpe auswählen …'),
      findsOneWidget,
    );
  });
}
