import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/screen/data_converter_screen.dart';
import 'package:tools_app/service/data_converter.dart';

import 'screen_test_harness.dart';

final _numberFormatter = NumberFormat('#,##0.000', 'pt_BR');

String _formatted(double value, String unit) =>
    '${_numberFormatter.format(value)} $unit';

void main() {
  group('DataConverterScreen chrome', () {
    testWidgets('uses ToolScaffold heading without a production AppBar', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const DataConverterScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(ToolScaffold), findsOneWidget);
      expect(find.text('Conversor de Armazenamento'), findsOneWidget);
      expect(find.text('Conversor de Dados'), findsNothing);
    });

    testWidgets(
      'primary button is labeled Analisar capacidade without a spinner-only child',
      (tester) async {
        await tester.pumpWidget(wrapScreen(const DataConverterScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Analisar Capacidade'), findsNothing);
        expect(find.text('Analisar capacidade'), findsWidgets);

        expect(
          find.descendant(
            of: find.byType(ElevatedButton),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsNothing,
        );
      },
    );
  });

  group('DataConverterScreen field errors', () {
    testWidgets('empty submit shows Insira um valor', (tester) async {
      await tester.pumpWidget(wrapScreen(const DataConverterScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Analisar capacidade'));
      await tester.tap(find.text('Analisar capacidade'));
      await tester.pumpAndSettle();

      expect(find.text('Insira um valor'), findsOneWidget);
    });

    testWidgets('non-numeric submit shows Insira um valor numérico positivo', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const DataConverterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Valor Anunciado'),
        'abc',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Analisar capacidade'));
      await tester.tap(find.text('Analisar capacidade'));
      await tester.pumpAndSettle();

      expect(find.text('Insira um valor numérico positivo'), findsOneWidget);
    });
  });

  group('DataConverterScreen happy path', () {
    testWidgets('analyzing 1 TB shows formatted advertised, real and difference', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const DataConverterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Valor Anunciado'),
        '1',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('GB'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TB').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Analisar capacidade'));
      await tester.tap(find.text('Analisar capacidade'));
      await tester.pumpAndSettle();

      final result = DataConverter.analyze(1, 'TB');
      expect(find.text('Analisar Capacidade'), findsNothing);
      expect(find.text('Analisar capacidade'), findsWidgets);
      expect(
        find.text(_formatted(result.advertisedValue, result.advertisedUnit)),
        findsWidgets,
      );
      expect(
        find.text(_formatted(result.realValue, result.realUnit)),
        findsWidgets,
      );
      expect(
        find.text(_formatted(result.differenceValue, result.differenceUnit)),
        findsWidgets,
      );
      expect(find.text('TiB'), findsWidgets);
      expect(find.text('Insira um valor'), findsNothing);
    });
  });

  group('DataConverterScreen explanation', () {
    testWidgets(
      'educational copy is always visible including 931 GiB',
      (tester) async {
        await tester.pumpWidget(wrapScreen(const DataConverterScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Por que a capacidade parece menor?'), findsOneWidget);
        expect(
          find.textContaining('931 GiB', findRichText: true),
          findsOneWidget,
        );
      },
    );
  });

  group('DataConverterScreen copy', () {
    testWidgets(
      'first CopyValueAction copies formatted advertised number and unit',
      (tester) async {
        final writer = FakeCopyWriter();
        await tester.pumpWidget(
          wrapScreen(DataConverterScreen(copyWriter: writer)),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Valor Anunciado'),
          '1',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('GB'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('TB').last);
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Analisar capacidade'));
        await tester.tap(find.text('Analisar capacidade'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CopyValueAction).first);
        await tester.pumpAndSettle();

        final result = DataConverter.analyze(1, 'TB');
        expect(
          writer.lastValue,
          _formatted(result.advertisedValue, result.advertisedUnit),
        );
      },
    );
  });
}
