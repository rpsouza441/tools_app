import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/screen/network_calculator_screen.dart';

import 'screen_test_harness.dart';

void main() {
  group('NetworkCalculatorScreen chrome', () {
    testWidgets('uses ToolScaffold heading without a production AppBar', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const NetworkCalculatorScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(ToolScaffold), findsOneWidget);
      expect(find.text('Calculadora de Rede'), findsOneWidget);
    });
  });

  group('NetworkCalculatorScreen happy path', () {
    testWidgets(
      'shows split IPv4 rows after Calcular rede for 192.168.1.10/24',
      (tester) async {
        await tester.pumpWidget(wrapScreen(const NetworkCalculatorScreen()));
        await tester.pumpAndSettle();

        await _enterIpAndMask(tester, ip: '192.168.1.10', maskOrCidr: '24');
        await tester.ensureVisible(find.text('Calcular rede'));
        await tester.tap(find.text('Calcular rede'));
        await tester.pumpAndSettle();

        expect(find.text('Endereço de Rede'), findsOneWidget);
        expect(find.text('192.168.1.0'), findsOneWidget);
        expect(find.text('255.255.255.0'), findsOneWidget);
        expect(find.text('192.168.1.1 - 192.168.1.254'), findsOneWidget);
        expect(find.text('254'), findsOneWidget);
        expect(find.text('Calcular'), findsNothing);
        expect(find.text('Cancelar'), findsNothing);
      },
    );
  });

  group('NetworkCalculatorScreen field errors', () {
    testWidgets('Limpar then Calcular rede shows invalid IP error', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const NetworkCalculatorScreen()));
      await tester.pumpAndSettle();

      await _enterIpAndMask(tester, ip: '192.168.1.10', maskOrCidr: '24');
      await tester.ensureVisible(find.text('Calcular rede'));
      await tester.tap(find.text('Calcular rede'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Limpar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calcular rede'));
      await tester.pumpAndSettle();

      expect(
        find.text('Formato de IP inválido (ex: 192.168.1.1).'),
        findsOneWidget,
      );
    });

    testWidgets('valid IP with empty mask shows mask required error', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const NetworkCalculatorScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Endereço de IP'),
        '192.168.1.10',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Calcular rede'));
      await tester.tap(find.text('Calcular rede'));
      await tester.pumpAndSettle();

      expect(
        find.text('Insira uma máscara de sub-rede ou um CIDR.'),
        findsOneWidget,
      );
    });

    testWidgets('valid IP with invalid dotted mask shows mask error', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const NetworkCalculatorScreen()));
      await tester.pumpAndSettle();

      await _enterIpAndMask(
        tester,
        ip: '192.168.1.10',
        maskOrCidr: '192.168.1.1',
      );
      await tester.ensureVisible(find.text('Calcular rede'));
      await tester.tap(find.text('Calcular rede'));
      await tester.pumpAndSettle();

      expect(find.text('Máscara de sub-rede inválida.'), findsOneWidget);
    });

    testWidgets('valid IP with CIDR 33 shows CIDR range error', (tester) async {
      await tester.pumpWidget(wrapScreen(const NetworkCalculatorScreen()));
      await tester.pumpAndSettle();

      await _enterIpAndMask(tester, ip: '192.168.1.10', maskOrCidr: '33');
      await tester.ensureVisible(find.text('Calcular rede'));
      await tester.tap(find.text('Calcular rede'));
      await tester.pumpAndSettle();

      expect(find.text('Valor de CIDR inválido (0-32).'), findsOneWidget);
    });
  });

  group('NetworkCalculatorScreen copy', () {
    testWidgets('first CopyValueAction copies 192.168.1.0 without blob prefix', (
      tester,
    ) async {
      final writer = FakeCopyWriter();
      await tester.pumpWidget(
        wrapScreen(NetworkCalculatorScreen(copyWriter: writer)),
      );
      await tester.pumpAndSettle();

      await _enterIpAndMask(tester, ip: '192.168.1.10', maskOrCidr: '24');
      await tester.ensureVisible(find.text('Calcular rede'));
      await tester.tap(find.text('Calcular rede'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CopyValueAction).first);
      await tester.pumpAndSettle();

      expect(writer.lastValue, '192.168.1.0');
    });
  });
}

Future<void> _enterIpAndMask(
  WidgetTester tester, {
  required String ip,
  required String maskOrCidr,
}) async {
  await tester.enterText(find.widgetWithText(TextField, 'Endereço de IP'), ip);
  await tester.enterText(
    find.widgetWithText(TextField, 'Máscara de Sub-Rede ou CIDR'),
    maskOrCidr,
  );
  await tester.pumpAndSettle();
}
