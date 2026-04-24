import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/production_provider.dart';
import '../models/production_order.dart';
import '../widgets/app_drawer.dart';
import 'production_form_screen.dart';
import 'production_detail_screen.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  String _filterStatut = 'TOUS';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductionProvider>().load();
    });
  }

  static const _filters = [
    ('TOUS', 'Tous'),
    ('PLANIFIE', 'Planifiés'),
    ('LANCE', 'Lancés'),
    ('TERMINE', 'Terminés'),
  ];

  List<ProductionOrder> _filtered(List<ProductionOrder> orders) {
    if (_filterStatut == 'TOUS') return orders;
    return orders.where((o) => o.statut == _filterStatut).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductionProvider>();
    final filtered = _filtered(provider.orders);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Production', style: TextStyle(fontWeight: FontWeight.bold)),
            if (!provider.isLoading)
              Text('${provider.ofPlanifies} planifié(s) · ${provider.ofEnCours} en cours',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<ProductionProvider>().load(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/production'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProductionFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel OF'),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: Column(
        children: [
          // Chips filtre
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final selected = _filterStatut == f.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f.$2),
                      selected: selected,
                      onSelected: (_) => setState(() => _filterStatut = f.$1),
                      selectedColor: const Color(0xFF6366F1).withOpacity(0.15),
                      checkmarkColor: const Color(0xFF6366F1),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: selected ? const Color(0xFF6366F1) : Colors.grey[700],
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(child: _buildBody(provider, filtered)),
        ],
      ),
    );
  }

  Widget _buildBody(ProductionProvider provider, List<ProductionOrder> filtered) {
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
              onPressed: () => context.read<ProductionProvider>().load(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.precision_manufacturing_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Aucun ordre de fabrication',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ProductionProvider>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => _OFCard(order: filtered[i]),
      ),
    );
  }
}

class _OFCard extends StatelessWidget {
  final ProductionOrder order;
  const _OFCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = Color(order.statutColor);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductionDetailScreen(order: order))),
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
                  const Icon(Icons.factory_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(order.produitFini?.designation ?? '—',
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
                      Text(order.datePlanifiee,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '${order.quantitePlanifiee.toStringAsFixed(0)} ${order.produitFini?.uniteMesure ?? ''}',
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (order.quantiteRealisee > 0) ...[
                        Text(' / réalisé: ${order.quantiteRealisee.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              ),
              // Barre de progression si lancé
              if (order.statut == 'LANCE' || order.statut == 'EN_COURS') ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: order.quantitePlanifiee > 0
                      ? (order.quantiteRealisee / order.quantitePlanifiee).clamp(0.0, 1.0)
                      : 0,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              // Actions rapides
              if (order.peutLancer || order.peutTerminer) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.peutLancer)
                      _ActionBtn(
                        label: 'Lancer',
                        icon: Icons.play_arrow_rounded,
                        color: const Color(0xFFF59E0B),
                        onTap: () => _launch(context, order),
                      ),
                    if (order.peutTerminer)
                      _ActionBtn(
                        label: 'Terminer',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF10B981),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => ProductionDetailScreen(order: order))),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _launch(BuildContext context, ProductionOrder order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lancer l\'OF ?'),
        content: Text(
            'Lancer ${order.reference} ?\n\nLes matières premières seront consommées du stock.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () async {
              Navigator.pop(context);
              final err = await context.read<ProductionProvider>().launch(order.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(err ?? 'OF lancé — matières premières consommées'),
                  backgroundColor: err == null ? Colors.green : Colors.red,
                ));
              }
            },
            child: const Text('Lancer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
      );
}
