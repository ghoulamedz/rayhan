import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ventes_provider.dart';
import '../models/sales_order.dart';
import '../widgets/app_drawer.dart';
import '../widgets/brand_app_bar.dart';
import '../constants/app_theme.dart';
import 'sales_order_form_screen.dart';
import 'sales_order_detail_screen.dart';

class VentesScreen extends StatefulWidget {
  const VentesScreen({super.key});

  @override
  State<VentesScreen> createState() => _VentesScreenState();
}

class _VentesScreenState extends State<VentesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VentesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VentesProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(BrandAppBar.heightFor(context)),
        child: BrandAppBar(
          title: 'Commandes Ventes',
          subtitle: !provider.isLoading
              ? '${provider.orders.length} commande(s)'
              : null,
          currentRoute: '/ventes',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: () => context.read<VentesProvider>().load(),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/ventes'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SalesOrderFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle commande'),
      ),
      body: AppTheme.glassBackground(
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(VentesProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.kTextHint),
            const SizedBox(height: 12),
            Text(provider.error!,
                style: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.kTextSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<VentesProvider>().load(),
              style: AppTheme.primaryButton,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (provider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: AppTheme.kBorderLight),
            const SizedBox(height: 16),
            Text('Aucune commande',
                style: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.kTextSecondary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<VentesProvider>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.orders.length,
        itemBuilder: (ctx, i) => _OrderCard(order: provider.orders[i]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final SalesOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_TN', symbol: 'TND', decimalDigits: 3);
    final color = Color(order.statutColor);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SalesOrderDetailScreen(order: order)),
      ),
      child: AppTheme.withGlass(
        radius: 12,
        blur: 16,
        opacity: 0.7,
        margin: const EdgeInsets.only(bottom: 10),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Row(
                children: [
                  Expanded(
                    child: Text(order.reference ?? '—',
                        style: AppTheme.titleSmall.copyWith(fontSize: 15)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(order.statutLabel,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.business_outlined,
                      size: 14, color: AppTheme.kTextSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(order.client?.raisonSociale ?? '—',
                        style: AppTheme.bodySmall.copyWith(fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppTheme.kTextSecondary),
                      const SizedBox(width: 4),
                      Text(order.dateCommande,
                          style: AppTheme.bodySmall
                              .copyWith(color: AppTheme.kTextSecondary)),
                    ],
                  ),
                  Text(fmt.format(order.totalTTC),
                      style: AppTheme.titleSmall.copyWith(
                          color: AppTheme.kSuccessGreen)),
                ],
              ),
              if (order.lignes.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('${order.lignes.length} ligne(s)',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.kTextSecondary)),
              ],
              ],
            ),
          ),
        ),
      ],
    ),
  ),
  ),
    );
  }
}
