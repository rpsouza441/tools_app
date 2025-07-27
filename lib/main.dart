import 'package:flutter/material.dart';
import 'package:tolls_app/theme/theme.dart';
import 'package:tolls_app/screen/network_calculator_screen.dart';
import 'package:tolls_app/screen/data_converter_screen.dart'; // NOVA TELA

void main() {
  runApp(
    const App(),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NetworkCalculatorScreen(),
    const DataConverterScreen(), // NOVA TELA
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Matrix App',
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.network_check),
              label: 'Network Calc',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storage),
              label: 'Data Converter',
            ),
          ],
        ),
      ),
    );
  }
}
