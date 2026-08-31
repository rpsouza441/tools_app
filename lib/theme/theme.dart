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

const _tokens = AppTokens();

final _buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(_tokens.radius8),
);

const _buttonMinSize = Size(48, 48);

/// Component themes that depend on the active [ColorScheme].
ThemeData _applyComponentThemes(ThemeData base) {
  final cs = base.colorScheme;
  return base.copyWith(
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
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
      elevation: 0,
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
      elevation: 0,
      color: cs.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_tokens.radius12),
        side: BorderSide(color: cs.outline, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_tokens.radius8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_tokens.radius8),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_tokens.radius8),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_tokens.radius4),
      ),
      labelStyle: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_tokens.radius12),
      ),
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
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: _greenSeed,
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFFFFFFF),
          surfaceContainer: const Color(0xFFEDF3EE),
          onSurface: const Color(0xFF171D18),
          onSurfaceVariant: const Color(0xFF47534A),
          outline: const Color(0xFF707A72),
          primary: const Color(0xFF006D2C),
          onPrimary: const Color(0xFFFFFFFF),
          primaryContainer: const Color(0xFFB8F3C5),
          onPrimaryContainer: const Color(0xFF002109),
          error: const Color(0xFFBA1A1A),
          onError: const Color(0xFFFFFFFF),
        ),
    textTheme: _textTheme,
    scaffoldBackgroundColor: const Color(0xFFF7F9F7),
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
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: _greenSeed,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF151C17),
          surfaceContainer: const Color(0xFF1D2820),
          onSurface: const Color(0xFFE1E9E2),
          onSurfaceVariant: const Color(0xFFBBC5BC),
          outline: const Color(0xFF859087),
          primary: const Color(0xFF50FA7B),
          onPrimary: const Color(0xFF003913),
          primaryContainer: const Color(0xFF005321),
          onPrimaryContainer: const Color(0xFFA7F5B7),
          error: const Color(0xFFFFB4AB),
          onError: const Color(0xFF690005),
        ),
    textTheme: _textTheme,
    scaffoldBackgroundColor: const Color(0xFF0F1511),
    extensions: const <ThemeExtension>[AppTokens()],
  ),
);
