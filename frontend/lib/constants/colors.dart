import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── DESIGN.md Material 3 palette ─────────────────────────────
  static const surface = Color(0xFFF9F9FD);
  static const surfaceDim = Color(0xFFD9DADD);
  static const surfaceContainerLow = Color(0xFFF3F3F7);
  static const surfaceContainer = Color(0xFFEDEEF1);
  static const surfaceContainerHigh = Color(0xFFE7E8EC);
  static const onSurface = Color(0xFF1A1C1E);
  static const onSurfaceVariant = Color(0xFF42474E);
  static const outline = Color(0xFF72787F);
  static const outlineVariant = Color(0xFFC2C7CF);

  static const primary = Color(0xFF002944);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF004066);
  static const onPrimaryContainer = Color(0xFF7EACD8);

  static const secondary = Color(0xFF0B6D29);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF9AF49E);
  static const onSecondaryContainer = Color(0xFF13722C);

  static const tertiary = Color(0xFF411E00);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF603003);
  static const onTertiaryContainer = Color(0xFFDE9863);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFF9F9FD);
  static const onBackground = Color(0xFF1A1C1E);

  // ── Brand colors ────────────────────────────────────────────
  static const deepIndustrialBlue = Color(0xFF002B45);
  static const growthGreen = Color(0xFF2E7D32);
  static const ecoPaleGreen = Color(0xFFE8F5E9);
  static const steelGray = Color(0xFFF5F7F9);
  static const safetyOrange = Color(0xFFFF8C00);

  // ── Neutrals ────────────────────────────────────────────────
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // ── Status ──────────────────────────────────────────────────
  static const successGreen = Color(0xFF4CAF50);
  static const successGreenLight = Color(0xFFC8E6C9);
  static const warningAmber = Color(0xFFFFA726);
  static const warningAmberLight = Color(0xFFFFE0B2);
  static const errorRed = Color(0xFFDE3E3E);
  static const errorRedLight = Color(0xFFF5C8C8);
}
