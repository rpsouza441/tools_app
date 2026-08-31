import 'package:flutter/material.dart';
import 'package:tools_app/app/app_destinations.dart';
import 'package:tools_app/app/app_shell.dart';
import 'package:tools_app/theme/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ferramentas de TI',
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: AppShell(destinations: appDestinations),
    );
  }
}
