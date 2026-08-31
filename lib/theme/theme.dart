import 'package:flutter/material.dart';
import 'package:tools_app/design_system/app_tokens.dart';

// ---------------------------------------------------------------------------
// D-05: Green accent only — neutral high-contrast surfaces/text in light/dark.
// D-06: Default Material sans-serif; no google_fonts runtime fetch.
// D-07: Hierarchy by size/weight/spacing/surface; color never sole indicator.
// D-08: Light/dark share semantic color roles.
// D-16: Touch targets >= 48x48.
// ---------------------------------------------------------------------------

/// Green seed used for accent roles (primary, selected, focus indicators).
const _greenSeed = Color(0xFF4CAF50);

// ──────────────────────────────────────────────────────────────────────────────
// Shared text theme — default sans-serif, neutral colors applied by ColorScheme.
// ──────────────────────────────────────────────────────────────────────────────

const _textTheme = TextTheme(
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
  titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  headlineSmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
);

// ──────────────────────────────────────────────────────────────────────────────
// Shared component themes — D-16 tap targets, consistent radii.
// ──────────────────────────────────────────────────────────────────────────────

final _buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
);

const _buttonMinSize = Size(48, 48);

/// Component themes that depend on the active [ColorScheme].
ThemeData _applyComponentThemes(ThemeData base) {
  final cs = base.colorScheme;
  return base.copyWith(
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: cs.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: cs.onPrimaryContainer);
        }
        return IconThemeData(color: cs.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          );
        }
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: cs.onSurfaceVariant,
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      indicatorColor: cs.primaryContainer,
      selectedIconTheme: IconThemeData(color: cs.onPrimaryContainer),
      unselectedIconTheme: IconThemeData(color: cs.onSurfaceVariant),
      selectedLabelTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: cs.onSurfaceVariant,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.error),
      ),
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        minimumSize: _buttonMinSize,
        shape: _buttonShape,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        minimumSize: _buttonMinSize,
        shape: _buttonShape,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        minimumSize: _buttonMinSize,
        shape: _buttonShape,
        side: BorderSide(color: cs.outline),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: _buttonMinSize),
    ),
  );
}

// ──────────────────────────────────────────────────────────────────────────────
// Light theme
// ──────────────────────────────────────────────────────────────────────────────

final ThemeData lightTheme = _applyComponentThemes(
  ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _greenSeed,
      brightness: Brightness.light,
    ),
    textTheme: _textTheme,
    scaffoldBackgroundColor: const Color(0xFFFBFDF8),
    appBarTheme: const AppBarTheme(elevation: 0, scrolledUnderElevation: 1),
    extensions: const <ThemeExtension>[AppTokens()],
  ),
);

// ──────────────────────────────────────────────────────────────────────────────
// Dark theme
// ──────────────────────────────────────────────────────────────────────────────

final ThemeData darkTheme = _applyComponentThemes(
  ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _greenSeed,
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme,
    scaffoldBackgroundColor: const Color(0xFF1A1C19),
    appBarTheme: const AppBarTheme(elevation: 0, scrolledUnderElevation: 1),
    extensions: const <ThemeExtension>[AppTokens()],
  ),
);
