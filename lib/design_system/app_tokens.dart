import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Design-system spacing, radii and max-width tokens.
///
/// Access via `Theme.of(context).extension<AppTokens>()`.
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    this.spacing4 = 4.0,
    this.spacing8 = 8.0,
    this.spacing16 = 16.0,
    this.spacing24 = 24.0,
    this.spacing32 = 32.0,
    this.spacing48 = 48.0,
    this.spacing64 = 64.0,
    this.radius4 = 4.0,
    this.radius8 = 8.0,
    this.radius12 = 12.0,
    this.formMaxWidth = 720.0,
    this.contentMaxWidth = 960.0,
  });

  /// 4 lp spacing unit.
  final double spacing4;

  /// 8 lp spacing unit.
  final double spacing8;

  /// 16 lp spacing unit.
  final double spacing16;

  /// 24 lp spacing unit.
  final double spacing24;

  /// 32 lp spacing unit.
  final double spacing32;

  /// 48 lp spacing unit.
  final double spacing48;

  /// 64 lp spacing unit.
  final double spacing64;

  /// 4 lp border radius.
  final double radius4;

  /// 8 lp border radius.
  final double radius8;

  /// 12 lp border radius.
  final double radius12;

  /// Maximum width for form content (D-15: 720px).
  final double formMaxWidth;

  /// Maximum width for general content areas.
  final double contentMaxWidth;

  @override
  AppTokens copyWith({
    double? spacing4,
    double? spacing8,
    double? spacing16,
    double? spacing24,
    double? spacing32,
    double? spacing48,
    double? spacing64,
    double? radius4,
    double? radius8,
    double? radius12,
    double? formMaxWidth,
    double? contentMaxWidth,
  }) {
    return AppTokens(
      spacing4: spacing4 ?? this.spacing4,
      spacing8: spacing8 ?? this.spacing8,
      spacing16: spacing16 ?? this.spacing16,
      spacing24: spacing24 ?? this.spacing24,
      spacing32: spacing32 ?? this.spacing32,
      spacing48: spacing48 ?? this.spacing48,
      spacing64: spacing64 ?? this.spacing64,
      radius4: radius4 ?? this.radius4,
      radius8: radius8 ?? this.radius8,
      radius12: radius12 ?? this.radius12,
      formMaxWidth: formMaxWidth ?? this.formMaxWidth,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
    );
  }

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      spacing4: lerpDouble(spacing4, other.spacing4, t)!,
      spacing8: lerpDouble(spacing8, other.spacing8, t)!,
      spacing16: lerpDouble(spacing16, other.spacing16, t)!,
      spacing24: lerpDouble(spacing24, other.spacing24, t)!,
      spacing32: lerpDouble(spacing32, other.spacing32, t)!,
      spacing48: lerpDouble(spacing48, other.spacing48, t)!,
      spacing64: lerpDouble(spacing64, other.spacing64, t)!,
      radius4: lerpDouble(radius4, other.radius4, t)!,
      radius8: lerpDouble(radius8, other.radius8, t)!,
      radius12: lerpDouble(radius12, other.radius12, t)!,
      formMaxWidth: lerpDouble(formMaxWidth, other.formMaxWidth, t)!,
      contentMaxWidth: lerpDouble(contentMaxWidth, other.contentMaxWidth, t)!,
    );
  }
}
