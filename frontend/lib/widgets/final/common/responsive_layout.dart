import 'package:flutter/material.dart';

/// Breakpoints that mirror the HTML's md/lg Tailwind classes.
abstract final class Breakpoints {
  static const double md = 768;
  static const double lg = 1024;
}

/// Returns different widgets based on current screen width.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.md;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= Breakpoints.md && w < Breakpoints.lg;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.lg;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.lg) return desktop;
        if (constraints.maxWidth >= Breakpoints.md) return tablet ?? desktop;
        return mobile;
      },
    );
  }
}

/// Convenience extension on [BuildContext] for quick breakpoint checks.
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
}
