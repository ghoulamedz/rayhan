import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rayhan_erp/models/mock/mock_data.dart';
import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/theme/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/stat_card.dart';
import 'package:rayhan_erp/widgets/custom/stock_level_indicator.dart';
import 'package:rayhan_erp/widgets/custom/system_status_chip.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          const Row(
            children: [
              Expanded(
                child: ScreenHeader(
                  title: 'Tableau de Bord',
                  subtitle:
                      'Surveillance de la ligne de production en temps réel',
                ),
              ),
              SystemStatusChip(),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // KPI Cards
          _KpiRow(),
          const SizedBox(height: AppTheme.sp24),

          // Charts + Stock panel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _ProductionChart()),
              const SizedBox(width: AppTheme.sp20),
              Expanded(flex: 2, child: _StockPanel()),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // Recent movements + Line status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _RecentMovements()),
              const SizedBox(width: AppTheme.sp20),
              Expanded(flex: 2, child: _LineStatusCard()),
            ],
          ),
        ],
      ),
    );
  }
}

// System status chip

// KPI row

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cards = <_KpiData>[
          _KpiData(
            title: 'Production en cours',
            value: '1,284',
            subtitle: 'Unités / Heure',
            trend: '+12%',
            trendPositive: true,
            icon: Icons.speed_rounded,
            iconColor: AppTheme.primary,
            iconBackground: AppTheme.primarySurface,
          ),
          _KpiData(
            title: 'Unités terminées',
            value: '8,492',
            subtitle: "Aujourd'hui",
            trend: 'Stable',
            trendPositive: true,
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppTheme.success,
            iconBackground: AppTheme.successSurface,
          ),
          _KpiData(
            title: 'Alertes de stock',
            value: '03',
            subtitle: 'Nécessite attention',
            trend: 'Action',
            trendPositive: false,
            icon: Icons.warning_amber_rounded,
            iconColor: AppTheme.error,
            iconBackground: AppTheme.errorSurface,
            alertLevel: 'error',
          ),
          _KpiData(
            title: 'Efficacité globale',
            value: 'OEE 92.4',
            subtitle: 'Performance machine',
            trend: '98%',
            trendPositive: true,
            icon: Icons.bolt_rounded,
            iconColor: Colors.white,
            iconBackground: AppTheme.sidebarBg,
          ),
        ];

        return Row(
          children: cards.map((d) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: d == cards.last ? 0 : AppTheme.sp16,
                ),
                child: StatCard(
                  title: d.title,
                  value: d.value,
                  subtitle: d.subtitle,
                  trend: d.trend,
                  trendPositive: d.trendPositive,
                  icon: d.icon,
                  iconColor: d.iconColor,
                  iconBackground: d.iconBackground,
                  alertLevel: d.alertLevel,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _KpiData {
  const _KpiData({
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.trendPositive = true,
    this.icon,
    this.iconColor,
    this.iconBackground,
    this.alertLevel,
  });

  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final bool trendPositive;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackground;
  final String? alertLevel;
}

// Production chart (simplified bar chart)

class _ProductionChart extends StatelessWidget {
  static const List<double> _data = [
    420,
    680,
    520,
    820,
    600,
    750,
    650,
    820,
    780,
    860,
    700,
    820,
    900,
    750,
    680,
  ];

  static const List<String> _labels = [
    '08:00',
    '10:00',
    '12:00',
    '14:00',
    '16:00',
    '18:00',
    '20:00',
    '22:00',
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Production journalière',
      subtitle: 'Rapport des cycles de moulage par injection',
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChartToggle(label: '24H', selected: true),
          SizedBox(width: 4),
          _ChartToggle(label: '7J', selected: false),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 200,
            child: _BarChart(data: _data),
          ),
          const SizedBox(height: AppTheme.sp12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _labels
                .map(
                  (l) => Text(
                    l,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    final max = data.reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (i) {
        final fraction = data[i] / max;
        final isHighlight = i == 5;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isHighlight)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.sidebarBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Text(
                      '11:00 – 820u',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 400 + i * 30),
                  height: 180 * fraction,
                  decoration: BoxDecoration(
                    color: isHighlight
                        ? AppTheme.primary
                        : AppTheme.primaryLight.withValues(alpha: 0.35),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ChartToggle extends StatelessWidget {
  const _ChartToggle({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// Stock panel

class _StockPanel extends StatelessWidget {
  static const List<_StockEntry> _entries = [
    _StockEntry(label: 'Polymères Plastiques', level: 0.82),
    _StockEntry(label: 'Additifs & Chimiques', level: 0.45),
    _StockEntry(label: 'Moules & Outillage', level: 0.12, isAlert: true),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'État des stocks',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.sp16),
              child: StockLevelIndicator(
                label: e.label,
                level: e.level,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.sp4),
          const _AiRecommendation(
            message:
                "Réapprovisionner le Lot de Moules A-12 d'ici 48h pour éviter un arrêt de production.",
          ),
        ],
      ),
    );
  }
}

class _StockEntry {
  const _StockEntry({
    required this.label,
    required this.level,
    this.isAlert = false,
  });

  final String label;
  final double level;
  final bool isAlert;
}

class _AiRecommendation extends StatelessWidget {
  const _AiRecommendation({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.sp12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'RECOMMANDATION IA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Recent movements

class _RecentMovements extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mouvements = MockData.mouvements;

    return AppCard(
      title: 'Mouvements de stock récents',
      trailing: TextButton(
        onPressed: () {},
        child: const Text(
          'VOIR TOUT',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: mouvements.map((m) => _MovementTile(mouvement: m)).toList(),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.mouvement});

  final MouvementStock mouvement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEntree = mouvement.isEntree;
    final sign = isEntree ? '+' : '-';
    final color = isEntree ? AppTheme.success : AppTheme.error;
    final qty = '${sign} ${mouvement.quantite.toStringAsFixed(0)} kg';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp20,
        vertical: AppTheme.sp14,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isEntree ? AppTheme.successSurface : AppTheme.errorSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              isEntree
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: AppTheme.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mouvement.designation,
                  style: theme.textTheme.labelLarge,
                ),
                Text(
                  'ENTRÉE • LOT ${mouvement.lot}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                qty,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                _timeAgo(mouvement.date),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return DateFormat('dd/MM').format(date);
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Line status card
// ──────────────────────────────────────────────────────────────────────────────

class _LineStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.sp20),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.precision_manufacturing_rounded,
                color: AppTheme.primaryLight,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Ligne Alpha-1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp16),
          Row(
            children: const [
              Expanded(
                child: _MetricTile(
                  label: 'TEMPÉRATURE',
                  value: '240°C',
                ),
              ),
              SizedBox(width: AppTheme.sp12),
              Expanded(
                child: _MetricTile(
                  label: 'PRESSION',
                  value: '1.2 kPA',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.sp8,
              horizontal: AppTheme.sp12,
            ),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.success.withOpacity(0.3)),
            ),
            child: const Center(
              child: Text(
                'OPÉRATIONNEL',
                style: TextStyle(
                  color: AppTheme.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.sp12),
      decoration: BoxDecoration(
        color: AppTheme.sidebarHover,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.sidebarText,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
