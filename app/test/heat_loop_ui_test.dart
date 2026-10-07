import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/features/editor/editor_controller.dart';
import 'package:solar_planner/features/editor/editor_screen.dart';
import 'package:solar_planner/features/editor/heat_loop_dialogs.dart';

void main() {
  late AppDatabase db;
  late EditorController c;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.projects).insert(ProjectsCompanion.insert(
      name: 'Testprojekt',
      createdAt: 0,
      updatedAt: 0,
      wpAnlage: const Value(true),
    ));
    c = EditorController(db: db, projectId: 1, readOnly: false);
    await c.load();
  });

  tearDown(() async {
    await db.close();
  });

  /// Wraps [child] in a MaterialApp with a Scaffold so that Navigator,
  /// Form, and ScaffoldMessenger work.
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Opens the editor and navigates to the Wärmepumpe tab.
  Future<void> _openHeatPumpTab(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(InkWell, 'Wärmepumpe').first);
    await tester.pumpAndSettle();
  }

  // =========================================================================
  // Controller tests — verify the backend methods work correctly
  // =========================================================================

  group('HeatLoop controller', () {
    test('insertHeatLoop creates a loop with correct values', () async {
      expect(c.heatLoops, isEmpty);
      final id = await c.insertHeatLoop(
        name: 'Testkreis',
        loopType: 'fußbodenheizung',
        nominalKw: 12.5,
        flowTempC: 40,
      );
      expect(id, isPositive);
      expect(c.heatLoops, hasLength(1));
      final loop = c.heatLoops.first;
      expect(loop.name, 'Testkreis');
      expect(loop.loopType, 'fußbodenheizung');
      expect(loop.nominalKw, 12.5);
      expect(loop.flowTempC, 40);
    });

    test('insertHeatLoop with defaults uses radiator type', () async {
      await c.insertHeatLoop(name: 'Defaultkreis');
      expect(c.heatLoops, hasLength(1));
      expect(c.heatLoops.first.loopType, 'radiator');
      expect(c.heatLoops.first.nominalKw, 0);
      expect(c.heatLoops.first.flowTempC, 55);
    });

    test('updateHeatLoop changes values', () async {
      final id = await c.insertHeatLoop(
        name: 'Original',
        loopType: 'radiator',
        nominalKw: 10,
        flowTempC: 55,
      );
      await c.updateHeatLoop(id,
          name: 'Updated', loopType: 'fußbodenheizung', nominalKw: 20, flowTempC: 35);
      expect(c.heatLoops, hasLength(1));
      expect(c.heatLoops.first.name, 'Updated');
      expect(c.heatLoops.first.loopType, 'fußbodenheizung');
      expect(c.heatLoops.first.nominalKw, 20);
      expect(c.heatLoops.first.flowTempC, 35);
    });

    test('updateHeatLoop partial update only changes specified fields',
        () async {
      final id = await c.insertHeatLoop(
        name: 'Original',
        loopType: 'radiator',
        nominalKw: 10,
        flowTempC: 55,
      );
      await c.updateHeatLoop(id, name: 'Changed');
      expect(c.heatLoops, hasLength(1));
      expect(c.heatLoops.first.name, 'Changed');
      expect(c.heatLoops.first.loopType, 'radiator');
      expect(c.heatLoops.first.nominalKw, 10);
      expect(c.heatLoops.first.flowTempC, 55);
    });

    test('deleteHeatLoop removes the loop', () async {
      final id1 = await c.insertHeatLoop(name: 'Kreis 1');
      final id2 = await c.insertHeatLoop(name: 'Kreis 2');
      expect(c.heatLoops, hasLength(2));
      await c.deleteHeatLoop(id1);
      expect(c.heatLoops, hasLength(1));
      expect(c.heatLoops.first.id, id2);
    });

    test('heatLoopsOf reads from DB correctly', () async {
      await c.insertHeatLoop(name: 'Loop A');
      await c.insertHeatLoop(name: 'Loop B');
      final loops = await db.heatLoopsOf(1);
      expect(loops, hasLength(2));
      expect(loops.map((l) => l.name).toList(), ['Loop A', 'Loop B']);
    });
  });

  // =========================================================================
  // Dialog widget tests — verify the dialogs render and behave correctly
  // (These are the same as heat_loop_dialogs_test.dart but kept here for
  //  discoverability — the dialog tests in heat_loop_dialogs_test.dart
  //  are the canonical source.)
  // =========================================================================

  group('HeatLoop dialog widgets', () {
    testWidgets('add dialog opens and cancels', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await showAddHeatLoopDialog(context);
            },
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Neuen Heizkreis erstellen'), findsOneWidget);
      expect(find.text('Neuer Heizkreis'), findsOneWidget);

      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(find.text('Neuen Heizkreis erstellen'), findsNothing);
    });

    testWidgets('edit dialog pre-fills existing data', (tester) async {
      final loop = HeatLoop(
        id: 1,
        projectId: 1,
        name: 'Bestehender',
        loopType: 'fußbodenheizung',
        nominalKw: 8.5,
        flowTempC: 40,
      );

      await tester.pumpWidget(wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await showEditHeatLoopDialog(context, loop);
            },
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Heizkreis bearbeiten'), findsOneWidget);
      expect(find.text('Bestehender'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('delete confirmation returns true on confirm', (tester) async {
      final loop = HeatLoop(
        id: 1,
        projectId: 1,
        name: 'Test',
        loopType: 'radiator',
        nominalKw: 5,
        flowTempC: 55,
      );
      bool? result;
      await tester.pumpWidget(wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await confirmDeleteHeatLoop(context, loop);
            },
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('„Test“ löschen?'), findsOneWidget);
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('save form returns HeatLoopFormResult with valid data',
        (tester) async {
      HeatLoopFormResult? returned;
      await tester.pumpWidget(wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              returned = await showAddHeatLoopDialog(context);
            },
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Fill numeric fields.
      await tester.enterText(find.byType(TextField).at(1), '15');
      await tester.enterText(find.byType(TextField).at(2), '50');

      // Select type from dropdown.
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fußbodenheizung'));
      await tester.pumpAndSettle();

      // Save.
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(returned, isNotNull);
      expect(returned!.name, 'Neuer Heizkreis');
      expect(returned!.loopType, 'fußbodenheizung');
      expect(returned!.nominalKw, 15);
      expect(returned!.flowTempC, 50);
    });

    testWidgets('save form rejects empty name', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showAddHeatLoopDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear the name field and tap save.
      await tester.enterText(find.byType(TextField).at(0), '');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      // SnackBar should show validation error.
      expect(find.text('Bitte einen Namen eingeben.'), findsOneWidget);
    });
  });

  // =========================================================================
  // UI integration tests — verify the EditorScreen renders heat loop UI
  // correctly. These test the _HydraulicFlowSection and _HeatLoopCard.
  // =========================================================================

  group('HeatLoop UI integration', () {
    testWidgets('read-only mode shows empty message, no add button',
        (tester) async {
      await tester.pumpWidget(wrap(
        EditorScreen(
          db: db,
          projectId: 1,
          projectName: 'Testprojekt',
          readOnly: true,
        ),
      ));
      await tester.pumpAndSettle();
      await _openHeatPumpTab(tester);

      // The empty message should be visible (no heat loops).
      expect(find.text(
          'Keine Heizkreise vorhanden. Erstellen Sie einen Heizkreis, um die hydraulische Darstellung zu sehen.'),
          findsOneWidget);

      // The "Heizkreis hinzufügen" button should NOT be visible.
      expect(find.text('Heizkreis hinzufügen'), findsNothing);
    });

    testWidgets('pre-seeded heat loops render as cards with edit/delete',
        (tester) async {
      // Pre-seed three heat loops.
      await db.into(db.heatLoops).insert(HeatLoopsCompanion.insert(
        projectId: 1,
        name: 'EG Radiatoren',
        loopType: const Value('radiator'),
        nominalKw: const Value(12),
        flowTempC: const Value(55),
      ));
      await db.into(db.heatLoops).insert(HeatLoopsCompanion.insert(
        projectId: 1,
        name: 'OG Radiatoren',
        loopType: const Value('radiator'),
        nominalKw: const Value(8),
        flowTempC: const Value(50),
      ));
      await db.into(db.heatLoops).insert(HeatLoopsCompanion.insert(
        projectId: 1,
        name: 'Fußboden',
        loopType: const Value('fußbodenheizung'),
        nominalKw: const Value(6),
        flowTempC: const Value(35),
      ));

      await tester.pumpWidget(wrap(
        EditorScreen(
          db: db,
          projectId: 1,
          projectName: 'Testprojekt',
          readOnly: false,
        ),
      ));
      await tester.pumpAndSettle();
      await _openHeatPumpTab(tester);

      // Verify all three heat loop names are visible.
      expect(find.text('EG Radiatoren'), findsOneWidget);
      expect(find.text('OG Radiatoren'), findsOneWidget);
      expect(find.text('Fußboden'), findsOneWidget);

      // Verify there are edit and delete buttons (2 per card = 6 total).
      expect(find.byIcon(Icons.edit), findsNWidgets(3));
      expect(find.byIcon(Icons.delete), findsNWidgets(3));
    });

    testWidgets('single heat loop card shows edit/delete buttons',
        (tester) async {
      await db.into(db.heatLoops).insert(HeatLoopsCompanion.insert(
        projectId: 1,
        name: 'Einziger Kreis',
        loopType: const Value('radiator'),
      ));

      await tester.pumpWidget(wrap(
        EditorScreen(
          db: db,
          projectId: 1,
          projectName: 'Testprojekt',
          readOnly: false,
        ),
      ));
      await tester.pumpAndSettle();
      await _openHeatPumpTab(tester);

      expect(find.text('Einziger Kreis'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNWidgets(1));
      expect(find.byIcon(Icons.delete), findsNWidgets(1));
    });

    // Note: The "adding a heat loop via dialog" flow is tested at the
    // controller level (insertHeatLoop/updateHeatLoop/deleteHeatLoop) and
    // the dialog level (heat_loop_dialogs_test.dart). The EditorScreen
    // creates its own internal controller, so a widget test cannot verify
    // that the test's `c` instance is updated — they are separate objects.
    // The pre-seeded cards tests above verify the UI renders correctly.
  });
}
