import 'package:flutter/material.dart';
import 'package:tools_app/design_system/app_tokens.dart';
import 'package:tools_app/design_system/copy_value_action.dart';

/// Container for form input fields.
///
/// Renders children in a vertical column with consistent spacing.
/// Does not own a [Form] or any controller.
class ToolInputSection extends StatelessWidget {
  const ToolInputSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(height: tokens.spacing16),
        ],
      ],
    );
  }
}

/// Primary + optional secondary/cancel actions with 48px touch targets.
///
/// Uses [OverflowBar] for automatic reflow at narrow widths.
class ToolActionGroup extends StatelessWidget {
  const ToolActionGroup({
    super.key,
    required this.primary,
    this.secondary,
    this.onCancel,
  });

  /// Primary action widget (typically an ElevatedButton).
  final Widget primary;

  /// Optional secondary action widget (typically an OutlinedButton).
  final Widget? secondary;

  /// Optional cancel callback. Shows a TextButton labeled 'Cancelar'.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return OverflowBar(
      spacing: tokens.spacing8,
      overflowSpacing: tokens.spacing8,
      children: [
        primary,
        ?secondary,
        if (onCancel != null)
          TextButton(onPressed: onCancel, child: const Text('Cancelar')),
      ],
    );
  }
}

/// Card for displaying tool results.
///
/// Uses theme tokens for padding and surface color.
class ToolResultCard extends StatelessWidget {
  const ToolResultCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Card(
      child: Padding(padding: EdgeInsets.all(tokens.spacing16), child: child),
    );
  }
}

/// Label (sans) + value (mono) metric display.
///
/// If [value] is null, displays 'Indisponível' — never shows zero.
class ToolMetric extends StatelessWidget {
  const ToolMetric({super.key, required this.label, this.value});

  /// Metric label in default sans-serif style.
  final String label;

  /// Metric value in monospace style. Null displays 'Indisponível'.
  final String? value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value ?? 'Indisponível',
          style: textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Courier New', 'Courier'],
          ),
        ),
      ],
    );
  }
}

/// Wraps multiple [ToolMetric] items into a responsive layout.
class ToolMetricLayout extends StatelessWidget {
  const ToolMetricLayout({super.key, required this.metrics});

  final List<ToolMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Wrap(
      spacing: tokens.spacing24,
      runSpacing: tokens.spacing8,
      children: metrics,
    );
  }
}

/// Row displaying a technical value with label, selectable mono text,
/// optional metadata, and an optional copy action.
class TechnicalValueRow extends StatelessWidget {
  const TechnicalValueRow({
    super.key,
    required this.label,
    required this.value,
    this.metadata,
    this.copyWriter,
  });

  /// Label in sans-serif style.
  final String label;

  /// Value displayed in monospace, selectable and wrapping.
  final String value;

  /// Optional metadata text below the value.
  final String? metadata;

  /// When provided, a [CopyValueAction] is shown and this writer is invoked
  /// with the displayed [value].
  final CopyValueWriter? copyWriter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontFamilyFallback: const ['Courier New', 'Courier'],
                ),
              ),
              if (metadata != null) ...[
                const SizedBox(height: 2),
                Text(
                  metadata!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (copyWriter != null)
          CopyValueAction(label: label, value: value, writer: copyWriter),
      ],
    );
  }
}
