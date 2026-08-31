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
/// - On success: hides current SnackBar, shows '{Label} copiado' for 2s
/// - On failure: shows fallback message advising manual copy
/// - [writer] defaults to [ClipboardCopyWriter] if not provided
class CopyValueAction extends StatelessWidget {
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

  String get _capitalizedLabel =>
      label.isEmpty ? label : '${label[0].toUpperCase()}${label.substring(1)}';

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy),
      tooltip: 'Copiar $label',
      onPressed: () => _copy(context),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final effectiveWriter = writer ?? const ClipboardCopyWriter();

    try {
      await effectiveWriter.write(value);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('$_capitalizedLabel copiado'),
          duration: const Duration(seconds: 2),
        ),
      );
    } on Exception {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível copiar. Selecione o valor e copie manualmente.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
