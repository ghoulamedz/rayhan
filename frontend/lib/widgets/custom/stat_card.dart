import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A KPI metric card displaying a [title], large [value], optional [subtitle],
/// optional [trend] label, and an optional [icon] with [iconColor].
///
/// Usage:
/// ```dart
/// StatCard(
///   title: 'Production en cours',
///   value: '1,284',
///   subtitle: 'Unités / Heure',
///   trend: '+12%',
///   trendPositive: true,
///   icon: Icons.speed_rounded,
/// )
/// ```
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.trendPositive = true,
    this.icon,
    this.iconColor,
    this.iconBackground,
    this.alertLevel,
    this.onTap,
    this.width,
  });

  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final bool trendPositive;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackground;

  /// Optionally highlights the card border: 'warning', 'error', 'success'.
  final String? alertLevel;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _alertBorderColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(AppTheme.sp20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: borderColor ?? AppTheme.border,
            width: borderColor != null ? 1.5 : 1,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _TopRow(
              title: title,
              trend: trend,
              trendPositive: trendPositive,
              icon: icon,
              iconColor: iconColor,
              iconBackground: iconBackground,
              theme: theme,
            ),
            const SizedBox(height: AppTheme.sp12),
            Text(
              value,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _valueColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.sp4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color? get _alertBorderColor => switch (alertLevel) {
        'warning' => AppTheme.warning.withOpacity(0.5),
        'error' => AppTheme.error.withOpacity(0.5),
        'success' => AppTheme.success.withOpacity(0.5),
        _ => null,
      };

  Color get _valueColor => switch (alertLevel) {
        'error' => AppTheme.error,
        'warning' => AppTheme.warning,
        _ => AppTheme.textPrimary,
      };
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.title,
    required this.trend,
    required this.trendPositive,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.theme,
  });

  final String title;
  final String? trend;
  final bool trendPositive;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackground;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground ?? AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? AppTheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.sp8),
        ],
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trend != null) ...[
          const SizedBox(width: AppTheme.sp8),
          _TrendBadge(label: trend!, positive: trendPositive),
        ],
      ],
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.label, required this.positive});

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppTheme.success : AppTheme.error;
    final bg = positive ? AppTheme.successSurface : AppTheme.errorSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
