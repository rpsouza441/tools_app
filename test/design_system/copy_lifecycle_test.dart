import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/theme/theme.dart';

/// Writer that stays pending until [completer] is completed.
class CompleterCopyWriter implements CopyValueWriter {
  CompleterCopyWriter(this.completer);

  final Completer<void> completer;

  @override
  Future<void> write(String value) => completer.future;
}

/// Writer that records the exact value passed to [write].
class RecordingCopyWriter implements CopyValueWriter {
  String? written;

  @override
  Future<void> write(String value) async {
    written = value;
  }
}

/// Writer that always fails so the fallback SnackBar can be asserted.
class ThrowingCopyWriter implements CopyValueWriter {
  @override
  Future<void> write(String value) {
    throw Exception('Clipboard failure');
  }
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    home: Scaffold(body: child),
  );
}

void main() {
  group('copy lifecycle', () {
    testWidgets('dispose before writer completes does not throw', (
      tester,
    ) async {
      final completer = Completer<void>();
      final writer = CompleterCopyWriter(completer);
      final errors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details);
        previousOnError?.call(details);
      };
      addTearDown(() {
        FlutterError.onError = previousOnError;
      });

      await tester.pumpWidget(
        _wrap(
          CopyValueAction(
            label: 'endereço de rede',
            value: '192.168.1.1',
            writer: writer,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());

      completer.complete();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(errors, isEmpty);
    });

    testWidgets('copy does not hide unrelated SnackBar', (tester) async {
      final writer = RecordingCopyWriter();

      await tester.pumpWidget(
        _wrap(
          CopyValueAction(
            label: 'endereço de rede',
            value: '192.168.1.1',
            writer: writer,
          ),
        ),
      );

      final messenger = ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold)),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Aviso não relacionado')),
      );
      await tester.pump();
      expect(find.text('Aviso não relacionado'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Aviso não relacionado'), findsOneWidget);
      expect(writer.written, '192.168.1.1');
    });

    testWidgets(
      'TechnicalValueRow copyWriter is invoked with the exact displayed value',
      (tester) async {
        final writer = RecordingCopyWriter();

        await tester.pumpWidget(
          _wrap(
            TechnicalValueRow(
              label: 'endereço de rede',
              value: '192.168.1.1',
              copyWriter: writer,
            ),
          ),
        );

        await tester.tap(find.byType(CopyValueAction));
        await tester.pump();

        expect(writer.written, '192.168.1.1');
      },
    );

    testWidgets(
      'tooltip and semantics name the label; success SnackBar capitalizes it',
      (tester) async {
        final writer = RecordingCopyWriter();
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          _wrap(
            CopyValueAction(
              label: 'endereço de rede',
              value: '10.0.0.1',
              writer: writer,
            ),
          ),
        );

        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.tooltip, 'Copiar endereço de rede');
        expect(find.byTooltip('Copiar endereço de rede'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Copiar endereço de rede'),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.copy));
        await tester.pumpAndSettle();

        expect(find.text('Endereço de rede copiado'), findsOneWidget);
        handle.dispose();
      },
    );

    testWidgets('writer failure shows fallback SnackBar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CopyValueAction(
            label: 'endereço de rede',
            value: '10.0.0.1',
            writer: ThrowingCopyWriter(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Não foi possível copiar. Selecione o valor e copie manualmente.',
        ),
        findsOneWidget,
      );
    });
  });
}
