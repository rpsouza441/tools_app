import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/app/app_destinations.dart';
import 'package:tools_app/app/app_shell.dart';
import 'package:tools_app/theme/theme.dart';

import 'design_system_gallery.dart';

/// Golden tests for design system visual regression protection.
///
/// Produces 4 baseline PNGs:
/// - primitives_compact_light: 360x800, light theme, gallery only
/// - primitives_compact_dark: 360x800, dark theme, gallery only
/// - shell_medium_light: 720x1024, light theme, AppShell + gallery
/// - shell_expanded_dark: 1024x768, dark theme, AppShell + gallery
void main() {
  group('Design system golden tests', () {
    testWidgets('primitives compact light', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          debugShowCheckedModeBanner: false,
          home: const Scaffold(body: DesignSystemGallery()),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/primitives_compact_light.png'),
      );
    });

    testWidgets('primitives compact dark', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          debugShowCheckedModeBanner: false,
          home: const Scaffold(body: DesignSystemGallery()),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/primitives_compact_dark.png'),
      );
    });

    testWidgets('shell medium light', (tester) async {
      tester.view.physicalSize = const Size(720, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          debugShowCheckedModeBanner: false,
          home: AppShell(destinations: _fakeDestinations),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/shell_medium_light.png'),
      );
    });

    testWidgets('shell expanded dark', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          debugShowCheckedModeBanner: false,
          home: AppShell(destinations: _fakeDestinations),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/shell_expanded_dark.png'),
      );
    });
  });
}

/// Fake destinations for golden tests.
/// Uses simple widgets as pages to avoid production screen dependencies.
final List<AppDestination> _fakeDestinations = [
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
    id: 'page_two',
    label: 'Página 2',
    semanticLabel: 'Página de Teste 2',
    icon: Icons.science_outlined,
    selectedIcon: Icons.science,
    category: AppDestinationCategory.armazenamento,
    compactPriority: 2,
    pageBuilder: (_) => const Center(child: Text('Página 2')),
  ),
  AppDestination(
    id: 'page_three',
    label: 'Página 3',
    semanticLabel: 'Página de Teste 3',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    category: AppDestinationCategory.hash,
    compactPriority: 3,
    pageBuilder: (_) => const Center(child: Text('Página 3')),
  ),
];
