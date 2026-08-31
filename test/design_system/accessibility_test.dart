import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/app/app_destinations.dart';
import 'package:tools_app/app/app_shell.dart';
import 'package:tools_app/design_system/app_tokens.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/design_system/tool_status_panel.dart';
import 'package:tools_app/theme/theme.dart';

import 'design_system_gallery.dart';

/// Five catalog-order [AppDestination]s for the public a11y fixture.
/// Page 0 is [DesignSystemGallery]. Short labels + full [semanticLabel]s.
final List<AppDestination> _publicDestinations = [
  AppDestination(
    id: 'gallery',
    label: 'Galeria',
    semanticLabel: 'Galeria de Componentes',
    icon: Icons.palette_outlined,
    selectedIcon: Icons.palette,
    category: AppDestinationCategory.rede,
    compactPriority: 1,
    pageBuilder: (_) => const DesignSystemGallery(),
  ),
  AppDestination(
    id: 'network_calculator',
    label: 'Rede',
    semanticLabel: 'Calculadora de Rede',
    icon: Icons.network_check_outlined,
    selectedIcon: Icons.network_check,
    category: AppDestinationCategory.rede,
    compactPriority: 2,
    pageBuilder: (_) => const Center(child: Text('Rede')),
  ),
  AppDestination(
    id: 'data_converter',
    label: 'Armazenamento',
    semanticLabel: 'Conversor de Dados',
    icon: Icons.storage_outlined,
    selectedIcon: Icons.storage,
    category: AppDestinationCategory.armazenamento,
    compactPriority: 3,
    pageBuilder: (_) => const Center(child: Text('Armazenamento')),
  ),
  AppDestination(
    id: 'hash_generator',
    label: 'Hash',
    semanticLabel: 'Gerador de Hash',
    icon: Icons.tag_outlined,
    selectedIcon: Icons.tag,
    category: AppDestinationCategory.hash,
    compactPriority: 4,
    pageBuilder: (_) => const Center(child: Text('Hash')),
  ),
  AppDestination(
    id: 'extra',
    label: 'Extra',
    semanticLabel: 'Destino extra de teste',
    icon: Icons.science_outlined,
    selectedIcon: Icons.science,
    category: AppDestinationCategory.rede,
    compactPriority: 5,
    pageBuilder: (_) => const Center(child: Text('Extra')),
  ),
];

/// Real public shell + gallery. Does not clone AppShell/ToolScaffold/ToolMetric.
Widget _buildPublicFixture(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: AppShell(destinations: _publicDestinations),
  );
}

Future<void> _pumpSizedFixture(
  WidgetTester tester, {
  required double width,
  required double scale,
  required ThemeData theme,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(_buildPublicFixture(theme));
  // Loading ToolStatusPanel uses an infinite CircularProgressIndicator.
  await tester.pump();
}

void main() {
  group('Theme role tests', () {
    test('lightTheme uses neutral onSurface (not saturated green)', () {
      final cs = lightTheme.colorScheme;
      // D-05: Body text must be neutral, not saturated green.
      // M3 fromSeed produces a tinted neutral (very low saturation, green-ish hue).
      // That is acceptable. The old matrix theme used #00FF41 (saturation ~1.0).
      // Reject if saturation >= 0.5 AND hue is in green range.
      final hsl = HSLColor.fromColor(cs.onSurface);
      final isSaturatedGreen =
          hsl.saturation >= 0.5 && hsl.hue >= 80 && hsl.hue <= 170;
      expect(
        isSaturatedGreen,
        isFalse,
        reason:
            'onSurface should not be saturated green. Got: ${cs.onSurface} '
            '(H:${hsl.hue.toStringAsFixed(1)} S:${hsl.saturation.toStringAsFixed(2)} L:${hsl.lightness.toStringAsFixed(2)})',
      );
    });

    test('darkTheme uses neutral onSurface (not saturated green)', () {
      final cs = darkTheme.colorScheme;
      final hsl = HSLColor.fromColor(cs.onSurface);
      final isSaturatedGreen =
          hsl.saturation >= 0.5 && hsl.hue >= 80 && hsl.hue <= 170;
      expect(
        isSaturatedGreen,
        isFalse,
        reason:
            'onSurface should not be saturated green. Got: ${cs.onSurface} '
            '(H:${hsl.hue.toStringAsFixed(1)} S:${hsl.saturation.toStringAsFixed(2)} L:${hsl.lightness.toStringAsFixed(2)})',
      );
    });

    test('lightTheme primary is green accent', () {
      final cs = lightTheme.colorScheme;
      final hsl = HSLColor.fromColor(cs.primary);
      expect(
        hsl.hue,
        inInclusiveRange(80, 170),
        reason: 'primary should be green',
      );
    });

    test('darkTheme primary is green accent', () {
      final cs = darkTheme.colorScheme;
      final hsl = HSLColor.fromColor(cs.primary);
      expect(
        hsl.hue,
        inInclusiveRange(80, 170),
        reason: 'primary should be green',
      );
    });

    test('light and dark share the same semantic color roles', () {
      // D-08: both schemes define the same role names; values differ for brightness
      final lightRoles = lightTheme.colorScheme;
      final darkRoles = darkTheme.colorScheme;
      // Both must have non-null error, primary, surface, onSurface
      expect(lightRoles.error, isNotNull);
      expect(darkRoles.error, isNotNull);
      expect(lightRoles.primary, isNotNull);
      expect(darkRoles.primary, isNotNull);
    });
  });

  group('AppTokens tests', () {
    testWidgets('AppTokens is accessible via Theme.of(context).extension', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: Builder(
            builder: (context) {
              final tokens = Theme.of(context).extension<AppTokens>();
              // Verify tokens are installed
              expect(tokens, isNotNull);
              expect(tokens!.spacing4, 4.0);
              expect(tokens.spacing8, 8.0);
              expect(tokens.spacing16, 16.0);
              expect(tokens.spacing24, 24.0);
              expect(tokens.spacing32, 32.0);
              expect(tokens.spacing48, 48.0);
              expect(tokens.spacing64, 64.0);
              expect(tokens.radius4, 4.0);
              expect(tokens.radius8, 8.0);
              expect(tokens.radius12, 12.0);
              expect(tokens.formMaxWidth, 720.0);
              expect(tokens.contentMaxWidth, 960.0);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('AppTokens is accessible in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: Builder(
            builder: (context) {
              final tokens = Theme.of(context).extension<AppTokens>();
              expect(tokens, isNotNull);
              expect(tokens!.formMaxWidth, 720.0);
              expect(tokens.contentMaxWidth, 960.0);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('Typography tests', () {
    test('bodyMedium fontSize is 14', () {
      expect(lightTheme.textTheme.bodyMedium?.fontSize, 14.0);
      expect(darkTheme.textTheme.bodyMedium?.fontSize, 14.0);
    });

    test('bodyLarge fontSize is 16', () {
      expect(lightTheme.textTheme.bodyLarge?.fontSize, 16.0);
      expect(darkTheme.textTheme.bodyLarge?.fontSize, 16.0);
    });

    test('titleLarge fontSize is 20', () {
      expect(lightTheme.textTheme.titleLarge?.fontSize, 20.0);
      expect(darkTheme.textTheme.titleLarge?.fontSize, 20.0);
    });

    test('headlineSmall fontSize is 28', () {
      expect(lightTheme.textTheme.headlineSmall?.fontSize, 28.0);
      expect(darkTheme.textTheme.headlineSmall?.fontSize, 28.0);
    });

    test('body text uses regular weight (400)', () {
      expect(lightTheme.textTheme.bodyMedium?.fontWeight, FontWeight.w400);
      expect(darkTheme.textTheme.bodyMedium?.fontWeight, FontWeight.w400);
    });

    test('label text uses semi-bold weight (600)', () {
      expect(lightTheme.textTheme.labelLarge?.fontWeight, FontWeight.w600);
      expect(darkTheme.textTheme.labelLarge?.fontWeight, FontWeight.w600);
    });

    test('no google_fonts runtime fetch in text theme', () {
      // D-06: TextTheme should use the default Material sans-serif family.
      // If google_fonts were used, the fontFamily would be a specific named font.
      // Default Material 3 uses Roboto/system font with no explicit fontFamily.
      final bodyStyle = lightTheme.textTheme.bodyMedium;
      // With default Material, fontFamily is null (inherits) or system default
      expect(
        bodyStyle?.fontFamily == null ||
            bodyStyle!.fontFamily == 'Roboto' ||
            !bodyStyle.fontFamily!.contains('Lato'),
        isTrue,
        reason:
            'Font should not be Lato (google_fonts). Got: ${bodyStyle?.fontFamily}',
      );
    });
  });

  group('Public widgets fixture', () {
    testWidgets(
      'mounts AppShell, ToolScaffold, ToolMetric, ToolStatusPanel, TechnicalValueRow with copy',
      (tester) async {
        await tester.pumpWidget(_buildPublicFixture(lightTheme));
        await tester.pump();

        expect(find.byType(AppShell), findsOneWidget);
        expect(find.byType(ToolScaffold), findsOneWidget);
        expect(find.byType(ToolMetric), findsWidgets);
        expect(find.byType(ToolStatusPanel), findsWidgets);
        expect(find.byType(TechnicalValueRow), findsOneWidget);
        expect(find.byType(CopyValueAction), findsOneWidget);
      },
    );
  });

  group('Accessibility guideline tests — light theme', () {
    testWidgets('meets androidTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildPublicFixture(lightTheme));
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('meets labeledTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildPublicFixture(lightTheme));
      await tester.pump();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('meets textContrastGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildPublicFixture(lightTheme));
      await tester.pump();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('Accessibility guideline tests — dark theme', () {
    testWidgets('meets androidTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildPublicFixture(darkTheme));
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('meets labeledTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildPublicFixture(darkTheme));
      await tester.pump();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('meets textContrastGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildPublicFixture(darkTheme));
      await tester.pump();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('Text scale matrix — no overflow', () {
    // D-17: Large text scale must not clamp; reflow and reachability required.
    final widths = [360.0, 720.0, 1024.0];
    final scales = [1.0, 2.0];

    for (final width in widths) {
      for (final scale in scales) {
        testWidgets(
          'no overflow at ${width.toInt()}px width, ${scale}x scale',
          (tester) async {
            await _pumpSizedFixture(
              tester,
              width: width,
              scale: scale,
              theme: lightTheme,
            );

            expect(find.byType(AppShell), findsOneWidget);
            expect(find.byType(ToolScaffold), findsOneWidget);
            expect(find.byType(ToolMetric), findsWidgets);
            expect(find.byType(ToolStatusPanel), findsWidgets);
            expect(find.byType(TechnicalValueRow), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('AppShell semantics and overflow chrome', () {
    testWidgets(
      '360 Bar with 5 destinations shows Ferramentas and full semanticLabels',
      (tester) async {
        final handle = tester.ensureSemantics();
        await _pumpSizedFixture(
          tester,
          width: 360,
          scale: 1.0,
          theme: lightTheme,
        );

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Ferramentas'),
          ),
          findsOneWidget,
        );
        expect(find.byTooltip('Galeria de Componentes'), findsOneWidget);
        expect(find.byTooltip('Calculadora de Rede'), findsOneWidget);
        expect(find.byTooltip('Conversor de Dados'), findsOneWidget);
        handle.dispose();
      },
    );

    testWidgets('720 rail shows 5 destinations and does not show Ferramentas', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pumpSizedFixture(
        tester,
        width: 720,
        scale: 1.0,
        theme: lightTheme,
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Ferramentas'), findsNothing);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.destinations, hasLength(5));
      expect(rail.extended, isFalse);
      for (final label in [
        'Galeria de Componentes',
        'Calculadora de Rede',
        'Conversor de Dados',
        'Gerador de Hash',
        'Destino extra de teste',
      ]) {
        expect(find.byTooltip(label), findsOneWidget);
        expect(
          find.bySemanticsLabel(RegExp(RegExp.escape(label))),
          findsWidgets,
        );
      }
      handle.dispose();
    });

    testWidgets(
      '1024 rail shows 5 destinations and does not show Ferramentas',
      (tester) async {
        final handle = tester.ensureSemantics();
        await _pumpSizedFixture(
          tester,
          width: 1024,
          scale: 1.0,
          theme: lightTheme,
        );

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.text('Ferramentas'), findsNothing);
        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.destinations, hasLength(5));
        expect(rail.extended, isTrue);
        for (final label in [
          'Galeria de Componentes',
          'Calculadora de Rede',
          'Conversor de Dados',
          'Gerador de Hash',
          'Destino extra de teste',
        ]) {
          expect(
            find.bySemanticsLabel(RegExp(RegExp.escape(label))),
            findsWidgets,
          );
        }
        handle.dispose();
      },
    );
  });
}
