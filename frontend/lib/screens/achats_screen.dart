import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/achats_provider.dart';
import '../models/purchase_order.dart';
import '../widgets/app_drawer.dart';
import 'purchase_order_form_screen.dart';
import 'purchase_order_detail_screen.dart';

class AchatsScreen extends StatefulWidget {
  const AchatsScreen({super.key});

  @override
  State<AchatsScreen> createState() => _AchatsScreenState();
}

class _AchatsScreenState extends State<AchatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchatsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AchatsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Commandes Achats',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (!provider.isLoading)
              Text('${provider.orders.length} commande(s)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<AchatsProvider>().load(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/achats'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PurchaseOrderFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle commande'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(AchatsProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AchatsProvider>().load(),
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
            Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Aucune commande achat',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<AchatsProvider>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.orders.length,
        itemBuilder: (ctx, i) => _OrderCard(order: provider.orders[i]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final PurchaseOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_TN', symbol: 'TND', decimalDigits: 3);
    final color = Color(order.statutColor);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => PurchaseOrderDetailScreen(order: order))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(order.reference ?? '—',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(order.statutLabel,
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.business_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(order.fournisseur?.raisonSociale ?? '—',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(order.dateCommande,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  Text(fmt.format(order.totalTTC),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF8B5CF6))),
                ],
              ),
              if (order.lignes.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('${order.lignes.length} ligne(s)',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
