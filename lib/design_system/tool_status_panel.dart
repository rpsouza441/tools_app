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
  const _StatusData({this.icon, required this.heading, required this.body});

  final IconData? icon;
  final String heading;
  final String body;
}

const _statusMap = <ToolStatusVariant, _StatusData>{
  ToolStatusVariant.empty: _StatusData(
    icon: Icons.inbox_outlined,
    heading: 'Nenhum resultado ainda',
    body: 'Preencha os campos e execute a ferramenta para ver os resultados.',
  ),
  ToolStatusVariant.loading: _StatusData(
    heading: 'Processando',
    body: 'Aguarde enquanto concluímos esta etapa.',
  ),
  ToolStatusVariant.success: _StatusData(
    icon: Icons.check_circle_outline,
    heading: 'Concluído',
    body: 'Resultado disponível abaixo.',
  ),
  ToolStatusVariant.failure: _StatusData(
    icon: Icons.error_outline,
    heading: 'Não foi possível concluir',
    body: 'Confira os dados e tente novamente.',
  ),
  ToolStatusVariant.offline: _StatusData(
    icon: Icons.wifi_off,
    heading: 'Sem conexão com a internet',
    body: 'Verifique a conexão e tente novamente.',
  ),
  ToolStatusVariant.permissionDenied: _StatusData(
    icon: Icons.lock_outline,
    heading: 'Permissão necessária',
    body: 'Ative a permissão nas configurações para continuar.',
  ),
  ToolStatusVariant.cancelled: _StatusData(
    icon: Icons.cancel_outlined,
    heading: 'Operação cancelada',
    body: 'Os resultados concluídos continuam disponíveis.',
  ),
};

/// Maps a [ToolStatusVariant] to icon + pt-BR heading + body.
///
/// - Color: icon/progress only — success uses primary; failure and
///   permissionDenied use error; empty, loading, offline, and cancelled use
///   onSurface (neutral). Headings always use onSurface (UI-SPEC: accent/error
///   on the icon, not the heading).
/// - Loading uses an indeterminate [CircularProgressIndicator] when
///   [ToolStatusPanel.progress] is null; otherwise the indicator is determinate.
/// - preservedChild: shown below status for loading, success, failure, and
///   cancelled.
/// - onRetry: shows retry button only when provided.
/// - onSettings: shows settings button only when provided.
class ToolStatusPanel extends StatelessWidget {
  const ToolStatusPanel({
    super.key,
    required this.variant,
    this.heading,
    this.body,
    this.progress,
    this.onRetry,
    this.onSettings,
    this.preservedChild,
  });

  /// Which status to display.
  final ToolStatusVariant variant;

  /// Tool-specific copy; omitted values use the variant's default message.
  final String? heading;
  final String? body;

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
      ToolStatusVariant.failure ||
      ToolStatusVariant.permissionDenied => cs.error,
      _ => cs.onSurface,
    };
  }

  bool get _showsPreservedChild =>
      variant == ToolStatusVariant.loading ||
      variant == ToolStatusVariant.success ||
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
        if (variant == ToolStatusVariant.loading)
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: progress,
              color: color,
              strokeWidth: 3,
            ),
          )
        else
          Icon(data.icon!, size: 48, color: color),
        SizedBox(height: tokens.spacing8),
        Text(
          heading ?? data.heading,
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.spacing4),
        Text(
          body ?? data.body,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
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
          // Full-width so cards/rows keep their layout while the panel itself
          // stays centered (consistent alignment across all states).
          SizedBox(width: double.infinity, child: preservedChild!),
        ],
      ],
    );
  }
}
