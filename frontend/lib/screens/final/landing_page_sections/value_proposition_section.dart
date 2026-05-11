import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/widgets/custom/responsive_layout.dart';

class ValuePropositionSection extends StatelessWidget {
  const ValuePropositionSection({super.key});

  static const _cards = [
    ValueCardData(
      icon: Icons.precision_manufacturing,
      title: 'Efficacité OEE en Temps Réel',
      description:
          'Surveillez chaque cycle de presse et automatisez le calcul du Taux de Rendement Synthétique instantanément.',
      accentColor: AppTheme.greenLight,
      hoverIconBg: AppTheme.greenLight,
    ),
    ValueCardData(
      icon: Icons.inventory_2,
      title: 'Gestion des Stocks Intelligente',
      description:
          'Optimisez vos niveaux de granulats et additifs grâce à des algorithmes de prédiction basés sur la production.',
      accentColor: AppTheme.greenLight,
      hoverIconBg: AppTheme.greenLight,
    ),
    ValueCardData(
      icon: Icons.verified,
      title: 'Traçabilité Totale des Lots',
      description:
          'Garantissez une conformité parfaite avec un suivi complet, de l\'origine du polymère jusqu\'à l\'expédition client.',
      accentColor: AppTheme.greenLight,
      hoverIconBg: AppTheme.greenLight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.blueLightTinted,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
        child: LayoutBuilder(builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= Breakpoints.lg
              ? 3
              : constraints.maxWidth >= Breakpoints.md
                  ? 2
                  : 1;

          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: _cards.map((card) {
              final itemWidth =
                  (constraints.maxWidth - (crossAxisCount - 1) * 24 - 0.01) /
                      crossAxisCount;
              return SizedBox(
                width: itemWidth,
                child: _ValueCard(data: card),
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}

class _ValueCard extends StatefulWidget {
  const _ValueCard({required this.data});
  final ValueCardData data;

  @override
  State<_ValueCard> createState() => _ValueCardState();
}

class _ValueCardState extends State<_ValueCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = widget.data;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.whiteSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            bottom: BorderSide(
                color: _hovered ? d.accentColor : Colors.black, width: 4),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _hovered ? d.hoverIconBg : AppTheme.whiteSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(d.icon, color: cs.primary, size: 28),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              d.title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              d.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                    height: 1.65,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
