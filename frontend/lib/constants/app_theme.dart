import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/custom_page_transition.dart';

abstract final class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────
  // Primary: deep burgundy
  static const Color kPrimaryBurgundy = Color(0xFF810B38);
  static const Color kPrimaryBurgundyLight = Color(0xFFA84B6E);
  static const Color kPrimaryBurgundyDark = Color(0xFF541A1A);

  // Background / surface
  static const Color kSecondaryCream = Color(0xFFF1E2D1);
  static const Color kSecondaryTan = Color(0xFFDCC3AA);
  static const Color kBackgroundWarm = Color(0xFFF8F0E8);
  static const Color kSurfaceGlass = Color(0xCCF1E2D1);
  static const Color kSurfaceWhite = Color(0xFFFFFFFF);

  // Text
  static const Color kTextPrimary = Color(0xFF541A1A);
  static const Color kTextSecondary = Color(0xFF8B6F5E);
  static const Color kTextHint = Color(0xFFB8A08E);

  // Input / borders
  static const Color kInputFill = Color(0xFFF5EDE6);
  static const Color kBorderLight = Color(0xFFE8D9CD);

  // Status colors
  static const Color kSuccessGreen = Color(0xFF4CAF50);
  static const Color kSuccessGreenLight = Color(0xFFC8E6C9);
  static const Color kWarningAmber = Color(0xFFFFA726);
  static const Color kWarningAmberLight = Color(0xFFFFE0B2);
  static const Color kErrorRed = Color(0xFFE53935);
  static const Color kErrorRedLight = Color(0xFFFFCDD2);

  // Neutrals
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kBlack = Color(0xFF000000);
  static const Color kDividerColor = Color(0xFFE8D9CD);

  // ── Glassmorphism helpers ──────────────────────────────────────
  static BoxDecoration glassCard({
    Color? tint,
    double blur = 20,
    double radius = 16,
    double opacity = 0.75,
  }) {
    return BoxDecoration(
      color: (tint ?? kSecondaryCream).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: kWhite.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: kBlack.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: kBlack.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static Widget withGlass({
    required Widget child,
    Color? tint,
    double blur = 20,
    double radius = 16,
    double opacity = 0.75,
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
          child: child,
        ),
      ),
    );
  }

  // ── Deprecated aliases (backwards compat) ──────────────────────
  @Deprecated('Use kPrimaryBurgundy instead') static const Color kPrimaryTeal = kPrimaryBurgundy;
  @Deprecated('Use kPrimaryBurgundyLight instead') static const Color kPrimaryTealLight = kPrimaryBurgundyLight;
  @Deprecated('Use kPrimaryBurgundyDark instead') static const Color kPrimaryTealDark = kPrimaryBurgundyDark;
  @Deprecated('Use kSecondaryTan instead') static const Color kSecondaryAmber = kSecondaryTan;
  @Deprecated('Use kWarningAmberLight instead') static const Color kSecondaryAmberLight = kWarningAmberLight;
  @Deprecated('Use kPrimaryBurgundyLight instead') static const Color kCtaOrange = kPrimaryBurgundyLight;
  @Deprecated('Use kWarningAmberLight instead') static const Color kCtaOrangeLight = kWarningAmberLight;
  @Deprecated('Use kBackgroundWarm instead') static const Color kBackgroundOffWhite = kBackgroundWarm;
  @Deprecated('Use kPrimaryBurgundyLight instead') static const Color blueLightTinted = kPrimaryBurgundyLight;
  @Deprecated('Use kPrimaryBurgundyLight instead') static const Color blueLightest = kPrimaryBurgundyLight;
  @Deprecated('Use kTextPrimary instead') static const Color blueStrongHighlight = kTextPrimary;
  @Deprecated('Use kPrimaryBurgundyLight instead') static const Color greenLight = kPrimaryBurgundyLight;
  @Deprecated('Use kSurfaceWhite instead') static const Color whiteSurface = kSurfaceWhite;
  @Deprecated('Use kSuccessGreenLight instead') static const Color whiteSurface2 = kSuccessGreenLight;
  @Deprecated('Use kPrimaryBurgundyLight instead') static const Color whiteTintedorGreyAddAlpha02 = kPrimaryBurgundyLight;
  @Deprecated('Use kPrimaryBurgundyDark instead') static const Color greenStrong = kPrimaryBurgundyDark;
  @Deprecated('Use kErrorRed instead') static const Color red = kErrorRed;
  @Deprecated('Use kWarningAmber instead') static const Color yellow = kWarningAmber;
  @Deprecated('Use kSuccessGreen instead') static const Color greenBright = kSuccessGreen;
  @Deprecated('Use kPrimaryBurgundy instead') static const Color greenMatte = kPrimaryBurgundy;
  @Deprecated('Use kTextSecondary instead') static const Color grey = kTextSecondary;
  @Deprecated('Use kTextHint instead') static const Color greyLight = kTextHint;
  @Deprecated('Use kPrimaryBurgundy instead') static const Color blueLight = kPrimaryBurgundy;

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

  // ── Gradients ──────────────────────────────────────────────────
  static const kPrimaryGradient = LinearGradient(
    colors: [kPrimaryBurgundy, kPrimaryBurgundyDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const kAccentGradient = LinearGradient(
    colors: [kSecondaryTan, kPrimaryBurgundyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const kCtaGradient = LinearGradient(
    colors: [kPrimaryBurgundyLight, kPrimaryBurgundy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const kWarmGradient = LinearGradient(
    colors: [kSecondaryCream, kBackgroundWarm],
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
  static BoxDecoration get cardDecorationMd => glassCard(blur: 24, opacity: 0.8);

  static BoxDecoration get inputDecoration => BoxDecoration(
        color: kInputFill,
        borderRadius: BorderRadius.circular(12),
      );

  // ── Button styles ──────────────────────────────────────────────
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: kPrimaryBurgundy,
        foregroundColor: kWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      );

  static ButtonStyle get accentButton => ElevatedButton.styleFrom(
        backgroundColor: kSecondaryTan,
        foregroundColor: kTextPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      );

  static ButtonStyle get ctaButton => ElevatedButton.styleFrom(
        backgroundColor: kPrimaryBurgundyLight,
        foregroundColor: kWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      );

  // ── Glassmorphism background ───────────────────────────────────
  static Widget glassBackground({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kBackgroundWarm,
            kSecondaryCream,
            kSecondaryTan.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: child,
    );
  }

  // ── Typography ─────────────────────────────────────────────────
  static TextStyle get displayLarge => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle get displaySmall => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.35,
      );

  static TextStyle get headlineMedium => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  static TextStyle get headlineSmall => const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleLarge => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.45,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

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
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.6,
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

  // ── ThemeData ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.light(
        primary: kPrimaryBurgundy,
        secondary: kSecondaryTan,
        tertiary: kPrimaryBurgundyLight,
        surface: kBackgroundWarm,
        error: kErrorRed,
        onPrimary: kWhite,
        onSecondary: kTextPrimary,
        onSurface: kTextPrimary,
        onError: kWhite,
      ),
      scaffoldBackgroundColor: kBackgroundWarm,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: kSurfaceGlass,
        foregroundColor: kTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: kTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: kSurfaceGlass,
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
          borderSide: BorderSide(color: kPrimaryBurgundy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kErrorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: kTextSecondary),
        hintStyle: TextStyle(color: kTextHint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButton,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kPrimaryBurgundy,
        foregroundColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        selectedColor: kPrimaryBurgundyLight.withValues(alpha: 0.2),
        checkmarkColor: kPrimaryBurgundy,
        labelStyle: TextStyle(fontSize: 12, color: kTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(color: kBorderLight, thickness: 1),
      drawerTheme: DrawerThemeData(
        backgroundColor: kSecondaryCream,
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
        primary: kPrimaryBurgundyLight,
        secondary: kSecondaryTan,
        tertiary: kPrimaryBurgundy,
        surface: const Color(0xFF2D1B1B),
        error: kErrorRed,
        onPrimary: kWhite,
        onSecondary: kWhite,
        onSurface: kSecondaryCream,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A0F0F),
      textTheme: textTheme.apply(
        bodyColor: kSecondaryCream,
        displayColor: kSecondaryCream,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF2D1B1B),
        foregroundColor: kSecondaryCream,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D1B1B),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3D2525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButton),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kPrimaryBurgundyLight,
        foregroundColor: kWhite,
      ),
      dividerTheme: DividerThemeData(color: kWhite.withValues(alpha: 0.12), thickness: 1),
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
