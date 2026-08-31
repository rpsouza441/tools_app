import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/app/app_destinations.dart';
import 'package:tools_app/app/app_shell.dart';
import 'package:tools_app/design_system/app_breakpoints.dart';
import 'package:tools_app/main.dart';

void main() {
  group('AppBreakpoints', () {
    test('classifies < 600 as compact', () {
      expect(AppBreakpoints.classify(599), AppWidthClass.compact);
      expect(AppBreakpoints.classify(320), AppWidthClass.compact);
    });

    test('classifies 600-839 as medium', () {
      expect(AppBreakpoints.classify(600), AppWidthClass.medium);
      expect(AppBreakpoints.classify(839), AppWidthClass.medium);
    });

    test('classifies >= 840 as expanded', () {
      expect(AppBreakpoints.classify(840), AppWidthClass.expanded);
      expect(AppBreakpoints.classify(1200), AppWidthClass.expanded);
    });
  });

  group('AppShell boundary adaptation', () {
    testWidgets('shows NavigationBar at 599px width', (tester) async {
      tester.view.physicalSize = const Size(599, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: AppShell(destinations: appDestinations)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('shows collapsed NavigationRail at 600px width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: AppShell(destinations: appDestinations)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
    });

    testWidgets('shows extended NavigationRail at 840px width', (tester) async {
      tester.view.physicalSize = const Size(840, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: AppShell(destinations: appDestinations)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
    });
  });

  group('AppShell state preservation', () {
    testWidgets('IndexedStack preserves page state on navigation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Use a custom stateful destination to detect rebuilds
      final destinations = [
        AppDestination(
          id: 'counter',
          label: 'Contador',
          semanticLabel: 'Contador de teste',
          icon: Icons.circle_outlined,
          selectedIcon: Icons.circle,
          category: AppDestinationCategory.rede,
          compactPriority: 1,
          pageBuilder: (_) => const _CounterPage(key: ValueKey('counter')),
        ),
        AppDestination(
          id: 'placeholder',
          label: 'Outro',
          semanticLabel: 'Outro teste',
          icon: Icons.star_outline,
          selectedIcon: Icons.star,
          category: AppDestinationCategory.hash,
          compactPriority: 2,
          pageBuilder: (_) => const Scaffold(body: Text('Placeholder')),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: AppShell(destinations: destinations)),
      );
      await tester.pumpAndSettle();

      // Tap the increment button on counter page (use FAB to avoid ambiguity)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      // Navigate to second destination
      await tester.tap(find.text('Outro'));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.text('Contador'));
      await tester.pumpAndSettle();

      // State is preserved
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('IndexedStack preserves state across resize', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final destinations = [
        AppDestination(
          id: 'counter',
          label: 'Contador',
          semanticLabel: 'Contador de teste',
          icon: Icons.circle_outlined,
          selectedIcon: Icons.circle,
          category: AppDestinationCategory.rede,
          compactPriority: 1,
          pageBuilder: (_) => const _CounterPage(key: ValueKey('counter')),
        ),
        AppDestination(
          id: 'placeholder',
          label: 'Outro',
          semanticLabel: 'Outro teste',
          icon: Icons.star_outline,
          selectedIcon: Icons.star,
          category: AppDestinationCategory.hash,
          compactPriority: 2,
          pageBuilder: (_) => const Scaffold(body: Text('Placeholder')),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: AppShell(destinations: destinations)),
      );
      await tester.pumpAndSettle();

      // Increment counter (use FAB to avoid ambiguity with nav icons)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      // Resize to medium (NavigationRail)
      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpAndSettle();

      // State is preserved after resize
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('AppShell growth — D-03 overflow', () {
    testWidgets('5 destinations shows 3 compact priorities + Ferramentas', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final destinations = _buildFiveDestinations();

      await tester.pumpWidget(
        MaterialApp(home: AppShell(destinations: destinations)),
      );
      await tester.pumpAndSettle();

      // Should show 3 highest priority labels + Ferramentas
      expect(find.text('Prio1'), findsOneWidget);
      expect(find.text('Prio2'), findsOneWidget);
      expect(find.text('Prio3'), findsOneWidget);
      expect(find.text('Ferramentas'), findsOneWidget);
      // The 2 lower-priority items should NOT be visible as nav items
      expect(find.text('Prio4'), findsNothing);
      expect(find.text('Prio5'), findsNothing);
    });

    testWidgets(
      'selecting an unpinned item from Ferramentas keeps Ferramentas selected',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final destinations = _buildFiveDestinations();

        await tester.pumpWidget(
          MaterialApp(home: AppShell(destinations: destinations)),
        );
        await tester.pumpAndSettle();

        // Tap Ferramentas
        await tester.tap(find.text('Ferramentas'));
        await tester.pumpAndSettle();

        // Should show the overflow menu/sheet with lower-priority items
        expect(find.text('Prio4'), findsOneWidget);

        // Tap an unpinned item
        await tester.tap(find.text('Prio4'));
        await tester.pumpAndSettle();

        // The page of Prio4 should be visible
        expect(find.text('Page4'), findsOneWidget);

        // NavigationBar should still show Ferramentas as selected
        final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        // Ferramentas is at index 3 (after the 3 pinned items)
        expect(navBar.selectedIndex, 3);
      },
    );
  });

  group('Happy path — real App integration', () {
    testWidgets(
      'at 360x800: NavigationBar present, network calc works, state preserved',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        // NavigationBar should be present
        expect(find.byType(NavigationBar), findsOneWidget);

        // Should see the network calculator as the first screen (AppBar title)
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Calculadora de Rede'),
          ),
          findsOneWidget,
        );

        // Enter IP and CIDR in the network calculator
        await tester.enterText(
          find.widgetWithText(TextField, 'Endereço de IP'),
          '192.168.1.10',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Máscara de Sub-Rede ou CIDR'),
          '24',
        );
        await tester.pumpAndSettle();

        // Scroll down to make Calcular button visible, then tap
        await tester.ensureVisible(find.text('Calcular'));
        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        // Verify result appears
        expect(
          find.textContaining('Endereço de Rede: 192.168.1.0'),
          findsOneWidget,
        );

        // Navigate to second tab
        await tester.tap(find.text('Conversor de Dados'));
        await tester.pumpAndSettle();

        // Navigate back to first tab
        await tester.tap(find.text('Calculadora de Rede'));
        await tester.pumpAndSettle();

        // Result is still there (preserved by IndexedStack)
        expect(
          find.textContaining('Endereço de Rede: 192.168.1.0'),
          findsOneWidget,
        );
      },
    );
  });
}

/// Helper: builds 5 fake destinations with distinct compact priorities
List<AppDestination> _buildFiveDestinations() {
  return [
    AppDestination(
      id: 'prio1',
      label: 'Prio1',
      semanticLabel: 'Prioridade 1',
      icon: Icons.looks_one_outlined,
      selectedIcon: Icons.looks_one,
      category: AppDestinationCategory.rede,
      compactPriority: 1,
      pageBuilder: (_) => const Scaffold(body: Text('Page1')),
    ),
    AppDestination(
      id: 'prio2',
      label: 'Prio2',
      semanticLabel: 'Prioridade 2',
      icon: Icons.looks_two_outlined,
      selectedIcon: Icons.looks_two,
      category: AppDestinationCategory.armazenamento,
      compactPriority: 2,
      pageBuilder: (_) => const Scaffold(body: Text('Page2')),
    ),
    AppDestination(
      id: 'prio3',
      label: 'Prio3',
      semanticLabel: 'Prioridade 3',
      icon: Icons.looks_3_outlined,
      selectedIcon: Icons.looks_3,
      category: AppDestinationCategory.hash,
      compactPriority: 3,
      pageBuilder: (_) => const Scaffold(body: Text('Page3')),
    ),
    AppDestination(
      id: 'prio4',
      label: 'Prio4',
      semanticLabel: 'Prioridade 4',
      icon: Icons.looks_4_outlined,
      selectedIcon: Icons.looks_4,
      category: AppDestinationCategory.rede,
      compactPriority: 4,
      pageBuilder: (_) => const Scaffold(body: Text('Page4')),
    ),
    AppDestination(
      id: 'prio5',
      label: 'Prio5',
      semanticLabel: 'Prioridade 5',
      icon: Icons.looks_5_outlined,
      selectedIcon: Icons.looks_5,
      category: AppDestinationCategory.armazenamento,
      compactPriority: 5,
      pageBuilder: (_) => const Scaffold(body: Text('Page5')),
    ),
  ];
}

/// Simple stateful counter widget for state preservation tests
class _CounterPage extends StatefulWidget {
  const _CounterPage({super.key});

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$_count')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
