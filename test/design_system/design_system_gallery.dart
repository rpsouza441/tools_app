import 'package:flutter/material.dart';
import 'package:tools_app/design_system/tool_scaffold.dart';
import 'package:tools_app/design_system/tool_sections.dart';
import 'package:tools_app/design_system/tool_status_panel.dart';

/// Test-only gallery showcasing all design system primitives.
///
/// Renders every component in a controlled, static configuration for:
/// - Golden image regression tests
/// - Manual TalkBack/accessibility testing
/// - Visual design review
///
/// Uses static pt-BR text. No network, no real clipboard, no animation loops.
///
/// Must be placed inside a [Scaffold] or [Material] ancestor for [TextField]
/// to function correctly. When used inside [AppShell], the shell provides the
/// Scaffold. When used standalone, wrap in a [Scaffold].
class DesignSystemGallery extends StatelessWidget {
  const DesignSystemGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Galeria de Componentes',
      summary: 'Todos os primitivos do design system.',
      children: [
        // ToolInputSection with sample TextField
        ToolInputSection(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Endereço IP',
                hintText: '192.168.1.0',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Máscara',
                hintText: '255.255.255.0',
                errorText: 'Máscara inválida',
                errorStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ToolActionGroup with primary and secondary
        ToolActionGroup(
          primary: ElevatedButton(
            onPressed: () {},
            child: const Text('Calcular'),
          ),
          secondary: TextButton(onPressed: () {}, child: const Text('Limpar')),
        ),
        const SizedBox(height: 24),

        // ToolResultCard with sample result
        const ToolResultCard(child: Text('Resultado: 192.168.1.0/24')),
        const SizedBox(height: 24),

        // ToolMetricLayout with metrics
        const ToolMetricLayout(
          metrics: [
            ToolMetric(label: 'Hosts', value: '254'),
            ToolMetric(label: 'Status', value: null),
          ],
        ),
        const SizedBox(height: 24),

        // TechnicalValueRow
        const TechnicalValueRow(label: 'Hash', value: 'abc123def456'),
        const SizedBox(height: 32),

        // All 7 ToolStatusPanel variants
        const _StatusPanelShowcase(),
      ],
    );
  }
}

/// Displays all 7 ToolStatusPanel variants in sequence.
class _StatusPanelShowcase extends StatelessWidget {
  const _StatusPanelShowcase();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Status Panels', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final variant in ToolStatusVariant.values) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ToolStatusPanel(variant: variant),
          ),
          if (variant != ToolStatusVariant.values.last) const Divider(),
        ],
      ],
    );
  }
}
