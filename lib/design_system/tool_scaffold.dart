import 'package:flutter/material.dart';
import 'package:tools_app/design_system/app_breakpoints.dart';
import 'package:tools_app/design_system/app_tokens.dart';

/// Vertical scrollable container for tool screens.
///
/// Provides:
/// - SafeArea for system insets
/// - SingleChildScrollView for overflow
/// - Center + ConstrainedBox for max content width
/// - Progressive padding by width class (16/24/32)
/// - Semantic header title in titleLarge style
class ToolScaffold extends StatelessWidget {
  const ToolScaffold({
    super.key,
    required this.title,
    this.summary,
    required this.children,
  });

  /// Screen title rendered as a semantic heading.
  final String title;

  /// Optional short description below the title.
  final String? summary;

  /// Content widgets rendered in a vertical column below the header.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final widthClass = AppBreakpoints.classify(constraints.maxWidth);
          final padding = switch (widthClass) {
            AppWidthClass.compact => tokens.spacing16,
            AppWidthClass.medium => tokens.spacing24,
            AppWidthClass.expanded => tokens.spacing32,
          };

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: textTheme.titleLarge),
                      ),
                      if (summary != null) ...[
                        SizedBox(height: tokens.spacing8),
                        Text(
                          summary!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      SizedBox(height: tokens.spacing24),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
