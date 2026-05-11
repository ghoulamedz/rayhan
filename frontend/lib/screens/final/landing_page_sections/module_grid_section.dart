import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/responsive_layout.dart';

class ModuleGridSection extends StatelessWidget {
  const ModuleGridSection({super.key});

  static const _modules = [
    ModuleData(
      icon: Icons.point_of_sale,
      title: 'Gestion des Ventes',
      features: [
        'Devis multi-devises',
        'Suivi des expéditions',
        'Portails clients B2B',
      ],
    ),
    ModuleData(
      icon: Icons.factory,
      title: 'Suivi de Production',
      features: [
        'Ordonnancement MES',
        'Maintenance préventive',
        'Gestion des moules',
      ],
    ),
    ModuleData(
      icon: Icons.warehouse,
      title: 'Gestion des Stocks',
      features: [
        'Inventaire tournant',
        'Emplacement dynamique',
        'Gestion des silo/vides',
      ],
    ),
    ModuleData(
      icon: Icons.shopping_cart,
      title: 'Gestion des Achats',
      features: [
        'SRM Fournisseurs',
        'Contrôle qualité réception',
        'Forecast d\'appro',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.blueLightTinted,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
        child: Column(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth >= Breakpoints.md) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SectionHeader(
                        title: 'Une Architecture Modulaire Intégrée',
                        subtitle:
                            'Chaque module de RayhanERP communique nativement pour éliminer les silos de données.',
                        alignment: TextAlign.left,
                      ),
                    ),
                    Spacer(),
                  ],
                );
              }
              return const SectionHeader(
                title: 'Une Architecture Modulaire Intégrée',
                subtitle:
                    'Chaque module de RayhanERP communique nativement pour éliminer les silos de données.',
                alignment: TextAlign.left,
              );
            }),
            const SizedBox(height: 48),
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth >= Breakpoints.lg
                  ? 4
                  : constraints.maxWidth >= Breakpoints.md
                      ? 2
                      : 1;
              final itemW = (constraints.maxWidth - (cols - 1) * 16) / cols;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _modules
                    .map((m) =>
                        SizedBox(width: itemW, child: _ModuleCard(data: m)))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  const _ModuleCard({required this.data});
  final ModuleData data;

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _hovered ? Colors.black : AppTheme.whiteSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              widget.data.icon,
              size: 36,
              color: _hovered ? AppTheme.greenLight : cs.primary,
            ),
            const SizedBox(height: 24),
            Text(
              widget.data.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _hovered ? Colors.white : cs.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            ...widget.data.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $f',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 13,
                        color: (_hovered ? Colors.white : cs.onSurfaceVariant)
                            .withValues(alpha: 0.8),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
