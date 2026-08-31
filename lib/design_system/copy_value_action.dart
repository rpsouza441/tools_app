import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Abstract clipboard interface for testing.
///
/// Inject a fake implementation in tests to verify copy behavior
/// without relying on the system clipboard.
abstract class CopyValueWriter {
  /// Writes [value] to the clipboard.
  Future<void> write(String value);
}

/// Default implementation using [Clipboard.setData].
class ClipboardCopyWriter implements CopyValueWriter {
  const ClipboardCopyWriter();

  @override
  Future<void> write(String value) {
    return Clipboard.setData(ClipboardData(text: value));
  }
}

/// 48px icon button that copies a value and shows a confirmation SnackBar.
///
/// - Tooltip: 'Copiar {label}'
/// - On success: closes only this action's prior SnackBar, shows '{Label} copiado' for 2s
/// - On failure: shows fallback message advising manual copy
/// - After [CopyValueWriter.write], touches the tree only if [BuildContext.mounted]
/// - [writer] defaults to [ClipboardCopyWriter] if not provided
class CopyValueAction extends StatefulWidget {
  const CopyValueAction({
    super.key,
    required this.label,
    required this.value,
    this.writer,
  });

  /// Descriptive label for the value being copied (used in tooltip and SnackBar).
  final String label;

  /// The exact value to copy to clipboard.
  final String value;

  /// Injectable clipboard writer. Defaults to [ClipboardCopyWriter].
  final CopyValueWriter? writer;

  @override
  State<CopyValueAction> createState() => _CopyValueActionState();
}

class _CopyValueActionState extends State<CopyValueAction> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _copySnackBar;

  String get _capitalizedLabel => widget.label.isEmpty
      ? widget.label
      : '${widget.label[0].toUpperCase()}${widget.label.substring(1)}';

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.copy, semanticLabel: 'Copiar ${widget.label}'),
      tooltip: 'Copiar ${widget.label}',
      onPressed: _copy,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }

  Future<void> _copy() async {
    // Capture the Element before await. State.context throws after unmount;
    // Element.mounted is the safe post-await guard.
    final context = this.context;
    final effectiveWriter = widget.writer ?? const ClipboardCopyWriter();

    try {
      await effectiveWriter.write(widget.value);
      if (!context.mounted) return;
      _showOwnedSnackBar(
        context,
        SnackBar(
          content: Text('$_capitalizedLabel copiado'),
          duration: const Duration(seconds: 2),
        ),
      );
    } on Exception {
      if (!context.mounted) return;
      _showOwnedSnackBar(
        context,
        const SnackBar(
          content: Text(
            'Não foi possível copiar. Selecione o valor e copie manualmente.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showOwnedSnackBar(BuildContext context, SnackBar snackBar) {
    _copySnackBar?.close();
    _copySnackBar = ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
