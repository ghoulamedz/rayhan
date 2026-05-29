import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/dashboard_kpi.dart';
import '../../constants/app_theme.dart';

class KpiGrid extends StatelessWidget {
  final DashboardKpi kpi;

  const KpiGrid({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final count = 4;
        final gap = 12.0;
        final totalGap = gap * (count - 1);
        final cardWidth = (constraints.maxWidth - totalGap) / count;
        if (cardWidth < 140) {
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              SizedBox(
                width: (constraints.maxWidth - gap) / 2,
                child: _KpiCard(
                  title: "Chiffre d'affaires",
                  value: NumberFormat.currency(
                    locale: 'fr_TN',
                    symbol: 'TND',
                    decimalDigits: 1,
                  ).format(kpi.ventes.chiffreAffairesMois),
                  subtitle: '+${kpi.ventes.nbCommandesMois} commandes',
                  icon: Icons.trending_up_rounded,
                  accentColor: AppTheme.kPrimaryTeal,
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - gap) / 2,
                child: _KpiCard(
                  title: 'Commandes',
                  value: '${kpi.ventes.nbCommandesMois}',
                  subtitle: '${kpi.ventes.commandesEnCours} en cours',
                  icon: Icons.receipt_long_rounded,
                  accentColor: AppTheme.kCtaOrange,
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - gap) / 2,
                child: _KpiCard(
                  title: 'OF en cours',
                  value: '${kpi.production.ofEnCours}',
                  subtitle: '${kpi.production.ofPlanifies} planifiés',
                  icon: Icons.precision_manufacturing_rounded,
                  accentColor: AppTheme.kPrimaryNavy,
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - gap) / 2,
                child: _KpiCard(
                  title: 'Alertes stock',
                  value: '${kpi.stock.articlesEnAlerte}',
                  subtitle: kpi.stock.articlesEnAlerte == 0
                      ? 'Aucune alerte'
                      : 'Articles sous seuil',
                  icon: kpi.stock.articlesEnAlerte == 0
                      ? Icons.check_circle_outline_rounded
                      : Icons.warning_amber_rounded,
                  accentColor: kpi.stock.articlesEnAlerte > 0
                      ? AppTheme.kErrorRed
                      : AppTheme.kSuccessGreen,
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _KpiCard(
                title: "Chiffre d'affaires",
                value: NumberFormat.currency(
                  locale: 'fr_TN',
                  symbol: 'TND',
                  decimalDigits: 1,
                ).format(kpi.ventes.chiffreAffairesMois),
                subtitle: '+${kpi.ventes.nbCommandesMois} commandes',
                icon: Icons.trending_up_rounded,
                accentColor: AppTheme.kPrimaryTeal,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _KpiCard(
                title: 'Commandes',
                value: '${kpi.ventes.nbCommandesMois}',
                subtitle: '${kpi.ventes.commandesEnCours} en cours',
                icon: Icons.receipt_long_rounded,
                accentColor: AppTheme.kCtaOrange,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _KpiCard(
                title: 'OF en cours',
                value: '${kpi.production.ofEnCours}',
                subtitle: '${kpi.production.ofPlanifies} planifiés',
                icon: Icons.precision_manufacturing_rounded,
                accentColor: AppTheme.kPrimaryNavy,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _KpiCard(
                title: 'Alertes stock',
                value: '${kpi.stock.articlesEnAlerte}',
                subtitle: kpi.stock.articlesEnAlerte == 0
                    ? 'Aucune alerte'
                    : 'Articles sous seuil',
                icon: kpi.stock.articlesEnAlerte == 0
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                accentColor: kpi.stock.articlesEnAlerte > 0
                    ? AppTheme.kErrorRed
                    : AppTheme.kSuccessGreen,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;

  const _KpiCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.withGlass(
      radius: 16,
      blur: 16,
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 3,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: AppTheme.bodySmall
                          .copyWith(color: AppTheme.kTextSecondary)),
                ),
                Icon(icon,
                    color: accentColor.withValues(alpha: 0.7), size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: AppTheme.headlineSmall
                    .copyWith(color: AppTheme.kTextPrimary)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!,
                  style: AppTheme.bodySmall
                      .copyWith(color: AppTheme.kTextHint)),
            ],
          ],
        ),
      ),
    );
  }
}