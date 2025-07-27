import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tema escuro (Matrix)
final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color(0xFF00FF41),
    primary: const Color(0xFF00FF41),
    secondary: const Color(0xFF4CAF50),
    surface: const Color(0xFF1C1C1C),
    background: const Color(0xFF2B2B2B),
    error: const Color(0xFFCF6679),
    onSurface: const Color(0xFF00FF41),
  ),
  canvasColor: const Color(0xFF2B2B2B),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2B2B2B),
    foregroundColor: Color(0xFF00FF41),
    elevation: 0,
  ),
  textTheme: GoogleFonts.latoTextTheme().copyWith(
    bodyLarge: const TextStyle(color: Color(0xFF00FF41), fontSize: 16),
    bodyMedium: const TextStyle(color: Color(0xFF00FF41), fontSize: 14),
    headlineLarge:
        const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00FF41)),
    labelLarge: const TextStyle(
        fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF00FF41)),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: const Color(0xFF4CAF50),
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF00FF41)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF00FF41), width: 2.0),
    ),
    labelStyle: TextStyle(color: Color(0xFF00FF41)),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF2B2B2B), // Fundo do menu
    textStyle: const TextStyle(color: Color(0xFF00FF41)), // Texto do menu
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    // Estilo do texto para todos os itens do menu
    textStyle: const TextStyle(color: Color(0xFF00FF41), fontSize: 16),
    inputDecorationTheme: const InputDecorationTheme(
      // Garante que o campo em si (quando o menu está fechado) também use a cor correta
      labelStyle: TextStyle(color: Color(0xFF00FF41)),
      // Estilo do texto dentro do campo
      hintStyle: TextStyle(color: Color(0xFF00FF41)),
    ),
    menuStyle: MenuStyle(
      // Cor de fundo do menu aberto
      backgroundColor: MaterialStateProperty.all(const Color(0xFF1C1C1C)),
      // Cor de fundo quando um item está focado ou selecionado
      surfaceTintColor: MaterialStateProperty.all(const Color(0xFF1C1C1C)),
    ),
  ),
  // Garante que a cor de destaque geral siga o tema
  highlightColor: const Color(0xFF4CAF50).withOpacity(0.3),
  splashColor: const Color(0xFF00FF41).withOpacity(0.4),
  scaffoldBackgroundColor: const Color(0xFF1C1C1C),
);

// Tema claro
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color(0xFF4CAF50),
    primary: const Color(0xFF4CAF50),
    secondary: const Color(0xFF00FF41),
    surface: const Color(0xFFE0E0E0),
    background: const Color(0xFFF5F5F5),
    error: const Color(0xFFB00020),
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF5F5F5),
    foregroundColor: Color(0xFF4CAF50),
    elevation: 0,
  ),
  textTheme: GoogleFonts.latoTextTheme().copyWith(
    bodyLarge: const TextStyle(color: Colors.black87, fontSize: 16),
    bodyMedium: const TextStyle(color: Colors.black87, fontSize: 14),
    headlineLarge:
        const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    labelLarge: const TextStyle(
        fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: const Color(0xFF4CAF50),
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF4CAF50)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF4CAF50)),
    ),
    labelStyle: TextStyle(color: Color(0xFF4CAF50)),
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
);
