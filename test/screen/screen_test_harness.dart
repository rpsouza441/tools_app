import 'package:flutter/material.dart';
import 'package:tools_app/design_system/copy_value_action.dart';
import 'package:tools_app/theme/theme.dart';

/// Wraps an isolated screen in [MaterialApp] with [lightTheme] so AppTokens resolve.
Widget wrapScreen(Widget child) {
  return MaterialApp(
    theme: lightTheme,
    home: Scaffold(body: child),
  );
}

/// In-memory [CopyValueWriter] for tests. Never writes the OS clipboard.
class FakeCopyWriter implements CopyValueWriter {
  String? lastValue;
  int callCount = 0;
  bool shouldThrow = false;

  @override
  Future<void> write(String value) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('Clipboard failure');
    }
    lastValue = value;
  }
}
