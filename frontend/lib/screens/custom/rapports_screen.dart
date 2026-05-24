//UNUSED
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rayhan_erp/models/mock/mock_data.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/stat_card.dart';
import 'package:rayhan_erp/widgets/custom/status_badge.dart';
import 'package:rayhan_erp/widgets/custom/stock_level_indicator.dart';

/// "Analyses & Rapports" — summary dashboard with trend charts and
/// cross-module KPI tables.
class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: _tabs.length, vsync: this);

  static const List<String> _tabs = [
    'Vue globale',
    'Production',
    'Ventes',
    'Stocks',
  ];

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Top section (header + tabs) ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppTheme.sp24, AppTheme.sp24, AppTheme.sp24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Analyses & Rapports',
                subtitle: 'Indicateurs consolidés sur l\'ensemble des modules.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today_outlined, size: 14),
                    label: const Text('Oct. 2023'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, size: 14),
                    label: const Text('Exporter PDF'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.sp20),
              // Tab bar
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppTheme.whiteTintedorGreyAddAlpha02)),
                ),
                child: TabBar(
                  controller: _tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Colors.black,
                  unselectedLabelColor: AppTheme.grey,
                  indicatorColor: Colors.black,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w400),
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ],
          ),
        ),

        // ── Tab content ──────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const [
              _VueGlobale(),
              _ProductionTab(),
              _VentesTab(),
              _StocksTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Vue Globale tab
// ──────────────────────────────────────────────────────────────────────────────

class _VueGlobale extends StatelessWidget {
  const _VueGlobale();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary KPIs ──────────────────────────────────────────────
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Chiffre d\'affaires',
                  value: '€142.6K',
                  subtitle: 'Mois en cours',
                  trend: '+12%',
                  trendPositive: true,
                  icon: Icons.trending_up_rounded,
                  iconColor: AppTheme.greenBright,
                  iconBackground: AppTheme.greenLight,
                ),
              ),
              SizedBox(width: AppTheme.sp16),
              Expanded(
                child: StatCard(
                  title: 'Unités produites',
                  value: '48,291',
                  subtitle: 'Ce mois',
                  trend: '+7%',
                  trendPositive: true,
                  icon: Icons.precision_manufacturing_rounded,
                  iconColor: Colors.black,
                  iconBackground: Colors.black,
                ),
              ),
              SizedBox(width: AppTheme.sp16),
              Expanded(
                child: StatCard(
                  title: 'OEE moyen',
                  value: '91.8%',
                  subtitle: 'Performance globale',
                  trend: '+2.3%',
                  trendPositive: true,
                  icon: Icons.speed_rounded,
                  iconColor: AppTheme.blueLight,
                  iconBackground: AppTheme.blueLightest,
                ),
              ),
              SizedBox(width: AppTheme.sp16),
              Expanded(
                child: StatCard(
                  title: 'Alertes totales',
                  value: '23',
                  subtitle: '5 critiques ce mois',
                  alertLevel: 'warning',
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppTheme.yellow,
                  iconBackground: AppTheme.yellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // ── Two-column: Trend chart + Module breakdown ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _TrendLineChart()),
              const SizedBox(width: AppTheme.sp20),
              Expanded(flex: 2, child: _ModuleBreakdown()),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // ── Recent activity log ───────────────────────────────────────
          _ActivityLog(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Trend line chart (custom painter)
// ──────────────────────────────────────────────────────────────────────────────

class _TrendLineChart extends StatelessWidget {
  static const _months = [
    'Avr',
    'Mai',
    'Jun',
    'Jul',
    'Aoû',
    'Sep',
    'Oct',
  ];
  static const _production = [38.0, 42.5, 40.1, 45.8, 44.2, 46.9, 48.3];
  static const _ventes = [30.5, 34.0, 36.2, 38.8, 37.4, 40.1, 42.6];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Tendance Mensuelle',
      subtitle: 'Production vs Ventes (milliers d\'unités)',
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendDot(color: Colors.black, label: 'Production'),
          SizedBox(width: 12),
          _LegendDot(color: AppTheme.greenBright, label: 'Ventes'),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: CustomPaint(
          painter: _LinePainter(
            seriesA: _production,
            seriesB: _ventes,
            colorA: Colors.black,
            colorB: AppTheme.greenBright,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _months
                    .map((m) => Text(
                          m,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.greyLight,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.seriesA,
    required this.seriesB,
    required this.colorA,
    required this.colorB,
  });

  final List<double> seriesA;
  final List<double> seriesB;
  final Color colorA;
  final Color colorB;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...seriesA, ...seriesB];
    final min = all.reduce((a, b) => a < b ? a : b) * 0.85;
    final max = all.reduce((a, b) => a > b ? a : b) * 1.05;
    final chartH = size.height - 24; // leave room for labels

    double xOf(int i) => (i / (seriesA.length - 1)) * size.width;
    double yOf(double v) => chartH - ((v - min) / (max - min)) * chartH;

    _drawSeries(canvas, seriesA, colorA, xOf, yOf, size);
    _drawSeries(canvas, seriesB, colorB, xOf, yOf, size);
  }

  void _drawSeries(
    Canvas canvas,
    List<double> series,
    Color color,
    double Function(int) xOf,
    double Function(double) yOf,
    Size size,
  ) {
    // Filled area
    final fillPath = Path();
    fillPath.moveTo(xOf(0), yOf(series[0]));
    for (var i = 1; i < series.length; i++) {
      final c1x = (xOf(i - 1) + xOf(i)) / 2;
      fillPath.cubicTo(
          c1x, yOf(series[i - 1]), c1x, yOf(series[i]), xOf(i), yOf(series[i]));
    }
    fillPath.lineTo(xOf(series.length - 1), size.height - 24);
    fillPath.lineTo(xOf(0), size.height - 24);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = color.withOpacity(0.08)
        ..style = PaintingStyle.fill,
    );

    // Line
    final linePath = Path();
    linePath.moveTo(xOf(0), yOf(series[0]));
    for (var i = 1; i < series.length; i++) {
      final c1x = (xOf(i - 1) + xOf(i)) / 2;
      linePath.cubicTo(
          c1x, yOf(series[i - 1]), c1x, yOf(series[i]), xOf(i), yOf(series[i]));
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Dots
    for (var i = 0; i < series.length; i++) {
      canvas.drawCircle(
        Offset(xOf(i), yOf(series[i])),
        3,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.seriesA != seriesA || old.seriesB != seriesB;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.grey)),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Module breakdown donut-style
// ──────────────────────────────────────────────────────────────────────────────

class _ModuleBreakdown extends StatelessWidget {
  static const List<_BreakdownRow> _rows = [
    _BreakdownRow(
        label: 'Ventes', value: 142600, pct: 0.46, color: AppTheme.greenBright),
    _BreakdownRow(
        label: 'Production', value: 98200, pct: 0.32, color: Colors.black),
    _BreakdownRow(
        label: 'Achats', value: 48200, pct: 0.16, color: AppTheme.blueLight),
    _BreakdownRow(
        label: 'Maintenance', value: 18000, pct: 0.06, color: AppTheme.yellow),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt =
        NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);

    return AppCard(
      title: 'Répartition par Module',
      subtitle: 'Valeur opérationnelle totale',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Visual bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: _rows
                    .map((r) => Expanded(
                          flex: (r.pct * 100).round(),
                          child: Container(color: r.color),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.sp20),
          // Row list
          ..._rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.sp12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration:
                          BoxDecoration(color: r.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppTheme.sp8),
                    Expanded(
                      child: Text(r.label, style: theme.textTheme.labelLarge),
                    ),
                    Text(
                      '${(r.pct * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: r.color,
                      ),
                    ),
                    const SizedBox(width: AppTheme.sp12),
                    SizedBox(
                      width: 80,
                      child: Text(
                        fmt.format(r.value),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _BreakdownRow {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.pct,
    required this.color,
  });
  final String label;
  final double value;
  final double pct;
  final Color color;
}

// ──────────────────────────────────────────────────────────────────────────────
// Activity log
// ──────────────────────────────────────────────────────────────────────────────

class _ActivityLog extends StatelessWidget {
  static const List<_ActivityEntry> _entries = [
    _ActivityEntry(
      time: 'Aujourd\'hui, 11:00',
      module: 'Production',
      color: Colors.black,
      event: 'Lot LOT-2023-442 atteint 75% — Phase 3 démarrée.',
    ),
    _ActivityEntry(
      time: 'Aujourd\'hui, 09:30',
      module: 'Maintenance',
      color: AppTheme.yellow,
      event: 'Alerte Robot-A4: surchauffe détectée. Refroidissement actif.',
    ),
    _ActivityEntry(
      time: 'Aujourd\'hui, 08:15',
      module: 'Ventes',
      color: AppTheme.greenBright,
      event: 'VTE-2023-089 validée — Industries Mécaniques SARL — 12 450 €.',
    ),
    _ActivityEntry(
      time: 'Hier, 17:45',
      module: 'Stocks',
      color: AppTheme.red,
      event: 'LDPE tombe sous le seuil minimal. Réapprovisionnement requis.',
    ),
    _ActivityEntry(
      time: 'Hier, 15:00',
      module: 'Achats',
      color: AppTheme.blueLight,
      event: 'ACH-2023-041 livré — 5 000 kg HDPE reçus de PolyChim Industries.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      title: 'Journal d\'Activité Global',
      trailing: TextButton(
        onPressed: () {},
        child: const Text('Voir tout', style: TextStyle(fontSize: 12)),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            _entries.map((e) => _ActivityTile(entry: e, theme: theme)).toList(),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry, required this.theme});
  final _ActivityEntry entry;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp20, vertical: AppTheme.sp12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.blueLightest)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration:
                BoxDecoration(color: entry.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppTheme.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: entry.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.module,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: entry.color,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(entry.time, style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 5),
                Text(entry.event,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityEntry {
  const _ActivityEntry({
    required this.time,
    required this.module,
    required this.color,
    required this.event,
  });
  final String time;
  final String module;
  final Color color;
  final String event;
}

// ──────────────────────────────────────────────────────────────────────────────
// Production tab
// ──────────────────────────────────────────────────────────────────────────────

class _ProductionTab extends StatelessWidget {
  const _ProductionTab();

  static const _weekLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const _weekData = [1240.0, 1380.0, 1150.0, 1420.0, 1284.0, 820.0, 0.0];
  static const _target = 1500.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly bar chart card
          const AppCard(
            title: 'Production par Jour (Semaine Actuelle)',
            subtitle: 'Unités produites vs objectif (1 500 u/j)',
            child: SizedBox(
              height: 220,
              child: _WeeklyBarChart(
                  data: _weekData, target: _target, labels: _weekLabels),
            ),
          ),
          const SizedBox(height: AppTheme.sp24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _LotStatusTable()),
              const SizedBox(width: AppTheme.sp20),
              Expanded(child: _OeeTrendCard()),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({
    required this.data,
    required this.target,
    required this.labels,
  });

  final List<double> data;
  final double target;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final max = target * 1.1;
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (i) {
              final frac = (data[i] / max).clamp(0.0, 1.0);
              final targetFrac = target / max;
              final isToday = i == 4;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value label
                      if (data[i] > 0)
                        Text(
                          data[i].toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isToday ? Colors.black : AppTheme.greyLight,
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Bar with target line overlay
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Background track
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: AppTheme.whiteSurface2,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // Fill
                          if (data[i] > 0)
                            FractionallySizedBox(
                              heightFactor: frac,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Colors.black
                                      : data[i] >= target
                                          ? AppTheme.greenBright
                                          : Colors.black.withOpacity(0.6),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          // Target line
                          Positioned(
                            bottom: 160 * targetFrac,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1.5,
                              color: AppTheme.red.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppTheme.sp8),
        Row(
          children: labels
              .map((l) => Expanded(
                    child: Text(
                      l,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.greyLight,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _LotStatusTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lots = MockData.productions;
    return AppCard(
      title: 'Statut des Lots',
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.sp16, vertical: AppTheme.sp10),
            decoration: const BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: AppTheme.whiteTintedorGreyAddAlpha02)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: _TH('LOT')),
                Expanded(flex: 3, child: _TH('PRODUIT')),
                Expanded(flex: 2, child: _TH('STATUT')),
                Expanded(flex: 2, child: _TH('AVANCEMENT')),
              ],
            ),
          ),
          ...lots.map((p) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.sp16, vertical: AppTheme.sp12),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: AppTheme.blueLightest)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        p.lotReference,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        p.produitDesignation,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: StatusBadge.fromProduction(statut: p.statut),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: p.progression,
                                minHeight: 6,
                                backgroundColor: AppTheme.whiteSurface2,
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(p.progression * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  const _TH(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppTheme.greyLight,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _OeeTrendCard extends StatelessWidget {
  static const _labels = ['S1', 'S2', 'S3', 'S4'];
  static const _values = [88.2, 90.5, 91.8, 94.2];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      title: 'Évolution OEE — 4 semaines',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(_values.length, (i) {
              final isLast = i == _values.length - 1;
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      '${_values[i]}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isLast ? Colors.black : Colors.black,
                      ),
                    ),
                    Text(
                      _labels[i],
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppTheme.sp8),
                    Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isLast ? Colors.black : AppTheme.whiteSurface2,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppTheme.sp16),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  size: 16, color: AppTheme.greenBright),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Amélioration de +6 points sur le mois — Objectif 95% atteint prochainement.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppTheme.greenBright),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Ventes tab
// ──────────────────────────────────────────────────────────────────────────────

class _VentesTab extends StatelessWidget {
  const _VentesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Ventes Totales',
                  value: '€142.6K',
                  trend: '+12%',
                  trendPositive: true,
                  icon: Icons.euro_rounded,
                  iconColor: AppTheme.greenBright,
                  iconBackground: AppTheme.greenLight,
                ),
              ),
              SizedBox(width: AppTheme.sp16),
              Expanded(
                child: StatCard(
                  title: 'Commandes Livrées',
                  value: '98',
                  subtitle: 'Sur 128 commandes',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: Colors.black,
                  iconBackground: Colors.black,
                ),
              ),
              SizedBox(width: AppTheme.sp16),
              Expanded(
                child: StatCard(
                  title: 'Taux de Satisfaction',
                  value: '97.2%',
                  subtitle: 'Basé sur les retours client',
                  icon: Icons.thumb_up_outlined,
                  iconColor: AppTheme.blueLight,
                  iconBackground: AppTheme.blueLightest,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),
          _TopClientTable(),
        ],
      ),
    );
  }
}

class _TopClientTable extends StatelessWidget {
  static const List<_ClientRow> _rows = [
    _ClientRow('Industries Mécaniques SARL', '€ 48 200', 12, 0.98),
    _ClientRow('BTP Construction Est', '€ 36 400', 9, 0.95),
    _ClientRow('Aéro-Logistique Nord', '€ 31 100', 7, 1.0),
    _ClientRow('EnergiePlast Ouest', '€ 26 900', 6, 0.92),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      title: 'Top Clients — Octobre 2023',
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.sp20, vertical: AppTheme.sp10),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: AppTheme.whiteTintedorGreyAddAlpha02))),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _TH('CLIENT')),
                Expanded(flex: 2, child: _TH('CA TOTAL')),
                Expanded(flex: 1, child: _TH('CMDS')),
                Expanded(flex: 2, child: _TH('TAUX LIVRAISON')),
              ],
            ),
          ),
          ..._rows.map((r) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.sp20, vertical: AppTheme.sp14),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppTheme.blueLightest))),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child:
                            Text(r.client, style: theme.textTheme.labelLarge)),
                    Expanded(
                        flex: 2,
                        child: Text(r.ca,
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700))),
                    Expanded(
                        flex: 1,
                        child: Text('${r.cmds}',
                            style: theme.textTheme.bodyMedium)),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: r.livraison,
                                minHeight: 6,
                                backgroundColor: AppTheme.whiteSurface2,
                                valueColor: AlwaysStoppedAnimation(
                                    r.livraison > 0.95
                                        ? AppTheme.greenBright
                                        : AppTheme.yellow),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(r.livraison * 100).round()}%',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ClientRow {
  const _ClientRow(this.client, this.ca, this.cmds, this.livraison);
  final String client;
  final String ca;
  final int cmds;
  final double livraison;
}

// ──────────────────────────────────────────────────────────────────────────────
// Stocks tab
// ──────────────────────────────────────────────────────────────────────────────

class _StocksTab extends StatelessWidget {
  const _StocksTab();

  @override
  Widget build(BuildContext context) {
    final matieres = MockData.matieresPremieres;
    final produits = MockData.produits;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Valeur Totale Stock',
                  value: '€ 2.4M',
                  subtitle: 'Méthode FIFO',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: Colors.black,
                  iconBackground: Colors.black,
                ),
              ),
              SizedBox(width: AppTheme.sp16),
              Expanded(
                child: StatCard(
                  title: 'Rotation Globale',
                  value: '4.2x',
                  subtitle: 'Objectif: >4x/an',
                  trend: '+0.3',
                  trendPositive: true,
                  icon: Icons.autorenew_rounded,
                  iconColor: AppTheme.greenBright,
                  iconBackground: AppTheme.greenLight,
                ),
              ),
              SizedBox(width: AppTheme.sp16),
              Expanded(
                child: StatCard(
                  title: 'Articles Sous Seuil',
                  value: '18',
                  alertLevel: 'error',
                  subtitle: 'Réapprovisionnement requis',
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppTheme.red,
                  iconBackground: AppTheme.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),
          AppCard(
            title: 'Niveaux Matières Premières',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: matieres.map((m) {
                final level =
                    (m.stockActuel / (m.seuilMinimal * 2)).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.sp16),
                  child: StockLevelIndicator(
                    label: '${m.type.label} — ${m.stockActuel} ${m.unite}',
                    level: level,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppTheme.sp24),
          AppCard(
            title: 'Produits Finis — Niveaux',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: produits
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.sp16),
                        child: StockLevelIndicator(
                          label:
                              '${p.designation} (${p.stockActuel.toStringAsFixed(0)} u)',
                          level: p.niveauReapprovisionnement,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
