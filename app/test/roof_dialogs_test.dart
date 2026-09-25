import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/tables.dart' show RoofType;
import 'package:solar_planner/features/editor/roof_dialogs.dart';

import 'helpers.dart';

/// Wraps [child] in a MaterialApp so that Navigator, Form and
/// ScaffoldMessenger work.
Widget wrap(Widget child) {
  return MaterialApp(home: Material(child: Center(child: child)));
}

/// Scrolls the dialog's content so that [target] is visible, then taps it.
/// Uses fixed-duration pumps (not pumpAndSettle) because a focused text field's
/// cursor-blink ticker can otherwise keep the test from settling.
Future<void> _scrollAndTap(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 200,
      scrollable: find.byType(Scrollable).first);
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.tapAt(tester.getCenter(target));
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('showAddRoofDialog', () {
    testWidgets('returns null when cancelled', (tester) async {
      await tester.pumpWidget(wrap(const SizedBox()));

      final future = showAddRoofDialog(tester.element(find.byType(SizedBox)));
      await tester.pumpAndSettle();

      // "Abbrechen" is in the actions bar (always visible, no scroll needed).
      await tester.tap(find.text('Abbrechen'));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final result = await future;
      expect(result, isNull);
    });

    testWidgets('returns a RoofFormResult with entered values', (tester) async {
      await tester.pumpWidget(wrap(const SizedBox()));

      final future = showAddRoofDialog(tester.element(find.byType(SizedBox)));
      await tester.pumpAndSettle();

      // Fill in the name.
      await tester.enterText(find.byType(TextFormField).first, 'Mein Dach');

      final lengthField = find.widgetWithText(TextFormField, 'Länge (m)');
      final widthField = find.widgetWithText(TextFormField, 'Breite (m)');
      await tester.enterText(lengthField, '12.5');
      await tester.enterText(widthField, '6');

      // Unfocus so the cursor-blink ticker doesn't block settling.
      FocusManager.instance.primaryFocus?.unfocus();

      await _scrollAndTap(tester, find.text('Hinzufügen'));

      final result = await future;
      expect(result, isNotNull);
      expect(result!.name, 'Mein Dach');
      expect(result.lengthM, 12.5);
      expect(result.widthM, 6.0);
      expect(result.type, RoofType.pitched); // default
      expect(result.isAdd, isTrue);
    });

    testWidgets('rejects empty name', (tester) async {
      await tester.pumpWidget(wrap(const SizedBox()));

      final future = showAddRoofDialog(tester.element(find.byType(SizedBox)));
      await tester.pumpAndSettle();

      // Leave name empty, fill dimensions.
      final lengthField = find.widgetWithText(TextFormField, 'Länge (m)');
      final widthField = find.widgetWithText(TextFormField, 'Breite (m)');
      await tester.enterText(lengthField, '10');
      await tester.enterText(widthField, '5');

      FocusManager.instance.primaryFocus?.unfocus();
      await _scrollAndTap(tester, find.text('Hinzufügen'));

      // Dialog should still be open (validation error shown).
      expect(find.text('Pflichtfeld'), findsOneWidget);

      await tester.tap(find.text('Abbrechen'));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final result = await future;
      expect(result, isNull);
    });

    testWidgets('rejects non-positive dimensions', (tester) async {
      await tester.pumpWidget(wrap(const SizedBox()));

      final future = showAddRoofDialog(tester.element(find.byType(SizedBox)));
      await tester.pumpAndSettle();

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Dach');

      final lengthField = find.widgetWithText(TextFormField, 'Länge (m)');
      final widthField = find.widgetWithText(TextFormField, 'Breite (m)');
      await tester.enterText(lengthField, '-5'); // negative!
      await tester.enterText(widthField, '5');

      FocusManager.instance.primaryFocus?.unfocus();
      await _scrollAndTap(tester, find.text('Hinzufügen'));

      // Should show validation error.
      expect(find.text('Größer als 0'), findsOneWidget);

      await tester.tap(find.text('Abbrechen'));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final result = await future;
      expect(result, isNull);
    });
  });

  group('showEditRoofDialog', () {
    testWidgets('pre-fills fields from the existing roof', (tester) async {
      final roof = makeRoof(
        name: 'Bestehendes Dach',
        lengthM: 12.0,
        widthM: 6.0,
        pitchDeg: 35.0,
      );

      await tester.pumpWidget(wrap(const SizedBox()));

      final future = showEditRoofDialog(
          tester.element(find.byType(SizedBox)), roof);
      await tester.pumpAndSettle();

      // Name should be pre-filled.
      expect(find.text('Bestehendes Dach'), findsOneWidget);

      // Dimensions are shown read-only in edit mode (not editable).
      expect(find.widgetWithText(TextFormField, 'Länge (m)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Breite (m)'), findsOneWidget);

      // Pitch field should be present.
      expect(find.widgetWithText(TextFormField, 'Neigung (°)'), findsOneWidget);

      // Cancel.
      await tester.tap(find.text('Abbrechen'));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final result = await future;
      expect(result, isNull);
    });

    testWidgets('saves changed name and pitch', (tester) async {
      final roof = makeRoof(
        name: 'Altes Dach',
        pitchDeg: 30.0,
      );

      await tester.pumpWidget(wrap(const SizedBox()));

      final future = showEditRoofDialog(
          tester.element(find.byType(SizedBox)), roof);
      await tester.pumpAndSettle();

      // Change the name.
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Neues Dach');

      // Change pitch.
      final pitchField = find.widgetWithText(TextFormField, 'Neigung (°)');
      await tester.enterText(pitchField, '45.0');

      FocusManager.instance.primaryFocus?.unfocus();
      await _scrollAndTap(tester, find.text('Speichern'));

      final result = await future;
      expect(result, isNotNull);
      expect(result!.name, 'Neues Dach');
      expect(result.pitchDeg, 45.0);

      // In edit mode, geometry fields are null (not changed).
      expect(result.lengthM, isNull);
      expect(result.widthM, isNull);
      expect(result.type, isNull); // type not changeable in edit mode
      expect(result.isAdd, isFalse);
    });

    testWidgets('rejects empty name on save', (tester) async {
      final roof = makeRoof(name: 'Dach');

      await tester.pumpWidget(wrap(const SizedBox()));

      final future = showEditRoofDialog(
          tester.element(find.byType(SizedBox)), roof);
      await tester.pumpAndSettle();

      // Clear the name.
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, '');

      FocusManager.instance.primaryFocus?.unfocus();
      await _scrollAndTap(tester, find.text('Speichern'));

      expect(find.text('Pflichtfeld'), findsOneWidget);

      // Dialog still open.
      await tester.tap(find.text('Abbrechen'));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final result = await future;
      expect(result, isNull);
    });
  });

    testWidgets('shows read-only dimensions with the roof values',
        (tester) async {
      final roof = makeRoof(
        name: 'Dach',
        lengthM: 12.0,
        widthM: 6.5,
      );

      await tester.pumpWidget(wrap(const SizedBox()));

      final future = showEditRoofDialog(
          tester.element(find.byType(SizedBox)), roof);
      await tester.pumpAndSettle();

      // The dimension fields display the roof's actual length/width.
      expect(find.text('12'), findsOneWidget);
      expect(find.text('6.5'), findsOneWidget);

      // They are disabled (read-only), so they cannot be edited.
      final lengthField = find.widgetWithText(TextFormField, 'Länge (m)');
      final widthField = find.widgetWithText(TextFormField, 'Breite (m)');
      expect(tester.widget<TextFormField>(lengthField).enabled, isFalse);
      expect(tester.widget<TextFormField>(widthField).enabled, isFalse);

      // Cancel.
      await tester.tap(find.text('Abbrechen'));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final result = await future;
      expect(result, isNull);
    });

  group('confirmDeleteRoof', () {
    testWidgets('returns true when confirmed', (tester) async {
      final roof = makeRoof(name: 'Zu löschen');

      await tester.pumpWidget(wrap(const SizedBox()));

      final future = confirmDeleteRoof(
          tester.element(find.byType(SizedBox)), roof);
      await tester.pumpAndSettle();

      expect(find.text('„Zu löschen“ löschen?'), findsOneWidget);
      await tester.tap(find.text('Löschen'));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final result = await future;
      expect(result, isTrue);
    });

    testWidgets('returns false when cancelled', (tester) async {
      final roof = makeRoof(name: 'Bleibt');

      await tester.pumpWidget(wrap(const SizedBox()));

      final future = confirmDeleteRoof(
          tester.element(find.byType(SizedBox)), roof);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abbrechen'));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final result = await future;
      expect(result, isFalse);
    });
  });
}
