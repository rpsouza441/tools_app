import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/screen/hash_generator_screen.dart';

import 'screen_test_harness.dart';

const _abcMd5 = '900150983cd24fb0d6963f7d28e17f72';
const _abcSha1 = 'a9993e364706816aba3e25717850c26c9cd0d89d';
const _abcSha256 =
    'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad';
const _abcSha512Prefix = 'ddaf35a193617abacc417349ae204131';
const _abcSha512Remainder =
    '12e6fa4e89a97ea20a9eeee64b55d39a'
    '2192992a274fc1a836ba3c23a3feebbd'
    '454d4423643ce80e2a9ac94fa54ca49f';

void main() {
  group('HashGeneratorScreen chrome', () {
    testWidgets('uses ToolScaffold heading without a production AppBar', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScreen(const HashGeneratorScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(ToolScaffold), findsOneWidget);
      expect(find.text('Gerador de Hash'), findsOneWidget);
    });

    testWidgets(
      'primary CTA is Gerar hashes with Limpar and without Calcular or Cancelar',
      (tester) async {
        await tester.pumpWidget(wrapScreen(const HashGeneratorScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Calcular'), findsNothing);
        expect(find.text('Cancelar'), findsNothing);
        expect(find.text('Gerar hashes'), findsWidgets);
        expect(find.text('Limpar'), findsWidgets);
        expect(
          find.text(
            'MD5 e SHA-1 servem para conferência, não para proteger senhas.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('HashGeneratorScreen field errors', () {
    testWidgets(
      'empty submit shows Digite ou cole um texto para calcular o hash.',
      (tester) async {
        await tester.pumpWidget(wrapScreen(const HashGeneratorScreen()));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Gerar hashes'));
        await tester.tap(find.text('Gerar hashes'));
        await tester.pumpAndSettle();

        expect(
          find.text('Digite ou cole um texto para calcular o hash.'),
          findsOneWidget,
        );
      },
    );
  });

  group('HashGeneratorScreen happy path', () {
    testWidgets('generating hashes for abc shows four known digests and metrics', (
      tester,
    ) async {
      final writer = FakeCopyWriter();
      await tester.pumpWidget(
        wrapScreen(HashGeneratorScreen(copyWriter: writer)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Texto'), 'abc');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Gerar hashes'));
      await tester.tap(find.text('Gerar hashes'));
      await tester.pumpAndSettle();

      expect(find.text(_abcMd5), findsOneWidget);
      expect(find.text(_abcSha1), findsOneWidget);
      expect(find.text(_abcSha256), findsOneWidget);
      expect(find.textContaining(_abcSha512Prefix), findsWidgets);
      expect(find.textContaining(_abcSha512Remainder), findsWidgets);

      expect(find.text('Calcular'), findsNothing);
      expect(find.text('Cancelar'), findsNothing);
      expect(find.text('Gerar hashes'), findsWidgets);
      expect(find.text('Limpar'), findsWidgets);
      expect(
        find.text(
          'MD5 e SHA-1 servem para conferência, não para proteger senhas.',
        ),
        findsOneWidget,
      );

      expect(find.text('Caracteres'), findsOneWidget);
      expect(find.text('Bytes UTF-8'), findsOneWidget);
      expect(find.text('Algoritmos'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ToolMetric),
          matching: find.text('3'),
        ),
        findsNWidgets(2),
      );
      expect(
        find.descendant(
          of: find.byType(ToolMetric),
          matching: find.text('4'),
        ),
        findsOneWidget,
      );
    });
  });

  group('HashGeneratorScreen copy', () {
    testWidgets('first CopyValueAction copies the MD5 digest of abc', (
      tester,
    ) async {
      final writer = FakeCopyWriter();
      await tester.pumpWidget(
        wrapScreen(HashGeneratorScreen(copyWriter: writer)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Texto'), 'abc');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Gerar hashes'));
      await tester.tap(find.text('Gerar hashes'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CopyValueAction).first);
      await tester.pumpAndSettle();

      expect(writer.lastValue, _abcMd5);
    });
  });
}
