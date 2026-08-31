import 'package:flutter/material.dart';
import 'package:tools_app/theme/theme.dart';

// ignore: avoid_relative_lib_imports
import '../design_system/design_system_gallery.dart';

/// Manual test harness for design system TalkBack/accessibility testing.
///
/// Run on a real device with:
///   flutter run -t test/manual/design_system_app.dart
///
/// This file is NEVER imported by production code.
void main() {
  runApp(const _DesignSystemApp());
}

class _DesignSystemApp extends StatelessWidget {
  const _DesignSystemApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design System Gallery',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(body: DesignSystemGallery()),
    );
  }
}
