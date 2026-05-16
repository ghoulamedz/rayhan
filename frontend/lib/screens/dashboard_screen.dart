import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';

import '../providers/dashboard_provider.dart';
import '../models/dashboard_kpi.dart';
import '../widgets/kpi_card.dart';
import '../widgets/app_drawer.dart';

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
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final currencyFmt =
        NumberFormat.currency(locale: 'fr_TN', symbol: 'TND', decimalDigits: 3);
    final dateFmt = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tableau de bord',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              dateFmt.format(DateTime.now()),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Actualiser',
            onPressed: () => context.read<DashboardProvider>().load(),
          ),
          const SizedBox(width: 8),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: _buildBody(provider, currencyFmt),
    );
  }

  Widget _buildBody(DashboardProvider provider, NumberFormat currencyFmt) {
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
              Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(provider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.read<DashboardProvider>().load(),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final kpi = provider.kpi;
    if (kpi == null) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardProvider>().load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: 'Ventes — Ce mois'),
            const SizedBox(height: 12),
            _VentesGrid(kpi: kpi, currencyFmt: currencyFmt),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Achats & Production'),
            const SizedBox(height: 12),
            _AchatsProductionGrid(kpi: kpi),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Stock'),
            const SizedBox(height: 12),
            _StockSection(kpi: kpi),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
      ),
    );
  }
}

class _VentesGrid extends StatelessWidget {
  final DashboardKpi kpi;
  final NumberFormat currencyFmt;

  const _VentesGrid({required this.kpi, required this.currencyFmt});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        KpiCard(
          title: "Chiffre d'affaires",
          value: currencyFmt.format(kpi.ventes.chiffreAffairesMois),
          subtitle: 'Ce mois',
          icon: Icons.trending_up,
          color: const Color(0xFF10B981),
        ),
        KpiCard(
          title: 'Commandes ce mois',
          value: '${kpi.ventes.nbCommandesMois}',
          subtitle: 'Bons de commande',
          icon: Icons.receipt_long_outlined,
          color: const Color(0xFF3B82F6),
        ),
        KpiCard(
          title: 'Commandes en cours',
          value: '${kpi.ventes.commandesEnCours}',
          subtitle: 'En attente livraison',
          icon: Icons.pending_actions_outlined,
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }
}

class _AchatsProductionGrid extends StatelessWidget {
  final DashboardKpi kpi;
  const _AchatsProductionGrid({required this.kpi});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        KpiCard(
          title: 'Achats en attente',
          value: '${kpi.achats.commandesEnAttente}',
          subtitle: 'Bons non réceptionnés',
          icon: Icons.local_shipping_outlined,
          color: const Color(0xFF8B5CF6),
        ),
        KpiCard(
          title: 'OF en cours',
          value: '${kpi.production.ofEnCours}',
          subtitle: 'Ordres de fabrication',
          icon: Icons.precision_manufacturing_outlined,
          color: const Color(0xFFEF4444),
        ),
        KpiCard(
          title: 'OF planifiés',
          value: '${kpi.production.ofPlanifies}',
          subtitle: 'En attente lancement',
          icon: Icons.schedule_outlined,
          color: const Color(0xFF6366F1),
        ),
      ],
    );
  }
}

class _StockSection extends StatelessWidget {
  final DashboardKpi kpi;
  const _StockSection({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final enAlerte = kpi.stock.articlesEnAlerte;
    final details = kpi.stock.articlesEnAlerteDetails;

    return Column(
      children: [
        KpiCard(
          title: 'Articles en alerte stock',
          value: '$enAlerte',
          subtitle: enAlerte == 0
              ? 'Tous les articles sont suffisamment approvisionnés'
              : 'Stock inférieur au seuil minimum',
          icon: enAlerte == 0
              ? Icons.check_circle_outline
              : Icons.warning_amber_outlined,
          color:
              enAlerte == 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: details.map<Widget>((item) {
                final m = item as Map<String, dynamic>;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.warning_amber,
                        color: Colors.red[600], size: 18),
                  ),
                  title: Text(
                    m['reference'] ?? m['designation'] ?? 'Article',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  trailing: Text(
                    'Stock: ${m['quantiteEnStock'] ?? 0}',
                    style: TextStyle(color: Colors.red[600], fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
