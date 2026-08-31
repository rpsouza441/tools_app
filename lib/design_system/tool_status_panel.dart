import 'package:flutter/material.dart';
import 'package:tools_app/design_system/app_tokens.dart';

/// Status variants for tool screens.
///
/// Each variant maps to a Material icon, pt-BR heading, and body text.
/// Color is supplementary — icon + heading + body are always present.
enum ToolStatusVariant {
  empty,
  loading,
  success,
  failure,
  offline,
  permissionDenied,
  cancelled,
}

/// Status metadata for rendering a [ToolStatusPanel].
class _StatusData {
  const _StatusData({
    required this.icon,
    required this.heading,
    required this.body,
  });

  final IconData icon;
  final String heading;
  final String body;
}

const _statusMap = <ToolStatusVariant, _StatusData>{
  ToolStatusVariant.empty: _StatusData(
    icon: Icons.inbox_outlined,
    heading: 'Pronto',
    body: 'Insira os dados e execute a ação.',
  ),
  ToolStatusVariant.loading: _StatusData(
    icon: Icons.hourglass_empty,
    heading: 'Processando...',
    body: 'Aguarde a conclusão.',
  ),
  ToolStatusVariant.success: _StatusData(
    icon: Icons.check_circle_outline,
    heading: 'Concluído',
    body: 'Resultado disponível abaixo.',
  ),
  ToolStatusVariant.failure: _StatusData(
    icon: Icons.error_outline,
    heading: 'Falha',
    body: 'Não foi possível concluir a operação.',
  ),
  ToolStatusVariant.offline: _StatusData(
    icon: Icons.cloud_off,
    heading: 'Sem conexão',
    body: 'Verifique sua conexão e tente novamente.',
  ),
  ToolStatusVariant.permissionDenied: _StatusData(
    icon: Icons.lock_outline,
    heading: 'Permissão necessária',
    body: 'Conceda a permissão nas configurações.',
  ),
  ToolStatusVariant.cancelled: _StatusData(
    icon: Icons.cancel_outlined,
    heading: 'Cancelado',
    body: 'A operação foi cancelada.',
  ),
};

/// Maps a [ToolStatusVariant] to icon + pt-BR heading + body.
///
/// - Color: success uses primary, failure/offline use error, others use onSurface.
/// - preservedChild: shown below status for loading, failure, and cancelled.
/// - onRetry: shows retry button only when provided.
/// - onSettings: shows settings button only when provided.
class ToolStatusPanel extends StatelessWidget {
  const ToolStatusPanel({
    super.key,
    required this.variant,
    this.progress,
    this.onRetry,
    this.onSettings,
    this.preservedChild,
  });

  /// Which status to display.
  final ToolStatusVariant variant;

  /// Optional progress value (0.0-1.0) for loading variant.
  final double? progress;

  /// Retry callback; shows a retry button when non-null.
  final VoidCallback? onRetry;

  /// Settings callback; shows a settings button when non-null.
  final VoidCallback? onSettings;

  /// Preserved content shown below the status for loading/failure/cancelled.
  final Widget? preservedChild;

  Color _iconColor(ColorScheme cs) {
    return switch (variant) {
      ToolStatusVariant.success => cs.primary,
      ToolStatusVariant.failure || ToolStatusVariant.offline => cs.error,
      _ => cs.onSurface,
    };
  }

  bool get _showsPreservedChild =>
      variant == ToolStatusVariant.loading ||
      variant == ToolStatusVariant.failure ||
      variant == ToolStatusVariant.cancelled;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final data = _statusMap[variant]!;
    final color = _iconColor(colorScheme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(data.icon, size: 48, color: color),
        SizedBox(height: tokens.spacing8),
        Text(
          data.heading,
          style: textTheme.titleLarge?.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.spacing4),
        Text(
          data.body,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (progress != null && variant == ToolStatusVariant.loading) ...[
          SizedBox(height: tokens.spacing16),
          LinearProgressIndicator(value: progress),
        ],
        if (onRetry != null) ...[
          SizedBox(height: tokens.spacing16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
        if (onSettings != null) ...[
          SizedBox(height: tokens.spacing16),
          TextButton.icon(
            onPressed: onSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Configurações'),
          ),
        ],
        if (_showsPreservedChild && preservedChild != null) ...[
          SizedBox(height: tokens.spacing24),
          preservedChild!,
        ],
      ],
    );
  }
}
