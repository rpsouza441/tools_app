import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/design_system/tool_status_panel.dart';
import 'package:tools_app/theme/theme.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Fake clipboard writer that records calls for verification.
class FakeCopyWriter implements CopyValueWriter {
  String? lastValue;
  int callCount = 0;
  bool shouldThrow = false;

  @override
  Future<void> write(String value) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('Clipboard failure');
    }
    lastValue = value;
  }
}

/// Wraps a widget in MaterialApp with the light theme for testing.
Widget _wrap(Widget child, {double? width}) {
  final app = MaterialApp(
    theme: lightTheme,
    home: Scaffold(body: child),
  );
  if (width != null) {
    return MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: app,
    );
  }
  return app;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('tool anatomy', () {
    testWidgets('ToolScaffold renders title as heading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          const ToolScaffold(
            title: 'Calculadora de Rede',
            children: [Text('content')],
          ),
        ),
      );

      final titleFinder = find.text('Calculadora de Rede');
      expect(titleFinder, findsOneWidget);

      // The title Text is wrapped in a Semantics widget with header: true.
      // Find the nearest Semantics ancestor that has header property set.
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.ancestor(of: titleFinder, matching: find.byType(Semantics)),
      );
      final hasHeaderSemantics = semanticsWidgets.any(
        (s) => s.properties.header == true,
      );
      expect(hasHeaderSemantics, isTrue);
      handle.dispose();
    });

    testWidgets('ToolScaffold renders optional summary', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ToolScaffold(
            title: 'Título',
            summary: 'Uma descrição breve',
            children: [Text('content')],
          ),
        ),
      );

      expect(find.text('Uma descrição breve'), findsOneWidget);
    });

    testWidgets('ToolScaffold respects contentMaxWidth', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(const ToolScaffold(title: 'Test', children: [Text('content')])),
      );

      // Find the ConstrainedBox with contentMaxWidth (960)
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final hasMaxWidth960 = constrainedBoxes.any(
        (box) => box.constraints.maxWidth == 960.0,
      );
      expect(hasMaxWidth960, isTrue);
    });

    testWidgets('ToolScaffold uses 16px padding at compact width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(const ToolScaffold(title: 'Test', children: [Text('content')])),
      );

      // Find the Padding inside the ConstrainedBox
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(ConstrainedBox),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, EdgeInsets.all(16.0));
    });

    testWidgets('ToolScaffold uses 24px padding at medium width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(const ToolScaffold(title: 'Test', children: [Text('content')])),
      );

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(ConstrainedBox),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, EdgeInsets.all(24.0));
    });

    testWidgets('ToolScaffold uses 32px padding at expanded width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(const ToolScaffold(title: 'Test', children: [Text('content')])),
      );

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(ConstrainedBox),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, EdgeInsets.all(32.0));
    });

    testWidgets('ToolInputSection renders children with spacing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ToolInputSection(
            children: [
              TextField(decoration: InputDecoration(labelText: 'Campo 1')),
              TextField(decoration: InputDecoration(labelText: 'Campo 2')),
            ],
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(2));
      // Verify spacing SizedBox exists between them
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('ToolActionGroup renders primary action', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ToolActionGroup(
            primary: ElevatedButton(
              onPressed: () {},
              child: const Text('Calcular'),
            ),
          ),
        ),
      );

      expect(find.text('Calcular'), findsOneWidget);
    });

    testWidgets('ToolActionGroup renders cancel when onCancel provided', (
      tester,
    ) async {
      var cancelled = false;
      await tester.pumpWidget(
        _wrap(
          ToolActionGroup(
            primary: ElevatedButton(
              onPressed: () {},
              child: const Text('Executar'),
            ),
            onCancel: () => cancelled = true,
          ),
        ),
      );

      expect(find.text('Cancelar'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      expect(cancelled, isTrue);
    });

    testWidgets('ToolActionGroup wraps actions at narrow width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(
          ToolActionGroup(
            primary: ElevatedButton(
              onPressed: () {},
              child: const Text('Ação Principal Longa'),
            ),
            secondary: OutlinedButton(
              onPressed: () {},
              child: const Text('Ação Secundária Longa'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both buttons should render without overflow
      expect(find.text('Ação Principal Longa'), findsOneWidget);
      expect(find.text('Ação Secundária Longa'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ToolResultCard wraps child in Card with padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ToolResultCard(child: Text('Resultado'))),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Resultado'), findsOneWidget);
    });

    testWidgets('ToolMetric displays label and value', (tester) async {
      await tester.pumpWidget(
        _wrap(const ToolMetric(label: 'Latência:', value: '42ms')),
      );

      expect(find.text('Latência:'), findsOneWidget);
      expect(find.text('42ms'), findsOneWidget);
    });

    testWidgets('ToolMetric shows Indisponível for null value', (tester) async {
      await tester.pumpWidget(
        _wrap(const ToolMetric(label: 'Latência:', value: null)),
      );

      expect(find.text('Latência:'), findsOneWidget);
      expect(find.text('Indisponível'), findsOneWidget);
    });

    testWidgets('ToolMetricLayout renders multiple metrics', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ToolMetricLayout(
            metrics: [
              ToolMetric(label: 'A:', value: '1'),
              ToolMetric(label: 'B:', value: '2'),
            ],
          ),
        ),
      );

      expect(find.byType(ToolMetric), findsNWidgets(2));
    });

    testWidgets('TechnicalValueRow renders label, value, and copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          TechnicalValueRow(
            label: 'IP Público',
            value: '192.168.1.1',
            onCopy: () {},
          ),
        ),
      );

      expect(find.text('IP Público'), findsOneWidget);
      expect(find.text('192.168.1.1'), findsOneWidget);
      expect(find.byType(CopyValueAction), findsOneWidget);
    });

    testWidgets('TechnicalValueRow hides copy when onCopy is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const TechnicalValueRow(label: 'IP', value: '10.0.0.1')),
      );

      expect(find.byType(CopyValueAction), findsNothing);
    });

    testWidgets('TechnicalValueRow renders metadata when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          TechnicalValueRow(
            label: 'Gateway',
            value: '192.168.0.1',
            metadata: 'via Wi-Fi',
            onCopy: () {},
          ),
        ),
      );

      expect(find.text('via Wi-Fi'), findsOneWidget);
    });
  });

  group('status', () {
    // Canonical copy from 01-UI-SPEC.md State Contract — literals in this
    // file only. Never import or call production _statusMap.
    const expectedStatus =
        <
          ToolStatusVariant,
          ({
            IconData? icon,
            String heading,
            String body,
            bool progressIndicator,
            String iconRole,
          })
        >{
          ToolStatusVariant.empty: (
            icon: Icons.inbox_outlined,
            heading: 'Nenhum resultado ainda',
            body:
                'Preencha os campos e execute a ferramenta para ver os resultados.',
            progressIndicator: false,
            iconRole: 'onSurface',
          ),
          ToolStatusVariant.loading: (
            icon: null,
            heading: 'Processando',
            body: 'Aguarde enquanto concluímos esta etapa.',
            progressIndicator: true,
            iconRole: 'onSurface',
          ),
          ToolStatusVariant.success: (
            icon: Icons.check_circle_outline,
            heading: 'Concluído',
            body: 'Resultado disponível abaixo.',
            progressIndicator: false,
            iconRole: 'primary',
          ),
          ToolStatusVariant.failure: (
            icon: Icons.error_outline,
            heading: 'Não foi possível concluir',
            body: 'Confira os dados e tente novamente.',
            progressIndicator: false,
            iconRole: 'error',
          ),
          ToolStatusVariant.offline: (
            icon: Icons.wifi_off,
            heading: 'Sem conexão com a internet',
            body: 'Verifique a conexão e tente novamente.',
            progressIndicator: false,
            iconRole: 'onSurface',
          ),
          ToolStatusVariant.permissionDenied: (
            icon: Icons.lock_outline,
            heading: 'Permissão necessária',
            body: 'Ative a permissão nas configurações para continuar.',
            progressIndicator: false,
            iconRole: 'error',
          ),
          ToolStatusVariant.cancelled: (
            icon: Icons.cancel_outlined,
            heading: 'Operação cancelada',
            body: 'Os resultados concluídos continuam disponíveis.',
            progressIndicator: false,
            iconRole: 'onSurface',
          ),
        };

    Widget wrapStatus(Widget child, ThemeData theme) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(body: child),
      );
    }

    Color roleColor(ColorScheme cs, String role) {
      return switch (role) {
        'primary' => cs.primary,
        'error' => cs.error,
        _ => cs.onSurface,
      };
    }

    for (final themeEntry in <(String, ThemeData)>[
      ('light', lightTheme),
      ('dark', darkTheme),
    ]) {
      final themeName = themeEntry.$1;
      final theme = themeEntry.$2;

      for (final entry in expectedStatus.entries) {
        testWidgets(
          '${entry.key.name} ($themeName) renders canonical icon, heading, body, and icon role',
          (tester) async {
            await tester.pumpWidget(
              wrapStatus(ToolStatusPanel(variant: entry.key), theme),
            );

            final expected = entry.value;
            expect(find.text(expected.heading), findsOneWidget);
            expect(find.text(expected.body), findsOneWidget);

            if (expected.progressIndicator) {
              // byType matches exact runtimeType; CircularProgressIndicator
              // is a ProgressIndicator subclass.
              final progressFinder = find.byWidgetPredicate(
                (widget) => widget is ProgressIndicator,
              );
              expect(progressFinder, findsOneWidget);
              final indicator = tester.widget<ProgressIndicator>(
                progressFinder,
              );
              expect(indicator.color, theme.colorScheme.onSurface);
            } else {
              expect(find.byIcon(expected.icon!), findsOneWidget);
              final iconWidget = tester.widget<Icon>(
                find.byIcon(expected.icon!),
              );
              expect(
                iconWidget.color,
                roleColor(theme.colorScheme, expected.iconRole),
              );
              if (entry.key == ToolStatusVariant.offline) {
                expect(iconWidget.color, isNot(theme.colorScheme.error));
              }
            }
          },
        );
      }
    }

    testWidgets('preservedChild shown for loading variant', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ToolStatusPanel(
            variant: ToolStatusVariant.loading,
            preservedChild: Text('Previous result'),
          ),
        ),
      );

      expect(find.text('Previous result'), findsOneWidget);
    });

    testWidgets('preservedChild shown for failure variant', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ToolStatusPanel(
            variant: ToolStatusVariant.failure,
            preservedChild: Text('Cached data'),
          ),
        ),
      );

      expect(find.text('Cached data'), findsOneWidget);
    });

    testWidgets('preservedChild shown for cancelled variant', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ToolStatusPanel(
            variant: ToolStatusVariant.cancelled,
            preservedChild: Text('Partial result'),
          ),
        ),
      );

      expect(find.text('Partial result'), findsOneWidget);
    });

    testWidgets('preservedChild NOT shown for success variant', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ToolStatusPanel(
            variant: ToolStatusVariant.success,
            preservedChild: Text('Should not appear'),
          ),
        ),
      );

      expect(find.text('Should not appear'), findsNothing);
    });

    testWidgets('preservedChild NOT shown for empty variant', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ToolStatusPanel(
            variant: ToolStatusVariant.empty,
            preservedChild: Text('Should not appear'),
          ),
        ),
      );

      expect(find.text('Should not appear'), findsNothing);
    });

    testWidgets('onRetry shows retry button', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(
          ToolStatusPanel(
            variant: ToolStatusVariant.failure,
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Tentar novamente'), findsOneWidget);
      await tester.tap(find.text('Tentar novamente'));
      expect(retried, isTrue);
    });

    testWidgets('retry button hidden when onRetry is null', (tester) async {
      await tester.pumpWidget(
        _wrap(const ToolStatusPanel(variant: ToolStatusVariant.failure)),
      );

      expect(find.text('Tentar novamente'), findsNothing);
    });

    testWidgets('onSettings shows settings button', (tester) async {
      var opened = false;
      await tester.pumpWidget(
        _wrap(
          ToolStatusPanel(
            variant: ToolStatusVariant.permissionDenied,
            onSettings: () => opened = true,
          ),
        ),
      );

      expect(find.text('Configurações'), findsOneWidget);
      await tester.tap(find.text('Configurações'));
      expect(opened, isTrue);
    });

    testWidgets('settings button hidden when onSettings is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ToolStatusPanel(variant: ToolStatusVariant.permissionDenied),
        ),
      );

      expect(find.text('Configurações'), findsNothing);
    });
  });

  group('copy', () {
    testWidgets('CopyValueAction copies exact value via injected writer', (
      tester,
    ) async {
      final writer = FakeCopyWriter();
      await tester.pumpWidget(
        _wrap(
          CopyValueAction(
            label: 'endereço IP',
            value: '192.168.1.100',
            writer: writer,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pumpAndSettle();

      expect(writer.lastValue, '192.168.1.100');
      expect(writer.callCount, 1);
    });

    testWidgets('CopyValueAction shows confirmation SnackBar', (tester) async {
      final writer = FakeCopyWriter();
      await tester.pumpWidget(
        _wrap(
          CopyValueAction(
            label: 'endereço IP',
            value: '192.168.1.100',
            writer: writer,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.copy));
      await tester.pumpAndSettle();

      expect(find.text('Endereço IP copiado'), findsOneWidget);
    });

    testWidgets('CopyValueAction hides prior SnackBar before showing new', (
      tester,
    ) async {
      final writer = FakeCopyWriter();
      await tester.pumpWidget(
        _wrap(CopyValueAction(label: 'valor', value: 'test', writer: writer)),
      );

      // Tap twice quickly
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pumpAndSettle();

      // Should only show one SnackBar
      expect(find.text('Valor copiado'), findsOneWidget);
      expect(writer.callCount, 2);
    });

    testWidgets('CopyValueAction shows fallback message on writer failure', (
      tester,
    ) async {
      final writer = FakeCopyWriter()..shouldThrow = true;
      await tester.pumpWidget(
        _wrap(CopyValueAction(label: 'hash', value: 'abc123', writer: writer)),
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

    testWidgets('CopyValueAction has tooltip with label', (tester) async {
      final writer = FakeCopyWriter();
      await tester.pumpWidget(
        _wrap(
          CopyValueAction(label: 'resultado', value: 'value', writer: writer),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Copiar resultado');
    });

    testWidgets('CopyValueAction has 48px minimum size', (tester) async {
      final writer = FakeCopyWriter();
      await tester.pumpWidget(
        _wrap(CopyValueAction(label: 'test', value: 'value', writer: writer)),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.constraints?.minWidth, 48.0);
      expect(iconButton.constraints?.minHeight, 48.0);
    });

    testWidgets('TechnicalValueRow renders label and value with copy action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          TechnicalValueRow(label: 'Gateway', value: '10.0.0.1', onCopy: () {}),
        ),
      );

      expect(find.text('Gateway'), findsOneWidget);
      expect(find.text('10.0.0.1'), findsOneWidget);
      expect(find.byType(CopyValueAction), findsOneWidget);
    });
  });
}
