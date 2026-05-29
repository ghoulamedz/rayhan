import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/dashboard_kpi.dart';
import '../../constants/app_theme.dart';

class ChartSection extends StatelessWidget {
  final DashboardKpi kpi;
  final List<double> revenueByMonth;
  final List<double> ordersByDay;

  const ChartSection({
    super.key,
    required this.kpi,
    required this.revenueByMonth,
    required this.ordersByDay,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 700;
        return Column(
          children: [
            isWide
                ? Row(
                    children: [
                      Expanded(child: _RevenueChart(data: revenueByMonth)),
                      const SizedBox(width: 16),
                      Expanded(child: _OrdersChart(data: ordersByDay)),
                    ],
                  )
                : Column(
                    children: [
                      _RevenueChart(data: revenueByMonth),
                      const SizedBox(height: 16),
                      _OrdersChart(data: ordersByDay),
                    ],
                  ),
            const SizedBox(height: 16),
            isWide
                ? Row(
                    children: [
                      Expanded(child: _ProductionChart(kpi: kpi)),
                      const SizedBox(width: 16),
                      Expanded(child: _StockChart(kpi: kpi)),
                    ],
                  )
                : Column(
                    children: [
                      _ProductionChart(kpi: kpi),
                      const SizedBox(height: 16),
                      _StockChart(kpi: kpi),
                    ],
                  ),
          ],
        );
      },
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<double> data;

  const _RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppTheme.withGlass(
      radius: 16,
      blur: 16,
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.kPrimaryTeal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text("Chiffre d'affaires", style: AppTheme.titleSmall),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.kPrimaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Annuel',
                      style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.kPrimaryTeal)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppTheme.kBorderLight,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (v, _) {
                          final months = [
                            'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
                            'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
                          ];
                          final idx = v.toInt();
                          if (idx >= 0 && idx < months.length) {
                            return Text(months[idx],
                                style: AppTheme.bodySmall
                                    .copyWith(color: AppTheme.kTextHint));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                          data.length, (i) => FlSpot(i.toDouble(), data[i])),
                      isCurved: true,
                      color: AppTheme.kPrimaryTeal,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: AppTheme.kPrimaryTeal,
                          strokeWidth: 2,
                          strokeColor: AppTheme.kWhite,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.kPrimaryTeal.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersChart extends StatelessWidget {
  final List<double> data;

  const _OrdersChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppTheme.withGlass(
      radius: 16,
      blur: 16,
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.kCtaOrange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Commandes', style: AppTheme.titleSmall),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.kCtaOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('7 jours',
                      style: AppTheme.bodySmall
                          .copyWith(color: AppTheme.kCtaOrange)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppTheme.kBorderLight,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (v, _) {
                          final labels = [
                            'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
                          ];
                          final idx = v.toInt();
                          if (idx >= 0 && idx < labels.length) {
                            return Text(labels[idx],
                                style: AppTheme.bodySmall
                                    .copyWith(color: AppTheme.kTextHint));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    data.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i],
                          color: AppTheme.kCtaOrange,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    ),
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

class _ProductionChart extends StatelessWidget {
  final DashboardKpi kpi;

  const _ProductionChart({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final total = kpi.production.ofEnCours + kpi.production.ofPlanifies;
    final pct = total > 0 ? kpi.production.ofEnCours / total : 0.0;

    return AppTheme.withGlass(
      radius: 16,
      blur: 16,
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.kPrimaryNavy,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Production', style: AppTheme.titleSmall),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.kPrimaryNavy.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${total} OF',
                      style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.kPrimaryNavy)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 160,
                width: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 50,
                        sections: [
                          PieChartSectionData(
                            value: kpi.production.ofEnCours.toDouble(),
                            color: AppTheme.kPrimaryTeal,
                            radius: 40,
                            title: '',
                          ),
                          PieChartSectionData(
                            value: kpi.production.ofPlanifies.toDouble(),
                            color: AppTheme.kBorderLight,
                            radius: 40,
                            title: '',
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(pct * 100).toInt()}%',
                            style: AppTheme.headlineSmall
                                .copyWith(color: AppTheme.kPrimaryTeal)),
                        Text('En cours',
                            style: AppTheme.bodySmall
                                .copyWith(color: AppTheme.kTextSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(AppTheme.kPrimaryTeal, 'En cours'),
                const SizedBox(width: 16),
                _legendDot(AppTheme.kBorderLight, 'Planifiés'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
      ],
    );
  }
}

class _StockChart extends StatelessWidget {
  final DashboardKpi kpi;

  const _StockChart({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final details = kpi.stock.articlesEnAlerteDetails;
    final normalCount = details.isEmpty ? 10 : 10 - details.length;

    return AppTheme.withGlass(
      radius: 16,
      blur: 16,
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kpi.stock.articlesEnAlerte > 0
                        ? AppTheme.kErrorRed
                        : AppTheme.kSuccessGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Stock', style: AppTheme.titleSmall),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kpi.stock.articlesEnAlerte > 0
                        ? AppTheme.kErrorRedLight
                        : AppTheme.kSuccessGreenLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${kpi.stock.articlesEnAlerte} alerte(s)',
                    style: AppTheme.bodySmall.copyWith(
                      color: kpi.stock.articlesEnAlerte > 0
                          ? AppTheme.kErrorRed
                          : AppTheme.kSuccessGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(
                        value: normalCount.toDouble(),
                        color: AppTheme.kSuccessGreen,
                        radius: 40,
                        title: '$normalCount',
                        titleStyle: const TextStyle(
                            color: AppTheme.kWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      PieChartSectionData(
                        value: kpi.stock.articlesEnAlerte.toDouble(),
                        color: AppTheme.kErrorRed,
                        radius: 40,
                        title: '${kpi.stock.articlesEnAlerte}',
                        titleStyle: const TextStyle(
                            color: AppTheme.kWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(AppTheme.kSuccessGreen, 'Normal'),
                const SizedBox(width: 16),
                _legendDot(AppTheme.kErrorRed, 'Alerte'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
      ],
    );
  }
}