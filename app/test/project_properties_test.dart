// drift exports `isNull`/`isNotNull`, which clash with the matcher versions.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/features/editor/editor_controller.dart';
import 'package:solar_planner/features/editor/project_properties_dialog.dart'
    show ProjectPropertiesResult, showProjectPropertiesDialog;

/// Tests for editing project properties on existing projects:
/// the batched controller write and the properties dialog (prefill, save,
/// cancel).
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.projects).insert(ProjectsCompanion.insert(
      name: 'Testprojekt',
      address: Value('Musterstraße 1'),
      latitude: Value(52.0),
      longitude: Value(13.0),
      createdAt: 0,
      updatedAt: 0,
    ));
  });

  tearDown(() async {
    await db.close();
  });

  Future<Project> projectRow() => (db.select(db.projects)
        ..where((t) => t.id.equals(1)))
      .getSingle();

  group('updateProjectProperties', () {
    test('persists identity, coordinates and household fields in one write',
        () async {
      final c = EditorController(db: db, projectId: 1, readOnly: false);
      await c.load();

      await c.updateProjectProperties(
        name: 'Neuer Name',
        address: 'Andere Straße 2',
        latitude: 48.5,
        longitude: 10.2,
        personen: 3,
        etagen: 3,
        keller: false,
      );

      final p = await projectRow();
      expect(p.name, 'Neuer Name');
      expect(p.address, 'Andere Straße 2');
      expect(p.latitude, 48.5);
      expect(p.longitude, 10.2);
      // Changed fields:
      expect(p.personen, 3);
      expect(p.etagen, 3);
      expect(p.keller, isFalse);
      // Untouched fields keep their previous values:
      expect(p.gridPhases, 3);
      expect(p.baeder, 2);
    });

    test('clears the feed-in limit with an explicit null', () async {
      final c = EditorController(db: db, projectId: 1, readOnly: false);
      await c.load();

      // Set first ...
      await c.updateProjectProperties(maxFeedInKw: Value(8.0));
      expect((await projectRow()).maxFeedInKw, 8.0);

      // ... then clear it (empty dialog field → Value(null)).
      await c.updateProjectProperties(maxFeedInKw: const Value<double?>(null));
      expect((await projectRow()).maxFeedInKw, isNull);
    });

    test('is a no-op in read-only mode', () async {
      final c = EditorController(db: db, projectId: 1, readOnly: true);
      await c.load();

      await c.updateProjectProperties(name: 'Sollte nicht gehen');
      expect((await projectRow()).name, 'Testprojekt');
    });

    test('updates the in-memory model', () async {
      final c = EditorController(db: db, projectId: 1, readOnly: false);
      await c.load();

      await c.updateProjectProperties(name: 'Im Speicher');
      expect(c.project?.name, 'Im Speicher');
    });
  });

  group('showProjectPropertiesDialog', () {
    late EditorController controller;

    Widget wrap(Project project) => MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return ElevatedButton(
                key: const ValueKey('open-dialog'),
                onPressed: () async {
                  final result = await showProjectPropertiesDialog(
                      context, project);
                  if (result != null) {
                    ProjectPropertiesResult.apply(controller, result);
                  }
                },
                child: const Text('Öffnen'),
              );
            }),
          ),
        );

    /// The dialog is tall; scroll its content area until [target] is visible.
    Future<void> scrollTo(WidgetTester tester, Finder target) async {
      // The dialog's content is a SingleChildScrollView; the Scrollable it
      // creates sits one level deeper in the widget tree.
      final scrollables =
          find.descendant(of: find.byType(SingleChildScrollView).first,
              matching: find.byType(Scrollable));
      await tester
          .scrollUntilVisible(target, 150,
              scrollable: scrollables.first);
    }

    testWidgets('prefills from the project and persists edits',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      controller = EditorController(db: db, projectId: 1, readOnly: false);
      await controller.load();

      await tester.pumpWidget(wrap(await projectRow()));
      await tester.tap(find.byKey(const ValueKey('open-dialog')));
      await tester.pumpAndSettle();

      // Prefilled values are visible.
      expect(find.text('Projekt-Eigenschaften'), findsOneWidget);
      final nameField = find.widgetWithText(TextField, 'Projektname');
      expect((tester.widget(nameField) as TextField).controller!.text,
          'Testprojekt');

      // Rename and change a household parameter (scroll into view first).
      await tester.enterText(nameField, 'Umbenannt');
      final personen = find.widgetWithText(TextField, 'Personen');
      await scrollTo(tester, personen);
      await tester.enterText(personen, '6');

      // Unfocus so the dialog actions are tappable (tall-dialog gotcha).
      await tester.tap(find.byType(Scaffold), warnIfMissed: false);
      await tester.pumpAndSettle();

      // The dialog is scrollable; the actions may be outside the viewport.
      await scrollTo(tester, find.text('Speichern'));
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      final p = await projectRow();
      expect(p.name, 'Umbenannt');
      expect(p.personen, 6);

      // Untouched defaults survive the round-trip.
      expect(p.gridPhases, 3);
    });

    testWidgets('cancelling keeps the project unchanged', (tester) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      controller = EditorController(db: db, projectId: 1, readOnly: false);
      await controller.load();

      await tester.pumpWidget(wrap(await projectRow()));
      await tester.tap(find.byKey(const ValueKey('open-dialog')));
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextField, 'Projektname');
      await tester.enterText(nameField, 'Wird verworfen');

      // Unfocus + scroll to the actions.
      await tester.tap(find.byType(Scaffold), warnIfMissed: false);
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('Abbrechen'));
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect((await projectRow()).name, 'Testprojekt');
    });
  });
}
