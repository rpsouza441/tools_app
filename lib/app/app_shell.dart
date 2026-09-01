import 'package:flutter/material.dart';
import 'package:tools_app/app/app_destinations.dart';
import 'package:tools_app/design_system/app_breakpoints.dart';

/// Exposes the currently-visible destination id to descendants so a preserved
/// [IndexedStack] page can cancel background work when it is no longer visible
/// (QUAL-04). The diagnostic screen listens to this to stop I/O when the user
/// navigates away without disposing the page.
class DiagnosticVisibilityScope extends InheritedWidget {
  const DiagnosticVisibilityScope({
    super.key,
    required this.selectedId,
    required super.child,
  });

  final String selectedId;

  static String? of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DiagnosticVisibilityScope>();
    return scope?.selectedId;
  }

  @override
  bool updateShouldNotify(DiagnosticVisibilityScope oldWidget) =>
      oldWidget.selectedId != selectedId;
}

/// Adaptive navigation shell that switches between NavigationBar (compact),
/// collapsed NavigationRail (medium), and extended NavigationRail (expanded).
///
/// Uses [IndexedStack] to preserve page state across navigation and resizes.
///
/// Overflow ("Ferramentas") applies only to the compact [NavigationBar] when
/// [destinations] has 5+ items. Medium and expanded rails list the full catalog.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.destinations});

  final List<AppDestination> destinations;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late String _selectedId;
  final Map<String, Widget> _pagesById = {};

  /// GlobalKey for IndexedStack to preserve state across layout changes.
  final GlobalKey _stackKey = GlobalKey();

  /// Whether compact NavigationBar overflow is active (5+ destinations).
  bool get _barUsesOverflow => widget.destinations.length > 4;

  /// The pinned destinations (top 3 by compactPriority) when in overflow mode.
  List<AppDestination> get _pinnedDestinations {
    if (!_barUsesOverflow) return widget.destinations;
    final sorted = List<AppDestination>.from(widget.destinations)
      ..sort((a, b) => a.compactPriority.compareTo(b.compactPriority));
    return sorted.take(3).toList();
  }

  /// The overflow destinations (not pinned) when in overflow mode.
  List<AppDestination> get _overflowDestinations {
    if (!_barUsesOverflow) return [];
    final pinnedIds = _pinnedDestinations.map((d) => d.id).toSet();
    return widget.destinations.where((d) => !pinnedIds.contains(d.id)).toList();
  }

  int get _catalogIndex {
    final index = widget.destinations.indexWhere((d) => d.id == _selectedId);
    if (index >= 0) return index;
    return 0;
  }

  int get _barSelectedIndex {
    if (!_barUsesOverflow) return _catalogIndex;
    final pinIndex = _pinnedDestinations.indexWhere((d) => d.id == _selectedId);
    if (pinIndex >= 0) return pinIndex;
    return _pinnedDestinations.length;
  }

  List<Widget> get _pages {
    return [
      for (final destination in widget.destinations)
        _pagesById[destination.id]!,
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedId = widget.destinations.first.id;
    _reconcilePages();
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameCatalog(oldWidget.destinations, widget.destinations)) {
      _reconcilePages();
      _normalizeSelection();
    }
  }

  bool _sameCatalog(List<AppDestination> previous, List<AppDestination> next) {
    if (identical(previous, next)) return true;
    if (previous.length != next.length) return false;
    for (var i = 0; i < previous.length; i++) {
      if (previous[i].id != next[i].id) return false;
    }
    return true;
  }

  void _reconcilePages() {
    final nextIds = widget.destinations.map((d) => d.id).toSet();
    _pagesById.removeWhere((id, _) => !nextIds.contains(id));
    for (final destination in widget.destinations) {
      _pagesById.putIfAbsent(
        destination.id,
        () => destination.pageBuilder(context),
      );
    }
  }

  void _normalizeSelection() {
    if (widget.destinations.isEmpty) return;
    if (!widget.destinations.any((d) => d.id == _selectedId)) {
      _selectedId = widget.destinations.first.id;
    }
  }

  void _onBarDestinationSelected(int index) {
    if (_barUsesOverflow && index == _pinnedDestinations.length) {
      _showOverflowMenu();
      return;
    }
    setState(() {
      _selectedId = _barUsesOverflow
          ? _pinnedDestinations[index].id
          : widget.destinations[index].id;
    });
  }

  void _onRailDestinationSelected(int index) {
    setState(() {
      _selectedId = widget.destinations[index].id;
    });
  }

  void _showOverflowMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final grouped = <AppDestinationCategory, List<AppDestination>>{};
        for (final d in _overflowDestinations) {
          grouped.putIfAbsent(d.category, () => []).add(d);
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Ferramentas',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              ...grouped.entries.expand((entry) {
                return entry.value.map(
                  (d) => ListTile(
                    leading: Icon(d.icon),
                    title: Text(d.label),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() {
                        _selectedId = d.id;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthClass = AppBreakpoints.classify(constraints.maxWidth);
        final pageIndex = _catalogIndex;

        final body = DiagnosticVisibilityScope(
          selectedId: _selectedId,
          child: IndexedStack(
            key: _stackKey,
            index: pageIndex,
            children: _pages,
          ),
        );

        switch (widthClass) {
          case AppWidthClass.compact:
            return Scaffold(
              body: body,
              bottomNavigationBar: _buildNavigationBar(),
            );
          case AppWidthClass.medium:
            return Scaffold(
              body: Row(
                children: [
                  _buildNavigationRail(extended: false),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: body),
                ],
              ),
            );
          case AppWidthClass.expanded:
            return Scaffold(
              body: Row(
                children: [
                  _buildNavigationRail(extended: true),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: body),
                ],
              ),
            );
        }
      },
    );
  }

  NavigationBar _buildNavigationBar() {
    final destinations = <NavigationDestination>[];

    if (_barUsesOverflow) {
      for (final d in _pinnedDestinations) {
        destinations.add(
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
            tooltip: d.semanticLabel,
          ),
        );
      }
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.build_outlined),
          selectedIcon: Icon(Icons.build),
          label: 'Ferramentas',
        ),
      );
    } else {
      for (final d in widget.destinations) {
        destinations.add(
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
            tooltip: d.semanticLabel,
          ),
        );
      }
    }

    return NavigationBar(
      selectedIndex: _barSelectedIndex,
      onDestinationSelected: _onBarDestinationSelected,
      destinations: destinations,
    );
  }

  Widget _railIcon(
    AppDestination destination, {
    required bool selected,
    required bool extended,
  }) {
    final icon = Icon(
      selected ? destination.selectedIcon : destination.icon,
      semanticLabel: extended ? null : destination.semanticLabel,
    );
    if (extended) return icon;
    return Tooltip(
      message: destination.semanticLabel,
      excludeFromSemantics: true,
      child: icon,
    );
  }

  NavigationRail _buildNavigationRail({required bool extended}) {
    final railDestinations = <NavigationRailDestination>[
      for (final destination in widget.destinations)
        NavigationRailDestination(
          icon: _railIcon(destination, selected: false, extended: extended),
          selectedIcon: _railIcon(
            destination,
            selected: true,
            extended: extended,
          ),
          label: Text(
            destination.label,
            semanticsLabel: extended ? destination.semanticLabel : null,
          ),
        ),
    ];

    return NavigationRail(
      extended: extended,
      scrollable: true,
      selectedIndex: _catalogIndex,
      onDestinationSelected: _onRailDestinationSelected,
      destinations: railDestinations,
    );
  }
}
