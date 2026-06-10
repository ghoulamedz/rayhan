import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/custom_page_transition.dart';
import 'package:rayhan_erp/constants/colors.dart';

abstract final class AppTheme {
  // ── Color Palette (DESIGN.md) ──────────────────────────────────
  // Surface
  static const Color kSurface = AppColors.surface;
  static const Color kSurfaceDim = AppColors.surfaceDim;
  static const Color kSurfaceContainer = AppColors.surfaceContainer;
  static const Color kOnSurface = AppColors.onSurface;
  static const Color kOnSurfaceVariant = AppColors.onSurfaceVariant;

  // Primary
  static const Color kPrimary = AppColors.primary;
  static const Color kOnPrimary = AppColors.onPrimary;
  static const Color kPrimaryContainer = AppColors.primaryContainer;
  static const Color kOnPrimaryContainer = AppColors.onPrimaryContainer;

  // Secondary (growth green)
  static const Color kSecondary = AppColors.secondary;
  static const Color kOnSecondary = AppColors.onSecondary;
  static const Color kSecondaryContainer = AppColors.secondaryContainer;

  // Tertiary
  static const Color kTertiary = AppColors.tertiary;
  static const Color kOnTertiary = AppColors.onTertiary;

  // Brand
  static const Color kDeepIndustrialBlue = AppColors.deepIndustrialBlue;
  static const Color kGrowthGreen = AppColors.growthGreen;
  static const Color kEcoPaleGreen = AppColors.ecoPaleGreen;
  static const Color kSteelGray = AppColors.steelGray;
  static const Color kSafetyOrange = AppColors.safetyOrange;

  // Text
  static const Color kTextPrimary = AppColors.onSurface;
  static const Color kTextSecondary = AppColors.onSurfaceVariant;
  static const Color kTextHint = AppColors.outline;

  // Input / borders
  static const Color kInputFill = Color(0xFFEAF2F5);
  static const Color kBorderLight = Color(0xFFC8D4DC);

  // Status colors
  static const Color kSuccessGreen = AppColors.successGreen;
  static const Color kSuccessGreenLight = AppColors.successGreenLight;
  static const Color kWarningAmber = AppColors.warningAmber;
  static const Color kWarningAmberLight = AppColors.warningAmberLight;
  static const Color kErrorRed = AppColors.errorRed;
  static const Color kErrorRedLight = AppColors.errorRedLight;

  // Neutrals
  static const Color kWhite = AppColors.white;
  static const Color kBlack = AppColors.black;
  static const Color kDividerColor = AppColors.outlineVariant;

  // ── Glassmorphism helpers (glossy) ─────────────────────────────
  static BoxDecoration glassCard({
    Color? tint,
    double blur = 24,
    double radius = 16,
    double opacity = 0.55,
  }) {
    return BoxDecoration(
      color: (tint ?? kSurface).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: kWhite.withValues(alpha: 0.45),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: kBlack.withValues(alpha: 0.08),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: kBlack.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: kWhite.withValues(alpha: 0.3),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static Widget withGlass({
    required Widget child,
    Color? tint,
    double blur = 24,
    double radius = 16,
    double opacity = 0.55,
    EdgeInsets? margin,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          margin: margin,
          decoration: glassCard(
            tint: tint,
            radius: radius,
            opacity: opacity,
            blur: blur,
          ),
          child: Stack(
            children: [
              child,
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          kWhite.withValues(alpha: 0.15),
                          kWhite.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Spacing ────────────────────────────────────────────────────

  // ── Spacing ────────────────────────────────────────────────────
  static const double sp4 = 4.0;
  static const double sp8 = 8.0;
  static const double sp10 = 10.0;
  static const double sp12 = 12.0;
  static const double sp14 = 14.0;
  static const double sp16 = 16.0;
  static const double sp20 = 20.0;
  static const double sp24 = 24.0;
  static const double sp32 = 32.0;
  static const double sp40 = 40.0;

  // ── Tinted surfaces ────────────────────────────────────────────
  static Color get kSectionBg => Color.lerp(kSurface, kPrimary, 0.05)!;

  // ── Gradients (DESIGN.md : blue/green industrial) ──────────────
  static const kPrimaryGradient = LinearGradient(
    colors: [kDeepIndustrialBlue, kPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const kAccentGradient = LinearGradient(
    colors: [kGrowthGreen, kSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const kCtaGradient = LinearGradient(
    colors: [kSafetyOrange, kTertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const kWarmGradient = LinearGradient(
    colors: [kSurface, kEcoPaleGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ────────────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: kBlack.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: kBlack.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: kBlack.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: kBlack.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: kBlack.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  // ── Decorations ────────────────────────────────────────────────
  static BoxDecoration get cardDecoration => glassCard();
  static BoxDecoration get cardDecorationMd =>
      glassCard(blur: 28, opacity: 0.6);

  static BoxDecoration get inputDecoration => BoxDecoration(
        color: kInputFill,
        borderRadius: BorderRadius.circular(12),
      );

  // ── Button styles (DESIGN.md) ──────────────────────────────────
  // Primary: Deep Industrial Blue, 4px radius
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: kDeepIndustrialBlue,
        foregroundColor: kWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
      );

  // Secondary (Eco): Growth Green — for sustainability/eco actions
  static ButtonStyle get ecoButton => ElevatedButton.styleFrom(
        backgroundColor: kGrowthGreen,
        foregroundColor: kWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
      );

  // Accent: Safety Orange — for CTA / alerts
  static ButtonStyle get ctaButton => ElevatedButton.styleFrom(
        backgroundColor: kSafetyOrange,
        foregroundColor: kWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
      );

  // ── Legacy button styles (backward compat) ─────────────────────
  static ButtonStyle get accentButton => ElevatedButton.styleFrom(
        backgroundColor: kGrowthGreen,
        foregroundColor: kTextPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      );

  // ── Glassmorphism background (DESIGN.md) ───────────────────────
  static Widget glassBackground(
      {required Widget child, LinearGradient? gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kSteelGray,
                kEcoPaleGreen.withValues(alpha: 0.3),
                kSteelGray,
              ],
            ),
      ),
      child: child,
    );
  }

  // ── Gradient header bar ────────────────────────────────────────
  static Widget gradientBar({required Widget child, LinearGradient? gradient}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kWhite,
                kDeepIndustrialBlue.withValues(alpha: 0.04),
              ],
            ),
        boxShadow: shadowSm,
      ),
      child: child,
    );
  }

  // ── Typography (DESIGN.md) ─────────────────────────────────────
  // Display (Manrope 700, tight tracking)
  static TextStyle get displayLarge => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 64,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.02,
      );

  static TextStyle get displayMedium => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.01,
      );

  static TextStyle get displaySmall => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  // Headline (Manrope 600)
  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle get headlineMedium => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineSmall => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // Title (Manrope 600, slightly smaller)
  static TextStyle get titleLarge => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Body (Inter 400)
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // Label (IBM Plex Sans 600, caps)
  static TextStyle get labelCaps => const TextStyle(
        fontFamily: 'IBM Plex Sans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 1.2,
      );

  // Legacy label styles (Inter 500, backward compat)
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.4,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.3,
      );

  static TextStyle get bodyMediumItalic => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.5,
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  static TextStyle get labelCapsStyle => labelCaps;

  // ── ThemeData ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.light(
        primary: kPrimary,
        secondary: kSecondary,
        tertiary: kTertiary,
        surface: kSurface,
        error: kErrorRed,
        onPrimary: kOnPrimary,
        onSecondary: kOnSecondary,
        onSurface: kOnSurface,
        onError: kWhite,
      ),
      scaffoldBackgroundColor: kSurface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: kSurface.withValues(alpha: 0.85),
        foregroundColor: kTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: kTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: kWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kDeepIndustrialBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kErrorRed),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: kTextSecondary),
        hintStyle: TextStyle(color: kTextHint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButton,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kDeepIndustrialBlue,
        foregroundColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        selectedColor: kOnPrimaryContainer.withValues(alpha: 0.2),
        checkmarkColor: kDeepIndustrialBlue,
        labelStyle: TextStyle(fontSize: 12, color: kTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(color: kBorderLight, thickness: 1),
      drawerTheme: DrawerThemeData(
        backgroundColor: kSurface,
        shape: const RoundedRectangleBorder(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: MySlideFadePageTransitionsBuilder(),
        TargetPlatform.iOS: MySlideFadePageTransitionsBuilder(),
        TargetPlatform.windows: MySlideFadePageTransitionsBuilder(),
        TargetPlatform.macOS: MySlideFadePageTransitionsBuilder(),
        TargetPlatform.linux: MySlideFadePageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.dark(
        primary: kSafetyOrange,
        secondary: kGrowthGreen,
        tertiary: kDeepIndustrialBlue,
        surface: const Color(0xFF1A142E),
        error: kErrorRed,
        onPrimary: kWhite,
        onSecondary: kWhite,
        onSurface: kWhite,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D0A1A),
      textTheme: textTheme.apply(
        bodyColor: kWhite,
        displayColor: kWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A142E),
        foregroundColor: kWhite,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A142E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2340),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButton),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kSafetyOrange,
        foregroundColor: kWhite,
      ),
      dividerTheme:
          DividerThemeData(color: kWhite.withValues(alpha: 0.12), thickness: 1),
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: MySlideFadePageTransitionsBuilder(),
        TargetPlatform.iOS: MySlideFadePageTransitionsBuilder(),
        TargetPlatform.windows: MySlideFadePageTransitionsBuilder(),
        TargetPlatform.macOS: MySlideFadePageTransitionsBuilder(),
        TargetPlatform.linux: MySlideFadePageTransitionsBuilder(),
      }),
    );
  }
}
