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

  /// Returns one of three values based on current breakpoint
  T responsive<T>({
    required T compact,
    required T medium,
    required T expanded,
  }) {
    if (isDesktop) return expanded;
    if (isTablet) return medium;
    return compact;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// ResponsiveGrid
// ──────────────────────────────────────────────────────────────────────────────

/// A grid that automatically adapts its column count to the available width.
///
/// ```dart
/// ResponsiveGrid(
///   compact: 1,
///   medium: 2,
///   expanded: 4,
///   spacing: 16,
///   children: cards,
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.compact = 1,
    this.medium = 2,
    this.expanded = 4,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  final List<Widget> children;
  final int compact;
  final int medium;
  final int expanded;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive<int>(
      compact: compact,
      medium: medium,
      expanded: expanded,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (cols - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map((c) => SizedBox(width: itemWidth, child: c))
              .toList(),
        );
      },
    );
  }
}
