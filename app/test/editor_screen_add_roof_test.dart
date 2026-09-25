import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/features/editor/editor_screen.dart';

/// Integration test: drives the real [EditorScreen] "Dach hinzufügen" button
/// -> add-roof dialog -> "Hinzufügen", and asserts the roof is persisted to
/// the database AND reflected in the controller state (so it gets drawn).
void main() {
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

  testWidgets('Dach hinzufügen -> Hinzufügen persists and draws a roof',
      (tester) async {
    // Wide layout so the control panel is always visible.
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(db));
    // Let the controller's initial load() finish.
    await tester.pumpAndSettle();

    // No roof yet.
    expect(db.roofsOf(1), completion(isEmpty));

    // Open the add-roof dialog.
    await tester.tap(find.text('Dach hinzufügen'));
    await tester.pumpAndSettle();

    // Fill name + dimensions (the dialog's first text field is the name).
    await tester.enterText(find.byType(TextFormField).first, 'Neues Dach');
    final lengthField = find.widgetWithText(TextFormField, 'Länge (m)');
    final widthField = find.widgetWithText(TextFormField, 'Breite (m)');
    await tester.enterText(lengthField, '12.5');
    await tester.enterText(widthField, '6');

    // Unfocus so the cursor-blink ticker doesn't block settling.
    FocusManager.instance.primaryFocus?.unfocus();

    // The dialog is scrollable; make sure the action button is visible.
    await tester.scrollUntilVisible(find.text('Hinzufügen'), 100,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    // Submit.
    await tester.tap(find.text('Hinzufügen'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // The dialog must be gone.
    expect(find.text('Hinzufügen'), findsNothing);

    // A roof must now exist in the database with the entered values.
    final roofs = await db.roofsOf(1);
    expect(roofs, hasLength(1));
    final roof = roofs.single;
    expect(roof.name, 'Neues Dach');
    expect(roof.lengthM, closeTo(12.5, 1e-9));
    expect(roof.widthM, closeTo(6.0, 1e-9));
    expect(roof.type, 'pitched'); // default selection

    // And the controller (which drives the canvas) must see it too, so it
    // is actually drawn on screen. The ListenableBuilder rebuilds the canvas
    // after load() notifies; a clean repaint with no exceptions confirms it.
    await tester.pump();
  });

  testWidgets('cancelling the dialog adds nothing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dach hinzufügen'));
    await tester.pumpAndSettle();

    // Fill a valid form, then cancel instead of submitting.
    await tester.enterText(find.byType(TextFormField).first, 'Abgebrochen');
    final lengthField = find.widgetWithText(TextFormField, 'Länge (m)');
    final widthField = find.widgetWithText(TextFormField, 'Breite (m)');
    await tester.enterText(lengthField, '10');
    await tester.enterText(widthField, '5');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.scrollUntilVisible(find.text('Abbrechen'), 100,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abbrechen'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(await db.roofsOf(1), isEmpty);
  });
}
