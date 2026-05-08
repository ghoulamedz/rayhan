import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Horizontal stock level progress bar with label and percentage.
///
/// ```dart
/// StockLevelIndicator(
///   label: 'Polymères Plastiques',
///   level: 0.82,
/// )
/// ```
class StockLevelIndicator extends StatelessWidget {
  const StockLevelIndicator({
    super.key,
    required this.label,
    required this.level,
    this.trailing,
    this.showPercentage = true,
    this.height = 6,
  });

  /// 0.0 to 1.0
  final double level;
  final String label;

  /// Optional trailing widget (e.g. a reorder button).
  final Widget? trailing;
  final bool showPercentage;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _barColor(level);
    final pct = (level * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: level < 0.2 ? AppTheme.error : AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppTheme.sp8),
            if (showPercentage)
              Text(
                '$pct%',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            if (trailing != null) ...[
              const SizedBox(width: AppTheme.sp8),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: AppTheme.sp8),
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: level.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: AppTheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _barColor(double l) {
    if (l < 0.2) return AppTheme.error;
    if (l < 0.5) return AppTheme.warning;
    return AppTheme.primary;
  }
}

/// Vertical silo-style indicator (used in the Inventaire screen for HDPE/LDPE).
class SiloIndicator extends StatelessWidget {
  const SiloIndicator({
    super.key,
    required this.label,
    required this.subtitle,
    required this.level,
    required this.poids,
    required this.unite,
    this.onTap,
    this.actionLabel,
    this.actionColor,
  });

  final String label;
  final String subtitle;

  /// 0.0 – 1.0
  final double level;
  final double poids;
  final String unite;
  final VoidCallback? onTap;
  final String? actionLabel;
  final Color? actionColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _siloColor(level);
    final pct = (level * 100).round();
    final isLow = level < 0.2;

    return Container(
      padding: const EdgeInsets.all(AppTheme.sp16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isLow ? AppTheme.error.withOpacity(0.4) : AppTheme.border,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          // Silo bar
          _VerticalBar(level: level, color: color, pct: pct),
          const SizedBox(width: AppTheme.sp16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppTheme.sp12),
                _Row(
                    label: 'Poids', value: '$poids', unit: unite, theme: theme),
                const SizedBox(height: AppTheme.sp4),
                _Row(label: 'Actuel', value: '$unite', unit: '', theme: theme),
                const SizedBox(height: AppTheme.sp12),
                _StatusChip(label: isLow ? 'BAS' : 'OPTIMAL', color: color),
                const SizedBox(height: AppTheme.sp12),
                if (onTap != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: actionColor ?? AppTheme.primary,
                        side:
                            BorderSide(color: actionColor ?? AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      child: Text(actionLabel ?? 'Détails'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _siloColor(double l) {
    if (l < 0.2) return AppTheme.error;
    if (l < 0.5) return AppTheme.warning;
    return AppTheme.primary;
  }
}

class _VerticalBar extends StatelessWidget {
  const _VerticalBar({
    required this.level,
    required this.color,
    required this.pct,
  });

  final double level;
  final Color color;
  final int pct;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$pct%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 48,
          height: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(color: AppTheme.surfaceVariant),
                FractionallySizedBox(
                  heightFactor: level.clamp(0.0, 1.0),
                  child: Container(color: color.withOpacity(0.85)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.unit,
    required this.theme,
  });

  final String label;
  final String value;
  final String unit;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const Spacer(),
        Text(
          unit.isEmpty ? value : '$value $unit',
          style:
              theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
