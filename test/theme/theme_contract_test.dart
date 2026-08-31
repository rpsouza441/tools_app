import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/theme/theme.dart';

/// Hex literals copied from `01-UI-SPEC.md` Color / Radius and Shape.
/// These are the oracle — never `ColorScheme.fromSeed` output, never
/// `isNotNull` as proof of a role.
const _lightCanvas = 0xFFF7F9F7;
const _lightSurface = 0xFFFFFFFF;
const _lightSurfaceContainer = 0xFFEDF3EE;
const _lightOnSurface = 0xFF171D18;
const _lightOnSurfaceVariant = 0xFF47534A;
const _lightOutline = 0xFF707A72;
const _lightPrimary = 0xFF006D2C;
const _lightOnPrimary = 0xFFFFFFFF;
const _lightPrimaryContainer = 0xFFB8F3C5;
const _lightOnPrimaryContainer = 0xFF002109;
const _lightError = 0xFFBA1A1A;
const _lightOnError = 0xFFFFFFFF;

const _darkCanvas = 0xFF0F1511;
const _darkSurface = 0xFF151C17;
const _darkSurfaceContainer = 0xFF1D2820;
const _darkOnSurface = 0xFFE1E9E2;
const _darkOnSurfaceVariant = 0xFFBBC5BC;
const _darkOutline = 0xFF859087;
const _darkPrimary = 0xFF50FA7B;
const _darkOnPrimary = 0xFF003913;
const _darkPrimaryContainer = 0xFF005321;
const _darkOnPrimaryContainer = 0xFFA7F5B7;
const _darkError = 0xFFFFB4AB;
const _darkOnError = 0xFF690005;

void _expectArgb(Color actual, int expectedArgb, String role) {
  expect(
    actual.toARGB32(),
    expectedArgb,
    reason:
        '$role: expected 0x${expectedArgb.toRadixString(16).toUpperCase().padLeft(8, '0')}, '
        'got 0x${actual.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0')}',
  );
}

RoundedRectangleBorder? _resolvedButtonShape(ButtonStyle? style) {
  final shape = style?.shape?.resolve(const <WidgetState>{});
  return shape is RoundedRectangleBorder ? shape : null;
}

void main() {
  group('lightTheme ColorScheme roles (UI-SPEC literals)', () {
    final theme = lightTheme;
    final cs = theme.colorScheme;

    test('canvas / scaffoldBackgroundColor is #F7F9F7', () {
      _expectArgb(theme.scaffoldBackgroundColor, _lightCanvas, 'canvas');
    });

    test('surface is #FFFFFF', () {
      _expectArgb(cs.surface, _lightSurface, 'surface');
    });

    test('surfaceContainer is #EDF3EE', () {
      _expectArgb(
        cs.surfaceContainer,
        _lightSurfaceContainer,
        'surfaceContainer',
      );
    });

    test('onSurface is #171D18', () {
      _expectArgb(cs.onSurface, _lightOnSurface, 'onSurface');
    });

    test('onSurfaceVariant is #47534A', () {
      _expectArgb(
        cs.onSurfaceVariant,
        _lightOnSurfaceVariant,
        'onSurfaceVariant',
      );
    });

    test('outline is #707A72', () {
      _expectArgb(cs.outline, _lightOutline, 'outline');
    });

    test('primary is #006D2C', () {
      _expectArgb(cs.primary, _lightPrimary, 'primary');
    });

    test('onPrimary is #FFFFFF', () {
      _expectArgb(cs.onPrimary, _lightOnPrimary, 'onPrimary');
    });

    test('primaryContainer is #B8F3C5', () {
      _expectArgb(
        cs.primaryContainer,
        _lightPrimaryContainer,
        'primaryContainer',
      );
    });

    test('onPrimaryContainer is #002109', () {
      _expectArgb(
        cs.onPrimaryContainer,
        _lightOnPrimaryContainer,
        'onPrimaryContainer',
      );
    });

    test('error is #BA1A1A', () {
      _expectArgb(cs.error, _lightError, 'error');
    });

    test('onError is #FFFFFF', () {
      _expectArgb(cs.onError, _lightOnError, 'onError');
    });
  });

  group('darkTheme ColorScheme roles (UI-SPEC literals)', () {
    final theme = darkTheme;
    final cs = theme.colorScheme;

    test('canvas / scaffoldBackgroundColor is #0F1511', () {
      _expectArgb(theme.scaffoldBackgroundColor, _darkCanvas, 'canvas');
    });

    test('surface is #151C17', () {
      _expectArgb(cs.surface, _darkSurface, 'surface');
    });

    test('surfaceContainer is #1D2820', () {
      _expectArgb(
        cs.surfaceContainer,
        _darkSurfaceContainer,
        'surfaceContainer',
      );
    });

    test('onSurface is #E1E9E2', () {
      _expectArgb(cs.onSurface, _darkOnSurface, 'onSurface');
    });

    test('onSurfaceVariant is #BBC5BC', () {
      _expectArgb(
        cs.onSurfaceVariant,
        _darkOnSurfaceVariant,
        'onSurfaceVariant',
      );
    });

    test('outline is #859087', () {
      _expectArgb(cs.outline, _darkOutline, 'outline');
    });

    test('primary is #50FA7B', () {
      _expectArgb(cs.primary, _darkPrimary, 'primary');
    });

    test('onPrimary is #003913', () {
      _expectArgb(cs.onPrimary, _darkOnPrimary, 'onPrimary');
    });

    test('primaryContainer is #005321', () {
      _expectArgb(
        cs.primaryContainer,
        _darkPrimaryContainer,
        'primaryContainer',
      );
    });

    test('onPrimaryContainer is #A7F5B7', () {
      _expectArgb(
        cs.onPrimaryContainer,
        _darkOnPrimaryContainer,
        'onPrimaryContainer',
      );
    });

    test('error is #FFB4AB', () {
      _expectArgb(cs.error, _darkError, 'error');
    });

    test('onError is #690005', () {
      _expectArgb(cs.onError, _darkOnError, 'onError');
    });
  });

  group('shapes and elevations (both themes)', () {
    for (final entry in <(String, ThemeData, int)>[
      ('light', lightTheme, _lightOutline),
      ('dark', darkTheme, _darkOutline),
    ]) {
      final name = entry.$1;
      final theme = entry.$2;
      final outlineArgb = entry.$3;

      test('$name Card elevation 0, radius 12, outline 1 px', () {
        expect(theme.cardTheme.elevation, 0);
        final shape = theme.cardTheme.shape;
        expect(shape, isA<RoundedRectangleBorder>());
        final border = shape! as RoundedRectangleBorder;
        expect(border.borderRadius, BorderRadius.circular(12));
        expect(border.side.width, 1);
        _expectArgb(border.side.color, outlineArgb, '$name Card outline');
      });

      test('$name AppBar elevation 0 and scrolledUnderElevation 0', () {
        expect(theme.appBarTheme.elevation, 0);
        expect(theme.appBarTheme.scrolledUnderElevation, 0);
      });

      test('$name NavigationBar and NavigationRail elevation 0', () {
        expect(theme.navigationBarTheme.elevation, 0);
        expect(theme.navigationRailTheme.elevation, 0);
      });

      test('$name Elevated/Text/OutlinedButton radius 8', () {
        expect(
          _resolvedButtonShape(theme.elevatedButtonTheme.style)?.borderRadius,
          BorderRadius.circular(8),
        );
        expect(
          _resolvedButtonShape(theme.textButtonTheme.style)?.borderRadius,
          BorderRadius.circular(8),
        );
        expect(
          _resolvedButtonShape(theme.outlinedButtonTheme.style)?.borderRadius,
          BorderRadius.circular(8),
        );
      });

      test('$name Chip radius 4', () {
        final shape = theme.chipTheme.shape;
        expect(shape, isA<RoundedRectangleBorder>());
        expect(
          (shape! as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(4),
        );
      });
    }
  });
}
