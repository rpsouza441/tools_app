import 'package:flutter/material.dart';
import 'package:tools_app/app/app_destinations.dart';
import 'package:tools_app/design_system/app_breakpoints.dart';

/// Adaptive navigation shell that switches between NavigationBar (compact),
/// collapsed NavigationRail (medium), and extended NavigationRail (expanded).
///
/// Uses [IndexedStack] to preserve page state across navigation and resizes.
///
/// When [destinations] has 5+ items, only the 3 with lowest [compactPriority]
/// are pinned; the rest are collected under a "Ferramentas" overflow item.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.destinations});

  final List<AppDestination> destinations;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  /// Whether overflow mode is active (5+ destinations).
  bool get _useOverflow => widget.destinations.length > 4;

  /// The pinned destinations (top 3 by compactPriority) when in overflow mode.
  List<AppDestination> get _pinnedDestinations {
    if (!_useOverflow) return widget.destinations;
    final sorted = List<AppDestination>.from(widget.destinations)
      ..sort((a, b) => a.compactPriority.compareTo(b.compactPriority));
    return sorted.take(3).toList();
  }

  /// The overflow destinations (not pinned) when in overflow mode.
  List<AppDestination> get _overflowDestinations {
    if (!_useOverflow) return [];
    final pinned = _pinnedDestinations;
    return widget.destinations
        .where((d) => !pinned.contains(d))
        .toList();
  }

  /// Maps the selected index to the actual destination index in widget.destinations.
  int get _actualDestinationIndex {
    if (!_useOverflow) return _selectedIndex;
    if (_selectedIndex < _pinnedDestinations.length) {
      // Find the index in widget.destinations for this pinned destination
      final pinned = _pinnedDestinations[_selectedIndex];
      return widget.destinations.indexOf(pinned);
    }
    // Ferramentas is selected — show the last selected overflow item
    return _overflowSelectedActualIndex;
  }

  /// Tracks which overflow item is currently selected (actual index).
  int _overflowSelectedActualIndex = -1;

  late List<Widget> _pages;

  /// GlobalKey for IndexedStack to preserve state across layout changes.
  final GlobalKey _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _buildPages();
    if (_useOverflow) {
      // Default overflow selection to first overflow item
      _overflowSelectedActualIndex =
          widget.destinations.indexOf(_overflowDestinations.first);
    }
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinations != widget.destinations) {
      _buildPages();
    }
  }

  void _buildPages() {
    _pages = widget.destinations
        .map((d) => d.pageBuilder(context))
        .toList();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      if (_useOverflow && index == _pinnedDestinations.length) {
        // Ferramentas tapped — show overflow menu
        _selectedIndex = index;
        _showOverflowMenu();
      } else {
        _selectedIndex = index;
      }
    });
  }

  void _showOverflowMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        // Group by category
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
                return entry.value.map((d) => ListTile(
                      leading: Icon(d.icon),
                      title: Text(d.label),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        setState(() {
                          _overflowSelectedActualIndex =
                              widget.destinations.indexOf(d);
                          // Keep Ferramentas selected
                          _selectedIndex = _pinnedDestinations.length;
                        });
                      },
                    ));
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
        final pageIndex = _useOverflow ? _actualDestinationIndex : _selectedIndex;

        final body = IndexedStack(
          key: _stackKey,
          index: pageIndex,
          children: _pages,
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

    if (_useOverflow) {
      for (final d in _pinnedDestinations) {
        destinations.add(NavigationDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.selectedIcon),
          label: d.label,
        ));
      }
      destinations.add(const NavigationDestination(
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build),
        label: 'Ferramentas',
      ));
    } else {
      for (final d in widget.destinations) {
        destinations.add(NavigationDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.selectedIcon),
          label: d.label,
        ));
      }
    }

    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      destinations: destinations,
    );
  }

  NavigationRail _buildNavigationRail({required bool extended}) {
    final railDestinations = <NavigationRailDestination>[];

    if (_useOverflow) {
      for (final d in _pinnedDestinations) {
        railDestinations.add(NavigationRailDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.selectedIcon),
          label: Text(d.label),
        ));
      }
      railDestinations.add(const NavigationRailDestination(
        icon: Icon(Icons.build_outlined),
        selectedIcon: Icon(Icons.build),
        label: Text('Ferramentas'),
      ));
    } else {
      for (final d in widget.destinations) {
        railDestinations.add(NavigationRailDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.selectedIcon),
          label: Text(d.label),
        ));
      }
    }

    return NavigationRail(
      extended: extended,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      destinations: railDestinations,
    );
  }
}
