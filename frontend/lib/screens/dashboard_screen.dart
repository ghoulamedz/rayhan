import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/dashboard_provider.dart';
import '../providers/article_provider.dart';
import '../providers/ventes_provider.dart';
import '../providers/achats_provider.dart';
import '../providers/production_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/dashboard/kpi_grid.dart';
import '../widgets/dashboard/chart_section.dart';
import '../widgets/dashboard/activity_feed.dart';
import '../widgets/dashboard/suggestion_card.dart';
import '../models/dashboard_kpi.dart';
import '../mock/mock_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dash = context.read<DashboardProvider>();
      dash.load();
      context.read<ArticleProvider>().load();
      context.read<VentesProvider>().load();
      context.read<AchatsProvider>().load();
      context.read<ProductionProvider>().load();
    });
  }

  void _refreshAll() {
    final dash = context.read<DashboardProvider>();
    dash.load();
    context.read<ArticleProvider>().load().then((_) {
      dash.loadSuggestions(
        articles: context.read<ArticleProvider>().articles,
        salesOrders: context.read<VentesProvider>().orders,
        purchaseOrders: context.read<AchatsProvider>().orders,
        productionOrders: context.read<ProductionProvider>().orders,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final dateFmt = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return Scaffold(
      backgroundColor: AppTheme.kBackgroundWarm,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(BrandAppBar.heightFor(context)),
        child: BrandAppBar(
          title: 'Tableau de bord',
          subtitle: dateFmt.format(DateTime.now()),
          currentRoute: '/dashboard',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              tooltip: 'Actualiser',
              onPressed: _refreshAll,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: AppTheme.glassBackground(
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(DashboardProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_outlined,
                  size: 56, color: AppTheme.kTextHint),
              const SizedBox(height: 16),
              Text(provider.error!,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium
                      .copyWith(color: AppTheme.kTextSecondary)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.read<DashboardProvider>().load(),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: AppTheme.primaryButton,
              ),
            ],
          ),
        ),
      );
    }
    final kpi = provider.kpi;
    if (kpi == null) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () async { _refreshAll(); },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KpiGrid(kpi: kpi),
            const SizedBox(height: 20),
            _StockAlertSection(kpi: kpi),
            const SizedBox(height: 20),
            ChartSection(
              kpi: kpi,
              revenueByMonth: MockData.revenueByMonth(),
              ordersByDay: MockData.ordersByDay(),
            ),
            const SizedBox(height: 20),
            ActivityFeed(activities: MockData.recentActivity),
            const SizedBox(height: 20),
            _SuggestionsSection(
              provider: provider,
              onRefresh: _refreshAll,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StockAlertSection extends StatelessWidget {
  final DashboardKpi kpi;

  const _StockAlertSection({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final details = kpi.stock.articlesEnAlerteDetails;
    if (details.isEmpty) return const SizedBox.shrink();

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
                    color: AppTheme.kErrorRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Alertes Stock',
                    style: AppTheme.titleSmall.copyWith(fontSize: 15)),
                const Spacer(),
                Text('${details.length} article(s)',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.kTextSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            ...details.map<Widget>((item) {
              final m = item as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.kErrorRedLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppTheme.kErrorRed, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['designation'] ??
                                  m['reference'] ??
                                  'Article',
                              style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.kErrorRed),
                            ),
                            Text(
                              'Stock: ${m['quantiteEnStock'] ?? 0}',
                              style: AppTheme.bodySmall
                                  .copyWith(color: AppTheme.kErrorRed),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsSection extends StatelessWidget {
  final DashboardProvider provider;
  final VoidCallback onRefresh;

  const _SuggestionsSection({
    required this.provider,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.suggestions.isEmpty && !provider.suggestionsLoading) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Text('Suggestions', style: AppTheme.titleSmall.copyWith(fontSize: 15)),
              const Spacer(),
              if (provider.suggestionsLoading)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              if (!provider.suggestionsLoading && provider.suggestions.isNotEmpty)
                GestureDetector(
                  onTap: onRefresh,
                  child: Text('Actualiser', style: AppTheme.bodySmall.copyWith(color: AppTheme.kPrimaryTeal)),
                ),
            ],
          ),
        ),
        ...provider.suggestions.map((s) => SuggestionCard(
          suggestion: s,
          onDismiss: () => provider.markSuggestionRead(s.id),
        )),
      ],
    );
  }
}