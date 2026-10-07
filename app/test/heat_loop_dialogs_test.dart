import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/db/database.dart' show HeatLoop;
import 'package:solar_planner/features/editor/heat_loop_dialogs.dart';

import 'helpers.dart';

Widget wrap(Widget child) {
  return MaterialApp(home: Material(child: Center(child: child)));
}

void main() {
  group('showAddHeatLoopDialog', () {
    testWidgets('returns null when cancelled', (tester) async {
      await tester.pumpWidget(wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await showAddHeatLoopDialog(context);
              expect(result, isNull);
            },
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
    });

    testWidgets('returns a HeatLoopFormResult with valid input',
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

      // Fill in the form — first TextField is name (already filled)
      // Second TextField is nominal kW
      await tester.enterText(find.byType(TextField).at(1), '12');
      // Third TextField is flow temp
      await tester.enterText(find.byType(TextField).at(2), '55');

      // Open the dropdown and select a type
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      // Select "Fußbodenheizung" (second option)
      await tester.tap(find.text('Fußbodenheizung'));
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(returned, isNotNull);
      expect(returned!.name, 'Neuer Heizkreis');
      expect(returned!.loopType, 'fußbodenheizung');
      expect(returned!.nominalKw, 12);
      expect(returned!.flowTempC, 55);
    });

    testWidgets('rejects empty name', (tester) async {
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

      // Clear the name field and tap save
      await tester.enterText(find.byType(TextField).at(0), '');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      // SnackBar should show
      expect(find.text('Bitte einen Namen eingeben.'), findsOneWidget);
    });

    testWidgets('prefills existing heat loop data', (tester) async {
      final loop = HeatLoop(
        id: 1,
        projectId: 1,
        name: 'Bestehender Kreis',
        loopType: 'fußbodenheizung',
        nominalKw: 8.5,
        flowTempC: 40,
      );

      HeatLoopFormResult? returned;
      await tester.pumpWidget(wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              returned = await showEditHeatLoopDialog(context, loop);
            },
            child: const Text('Open'),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify pre-filled values
      expect(find.text('Heizkreis bearbeiten'), findsOneWidget);
      expect(find.text('Bestehender Kreis'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });
  });

  group('confirmDeleteHeatLoop', () {
    testWidgets('returns false when cancelled', (tester) async {
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
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('returns true when confirmed', (tester) async {
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
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });
}
