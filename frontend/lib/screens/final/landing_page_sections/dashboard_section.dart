//UNUSED
import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/responsive_layout.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({super.key});

  static const _kpis = [
    KpiData(
      label: 'OEE Global',
      value: '84.2%',
      progressValue: 0.842,
    ),
    KpiData(
      label: 'Production (24h)',
      value: '12.5k',
      subtitle: '+4.2% vs hier',
      subtitleColor: AppTheme.greenMatte,
    ),
    KpiData(
      label: 'Rebuts',
      value: '0.8%',
      subtitle: 'Cible < 1.2%',
      subtitleColor: AppTheme.red,
    ),
    KpiData(
      label: 'Stock Matière',
      value: '42t',
      subtitle: 'PP / HDPE / ABS',
    ),
  ];

  static const _orders = [
    ProductionOrder(
      orderNumber: 'Ordre #OF-8829',
      machine: 'Machine A4 - Moule Carter Frontal',
      status: OrderStatus.inProgress,
      statusDetail: 'Fin prévue: 14:30',
      accentColor: AppTheme.greenBright,
    ),
    ProductionOrder(
      orderNumber: 'Ordre #OF-8830',
      machine: 'Machine B1 - Couvercle Batterie',
      status: OrderStatus.pending,
      statusDetail: 'Matière prête',
      accentColor: AppTheme.blueStrongHighlight,
    ),
    ProductionOrder(
      orderNumber: 'Ordre #OF-8831',
      machine: 'Machine A2 - Support Châssis',
      status: OrderStatus.pending,
      statusDetail: 'Moule en maintenance',
      accentColor: AppTheme.blueStrongHighlight,
    ),
  ];

  static const _alerts = [
    SystemAlert(
      icon: Icons.warning_amber_rounded,
      title: 'Température Cylindre A4',
      description: 'Déviation de +3°C détectée par l\'IA.',
    ),
    SystemAlert(
      icon: Icons.inventory,
      title: 'Réapprovisionnement ABS',
      description: 'Seuil critique atteint pour OF-8832.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.whiteSurface,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 48, vertical: 96),
        child: Column(
          children: [
            SectionHeader(
              title: 'Le Poste de Commande de votre Usine',
              subtitle:
                  'Une interface pensée pour les opérateurs et les managers. Données denses, clarté absolue.',
            ),
            SizedBox(height: 56),
            _DashboardFrame(kpis: _kpis, orders: _orders, alerts: _alerts),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard chrome frame ────────────────────────────────────────────────────

class _DashboardFrame extends StatelessWidget {
  const _DashboardFrame({
    required this.kpis,
    required this.orders,
    required this.alerts,
  });

  final List<KpiData> kpis;
  final List<ProductionOrder> orders;
  final List<SystemAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.whiteSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          // Window chrome bar
          Container(
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.blueStrongHighlight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const _TrafficLight(color: AppTheme.red),
                const SizedBox(width: 8),
                const _TrafficLight(color: AppTheme.yellow),
                const SizedBox(width: 8),
                const _TrafficLight(color: AppTheme.greenBright),
                const Spacer(),
                Text(
                  'system status: active',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: AppTheme.blueStrongHighlight,
                      ),
                ),
              ],
            ),
          ),

          // Dashboard body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // KPI row
                _KpiRow(kpis: kpis),
                const SizedBox(height: 20),
                // Detail panels
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= Breakpoints.md) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 2,
                              child: _ProductionPlanningPanel(orders: orders)),
                          const SizedBox(width: 20),
                          Expanded(child: _AlertsPanel(alerts: alerts)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _ProductionPlanningPanel(orders: orders),
                        const SizedBox(height: 20),
                        _AlertsPanel(alerts: alerts),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficLight extends StatelessWidget {
  const _TrafficLight({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── KPI row ───────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.kpis});
  final List<KpiData> kpis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= Breakpoints.md ? 4 : 2;
        final itemW = (constraints.maxWidth - (cols - 1) * 16) / cols;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: kpis
              .map((kpi) => SizedBox(width: itemW, child: _KpiCard(data: kpi)))
              .toList(),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final KpiData data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final valueColor =
        data.subtitleColor == AppTheme.red ? AppTheme.red : cs.onSurface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.whiteSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
          ),
          if (data.progressValue != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: data.progressValue,
                backgroundColor: AppTheme.greyLight,
                color: AppTheme.greenLight,
                minHeight: 4,
              ),
            ),
          ] else if (data.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              data.subtitle!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: data.subtitleColor ?? cs.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Production planning panel ─────────────────────────────────────────────────

class _ProductionPlanningPanel extends StatelessWidget {
  const _ProductionPlanningPanel({required this.orders});
  final List<ProductionOrder> orders;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.whiteSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greyLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Planning de Production',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
              ),
              Icon(Icons.filter_list, color: cs.outline, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          ...orders.map((order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductionOrderRow(order: order),
              )),
        ],
      ),
    );
  }
}

class _ProductionOrderRow extends StatelessWidget {
  const _ProductionOrderRow({required this.order});
  final ProductionOrder order;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = order.status == OrderStatus.inProgress;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.whiteSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: order.accentColor, width: 4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderNumber,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                order.machine,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isActive ? 'EN COURS' : 'EN ATTENTE',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color:
                          isActive ? AppTheme.greenStrong : cs.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                order.statusDetail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Alerts panel ─────────────────────────────────────────────────────────────

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel({required this.alerts});
  final List<SystemAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.blueStrongHighlight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertes Système',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 20),
          ...alerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _AlertItem(alert: alert),
              )),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({required this.alert});
  final SystemAlert alert;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(alert.icon, color: AppTheme.greenLight, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                alert.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
