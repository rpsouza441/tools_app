import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/theme/theme.dart';

/// Public [ToolMetric] must reflow at 360×800 with [TextScaler.linear] 2.0.
///
/// Exercises the production widget — not a cloned [Row]. Essential label and
/// `Indisponível` remain visible without overflow or ellipsis.
void main() {
  const longLabel = 'Latência média do último diagnóstico de alcance';

  testWidgets(
    'ToolMetric with long label and null value reflows at 360px with 2.0 scaler',
    (tester) async {
      assert(longLabel.length >= 40, 'behavior requires label ≥ 40 characters');

      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2.0)),
              child: child!,
            );
          },
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ToolMetric(label: longLabel, value: null),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason:
            'Public ToolMetric must reflow at 360×800 with TextScaler 2.0; '
            'overflow is a WR-04 failure.',
      );
      expect(find.byType(ToolMetric), findsOneWidget);
      expect(find.text(longLabel), findsOneWidget);
      expect(find.text('Indisponível'), findsOneWidget);
    },
  );
}
