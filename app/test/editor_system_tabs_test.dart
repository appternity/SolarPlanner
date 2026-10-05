import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:solar_planner/db/database.dart';
import 'package:solar_planner/features/editor/editor_screen.dart';

/// Tests for the vertical system-tab rail (PV / Batteriespeicher / Wallbox /
/// Wärmepumpe) on the left edge of the editor. Only the PV tab is functional
/// so far; the others show a placeholder.
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

  testWidgets('shows all five tabs with Projekt active by default',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(db));
    await tester.pumpAndSettle();

    // All five tab labels are present in the left rail.
    expect(find.widgetWithText(InkWell, 'Projekt'), findsWidgets);
    expect(find.widgetWithText(InkWell, 'PV'), findsOneWidget);
    // "Batteriespeicher" appears in both the rail and the Projekt tab's
    // system toggle, so we expect at least one.
    expect(find.widgetWithText(InkWell, 'Batteriespeicher'), findsWidgets);
    // "Wallbox" appears in both the rail and the Projekt tab's system toggle.
    expect(find.widgetWithText(InkWell, 'Wallbox'), findsWidgets);
    // "Wärmepumpe" appears in both the rail and the Projekt tab's system toggle.
    expect(find.widgetWithText(InkWell, 'Wärmepumpe'), findsWidgets);

    // The Projekt tab is active by default → no placeholder visible.
    expect(find.text('Noch in Arbeit'), findsNothing);

    // Switch to Wallbox → placeholder shows.
    await tester.tap(find.widgetWithText(InkWell, 'Wallbox').first);
    await tester.pumpAndSettle();
    expect(find.text('Noch in Arbeit'), findsOneWidget);

    // Switch to PV → placeholder gone (functional tab).
    await tester.tap(find.widgetWithText(InkWell, 'PV'));
    await tester.pumpAndSettle();
    expect(find.text('Noch in Arbeit'), findsNothing);

    // Back to Projekt → still no placeholder.
    await tester.tap(find.widgetWithText(InkWell, 'Projekt').first);
    await tester.pumpAndSettle();
    expect(find.text('Noch in Arbeit'), findsNothing);
  });
}
