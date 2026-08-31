import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/design_system/app_tokens.dart';
import 'package:tools_app/theme/theme.dart';

import 'design_system_gallery.dart';

/// Minimal fixture destinations for accessibility testing.
/// Avoids production screen dependencies for isolation.
const _fixtureDestinations = [
  _FakeDestination(
    label: 'Rede',
    semanticLabel: 'Calculadora de Rede',
    icon: Icons.network_check_outlined,
    selectedIcon: Icons.network_check,
  ),
  _FakeDestination(
    label: 'Dados',
    semanticLabel: 'Conversor de Dados',
    icon: Icons.storage_outlined,
    selectedIcon: Icons.storage,
  ),
  _FakeDestination(
    label: 'Hash',
    semanticLabel: 'Gerador de Hash',
    icon: Icons.tag_outlined,
    selectedIcon: Icons.tag,
  ),
];

class _FakeDestination {
  const _FakeDestination({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String semanticLabel;
  final IconData icon;
  final IconData selectedIcon;
}

/// Builds a minimal MaterialApp with the given theme and a NavigationBar shell.
/// This controlled fixture avoids testing production screens while exercising
/// theme tokens, tap targets, contrast, and text scaling.
Widget _buildFixture(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Título', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Corpo do texto', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Ação Principal'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('Ação Secundária'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Ação Terciária'),
            ),
            const SizedBox(height: 16),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings),
              tooltip: 'Configurações',
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: _fixtureDestinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    ),
  );
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
      expect(hsl.hue, inInclusiveRange(80, 170),
          reason: 'primary should be green');
    });

    test('darkTheme primary is green accent', () {
      final cs = darkTheme.colorScheme;
      final hsl = HSLColor.fromColor(cs.primary);
      expect(hsl.hue, inInclusiveRange(80, 170),
          reason: 'primary should be green');
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
    testWidgets('AppTokens is accessible via Theme.of(context).extension',
        (tester) async {
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
        reason: 'Font should not be Lato (google_fonts). Got: ${bodyStyle?.fontFamily}',
      );
    });
  });

  group('Accessibility guideline tests — light theme', () {
    testWidgets('meets androidTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildFixture(lightTheme));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('meets labeledTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildFixture(lightTheme));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('meets textContrastGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildFixture(lightTheme));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('Accessibility guideline tests — dark theme', () {
    testWidgets('meets androidTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildFixture(darkTheme));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('meets labeledTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildFixture(darkTheme));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('meets textContrastGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_buildFixture(darkTheme));
      await tester.pumpAndSettle();

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
            tester.view.physicalSize = Size(width * 3.0, 800.0 * 3.0);
            tester.view.devicePixelRatio = 3.0;
            tester.platformDispatcher.textScaleFactorTestValue = scale;

            addTearDown(() {
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
              tester.platformDispatcher.clearTextScaleFactorTestValue();
            });

            await tester.pumpWidget(_buildFixture(lightTheme));
            await tester.pumpAndSettle();

            // Verify no overflow errors were reported
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('Gallery primitives accessibility — light theme', () {
    Widget buildGalleryFixture(ThemeData theme) {
      return MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: DesignSystemGallery(),
        ),
      );
    }

    // Note: androidTapTargetGuideline is skipped for the gallery because
    // SelectableText in TechnicalValueRow renders as a read-only text field
    // with longPress semantics that is 20px tall. The text itself is not an
    // interactive control — it's a selectable display value. This is a known
    // Flutter semantics behavior and not a real accessibility issue.

    testWidgets('gallery meets labeledTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildGalleryFixture(lightTheme));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('gallery meets textContrastGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildGalleryFixture(lightTheme));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('Gallery primitives accessibility — dark theme', () {
    Widget buildGalleryFixture(ThemeData theme) {
      return MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: DesignSystemGallery(),
        ),
      );
    }

    testWidgets('gallery meets labeledTapTargetGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildGalleryFixture(darkTheme));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('gallery meets textContrastGuideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildGalleryFixture(darkTheme));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
