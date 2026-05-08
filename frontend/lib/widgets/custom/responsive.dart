import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Breakpoints
// ──────────────────────────────────────────────────────────────────────────────

/// Named breakpoints for the ERP layout.
///
/// | Name     | Min width | Sidebar         |
/// |----------|-----------|-----------------|
/// | compact  | 0         | hidden (drawer) |
/// | medium   | 768       | collapsed icons |
/// | expanded | 1 024     | full labels     |
abstract final class Breakpoints {
  static const double compact = 0;
  static const double medium = 768;
  static const double expanded = 1024;
}

/// Extension on [BuildContext] for breakpoint-aware queries.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  bool get isCompact => screenWidth < Breakpoints.medium;
  bool get isMedium =>
      screenWidth >= Breakpoints.medium && screenWidth < Breakpoints.expanded;
  bool get isExpanded => screenWidth >= Breakpoints.expanded;

  /// Returns one of three values based on current breakpoint.
  T responsive<T>({
    required T compact,
    required T medium,
    required T expanded,
  }) {
    if (isExpanded) return expanded;
    if (isMedium) return medium;
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

// ──────────────────────────────────────────────────────────────────────────────
// AdaptiveLayout
// ──────────────────────────────────────────────────────────────────────────────

/// Shows [expanded] (side-by-side) on wide screens, [stacked] on compact.
///
/// ```dart
/// AdaptiveLayout(
///   expanded: Row(children: [TablePanel(), DetailPanel()]),
///   stacked: Column(children: [TablePanel(), DetailPanel()]),
/// )
/// ```
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.expanded,
    required this.stacked,
    this.breakpoint = Breakpoints.expanded,
  });

  final Widget expanded;
  final Widget stacked;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth >= breakpoint ? expanded : stacked;
      },
    );
  }
}
