import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/sales_order.dart';
import '../providers/ventes_provider.dart';

class SalesOrderDetailScreen extends StatelessWidget {
  final SalesOrder order;
  const SalesOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_TN', symbol: 'TND', decimalDigits: 3);
    final statusColor = Color(order.statutColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(order.reference ?? '—',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (order.peutLivrer)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () => _confirmDeliver(context),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: const Text('Livrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête statut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: statusColor, size: 10),
                const SizedBox(width: 8),
                Text(order.statutLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Infos générales
          _InfoCard(children: [
            _InfoRow(label: 'Client', value: order.client?.raisonSociale ?? '—'),
            _InfoRow(label: 'Date commande', value: order.dateCommande),
            if (order.dateLivraisonSouhaitee != null)
              _InfoRow(label: 'Livraison souhaitée', value: order.dateLivraisonSouhaitee!),
            if (order.notes != null && order.notes!.isNotEmpty)
              _InfoRow(label: 'Notes', value: order.notes!),
          ]),
          const SizedBox(height: 16),

          // Lignes
          const Text('Lignes de commande',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          ...order.lignes.map((l) => _LigneCard(ligne: l, fmt: fmt)),
          const SizedBox(height: 16),

          // Totaux
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                _TotalRow(label: 'Total HT', value: fmt.format(order.totalHT)),
                _TotalRow(label: 'TVA (19%)', value: fmt.format(order.totalTVA)),
                const Divider(),
                _TotalRow(
                    label: 'Total TTC',
                    value: fmt.format(order.totalTTC),
                    bold: true,
                    color: const Color(0xFF10B981)),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmDeliver(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer la livraison ?'),
        content: Text(
            'Livrer toutes les lignes de la commande ${order.reference} ?\n\nLe stock sera mis à jour automatiquement.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981)),
            onPressed: () async {
              Navigator.pop(context);
              final err = await context
                  .read<VentesProvider>()
                  .deliver(order.id!, order.lignes);
              if (context.mounted) {
                if (err == null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Livraison enregistrée — stock mis à jour'),
                    backgroundColor: Colors.green,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Confirmer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13)),
            ),
          ],
        ),
      );
}

class _LigneCard extends StatelessWidget {
  final SalesOrderLine ligne;
  final NumberFormat fmt;
  const _LigneCard({required this.ligne, required this.fmt});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ligne.article?.designation ?? '—',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ligne.quantiteCommandee} ${ligne.article?.uniteMesure ?? ''} × ${fmt.format(ligne.prixUnitaireHT)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  fmt.format(ligne.montantTTC ?? ligne.montantTTCCalc),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF10B981)),
                ),
              ],
            ),
            if (ligne.quantiteLivree > 0)
              Text('Livré : ${ligne.quantiteLivree}',
                  style: const TextStyle(
                      color: Color(0xFF10B981), fontSize: 11)),
          ],
        ),
      );
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _TotalRow(
      {required this.label,
      required this.value,
      this.bold = false,
      this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    TextStyle(color: Colors.grey[600], fontSize: 13)),
            Text(value,
                style: TextStyle(
                    fontWeight:
                        bold ? FontWeight.bold : FontWeight.normal,
                    fontSize: bold ? 16 : 13,
                    color: color ?? const Color(0xFF374151))),
          ],
        ),
      );
}
