import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/main.dart';
import 'package:tools_app/screen/data_converter_screen.dart';
import 'package:tools_app/screen/hash_generator_screen.dart';
import 'package:tools_app/screen/internet_diagnostic_screen.dart';
import 'package:tools_app/screen/network_calculator_screen.dart';
import 'package:tools_app/theme/theme.dart';

import 'screen_test_harness.dart';

void main() {
  group('screen test harness', () {
    testWidgets('wrapScreen supplies lightTheme', (tester) async {
      await tester.pumpWidget(wrapScreen(const Text('harness')));

      expect(find.text('harness'), findsOneWidget);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, lightTheme);
    });

    test('FakeCopyWriter records values in memory only', () async {
      final writer = FakeCopyWriter();
      await writer.write('payload');
      expect(writer.lastValue, 'payload');
      expect(writer.callCount, 1);
    });
  });

  group('PRES-04 three-tool smoke via live App', () {
    testWidgets(
      'Rede, Armazenamento and Hash remain reachable with current chrome',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        expect(find.text('Calculadora de Rede'), findsWidgets);
        expect(
          find.descendant(
            of: find.byType(NetworkCalculatorScreen),
            matching: find.text('Calcular rede'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(NetworkCalculatorScreen),
            matching: find.text('Limpar'),
          ),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(TextField, 'Endereço de IP'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(TextField, 'Máscara de Sub-Rede ou CIDR'),
          findsOneWidget,
        );

        await tester.tap(find.text('Armazenamento'));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(DataConverterScreen),
            matching: find.text('Conversor de Armazenamento'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(DataConverterScreen),
            matching: find.text('Analisar capacidade'),
          ),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(TextField, 'Valor Anunciado'),
          findsOneWidget,
        );

        await tester.tap(find.text('Hash'));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(HashGeneratorScreen),
            matching: find.text('Gerador de Hash'),
          ),
          findsOneWidget,
        );
        expect(find.widgetWithText(TextField, 'Texto'), findsOneWidget);
        expect(
          find.text(
            'MD5 e SHA-1 servem para conferência, não para proteger senhas.',
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(HashGeneratorScreen),
            matching: find.text('Gerar hashes'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(HashGeneratorScreen),
            matching: find.text('Limpar'),
          ),
          findsOneWidget,
        );

        // 4th destination: Diagnóstico de Internet is reachable and the three
        // migrated tools remain intact (D-03, PRES).
        await tester.tap(find.text('Diagnóstico'));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(InternetDiagnosticScreen),
            matching: find.text('Diagnóstico de Internet'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(InternetDiagnosticScreen),
            matching: find.text('Iniciar diagnóstico'),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
