import 'package:flutter/material.dart';
import 'package:tools_app/screen/network_calculator_screen.dart';
import 'package:tools_app/screen/data_converter_screen.dart';
import 'package:tools_app/screen/hash_generator_screen.dart';

/// Categories for grouping destinations in overflow menus.
enum AppDestinationCategory { rede, armazenamento, hash }

/// A typed destination entry for the adaptive navigation shell.
class AppDestination {
  const AppDestination({
    required this.id,
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.selectedIcon,
    required this.category,
    required this.compactPriority,
    required this.pageBuilder,
  });

  /// Stable, unique identifier for this destination.
  final String id;

  /// Short pt-BR label shown in navigation items.
  final String label;

  /// Full name for tooltips and screen readers.
  final String semanticLabel;

  /// Icon shown when the destination is not selected.
  final IconData icon;

  /// Icon shown when the destination is selected.
  final IconData selectedIcon;

  /// Category for grouping in overflow menus.
  final AppDestinationCategory category;

  /// Priority for compact-mode display (lower = higher priority).
  /// When there are 5+ destinations, the 3 with lowest compactPriority
  /// are pinned; the rest go into the overflow "Ferramentas" item.
  final int compactPriority;

  /// Factory that builds the page widget for this destination.
  final WidgetBuilder pageBuilder;
}

/// The canonical list of app destinations in display order.
final List<AppDestination> appDestinations = List.unmodifiable([
  AppDestination(
    id: 'network_calculator',
    label: 'Rede',
    semanticLabel: 'Calculadora de Rede',
    icon: Icons.network_check_outlined,
    selectedIcon: Icons.network_check,
    category: AppDestinationCategory.rede,
    compactPriority: 1,
    pageBuilder: _buildNetworkCalculator,
  ),
  AppDestination(
    id: 'data_converter',
    label: 'Armazenamento',
    semanticLabel: 'Conversor de Dados',
    icon: Icons.storage_outlined,
    selectedIcon: Icons.storage,
    category: AppDestinationCategory.armazenamento,
    compactPriority: 2,
    pageBuilder: _buildDataConverter,
  ),
  AppDestination(
    id: 'hash_generator',
    label: 'Hash',
    semanticLabel: 'Gerador de Hash',
    icon: Icons.tag_outlined,
    selectedIcon: Icons.tag,
    category: AppDestinationCategory.hash,
    compactPriority: 3,
    pageBuilder: _buildHashGenerator,
  ),
]);

Widget _buildNetworkCalculator(BuildContext context) =>
    const NetworkCalculatorScreen();

Widget _buildDataConverter(BuildContext context) => const DataConverterScreen();

Widget _buildHashGenerator(BuildContext context) => const HashGeneratorScreen();
