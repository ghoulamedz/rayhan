import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/production_order.dart';
import '../providers/production_provider.dart';

class ProductionDetailScreen extends StatelessWidget {
  final ProductionOrder order;
  const ProductionDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final color = Color(order.statutColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(order.reference ?? '—',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statut
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: color, size: 10),
                const SizedBox(width: 8),
                Text(order.statutLabel,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Infos
          _InfoCard(children: [
            _InfoRow(label: 'Produit fini', value: order.produitFini?.designation ?? '—'),
            _InfoRow(label: 'Référence article', value: order.produitFini?.reference ?? '—'),
            _InfoRow(label: 'Qté planifiée',
                value: '${order.quantitePlanifiee.toStringAsFixed(0)} ${order.produitFini?.uniteMesure ?? ''}'),
            if (order.quantiteRealisee > 0)
              _InfoRow(label: 'Qté réalisée',
                  value: '${order.quantiteRealisee.toStringAsFixed(0)} ${order.produitFini?.uniteMesure ?? ''}'),
            _InfoRow(label: 'Date planifiée', value: order.datePlanifiee),
            if (order.dateLancement != null)
              _InfoRow(label: 'Date lancement', value: order.dateLancement!.substring(0, 10)),
            if (order.dateTerminaison != null)
              _InfoRow(label: 'Date terminaison', value: order.dateTerminaison!.substring(0, 10)),
            if (order.notes != null && order.notes!.isNotEmpty)
              _InfoRow(label: 'Notes', value: order.notes!),
          ]),
          const SizedBox(height: 24),

          // Actions
          if (order.peutLancer)
            _ActionCard(
              title: 'Lancer la production',
              description: 'Les matières premières seront consommées du stock selon la nomenclature BOM.',
              buttonLabel: 'Lancer l\'OF',
              buttonColor: const Color(0xFFF59E0B),
              icon: Icons.play_arrow_rounded,
              onConfirm: () async {
                final err = await context.read<ProductionProvider>().launch(order.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(err ?? 'OF lancé — matières premières consommées'),
                    backgroundColor: err == null ? Colors.green : Colors.red,
                  ));
                }
              },
            ),

          if (order.peutTerminer) ...[
            _CompleteCard(order: order),
          ],
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final IconData icon;
  final Future<void> Function() onConfirm;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.icon,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: Icon(icon, size: 18),
                label: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      );
}

class _CompleteCard extends StatefulWidget {
  final ProductionOrder order;
  const _CompleteCard({required this.order});

  @override
  State<_CompleteCard> createState() => _CompleteCardState();
}

class _CompleteCardState extends State<_CompleteCard> {
  final _qteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _qteCtrl.text = widget.order.quantitePlanifiee.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _qteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clôturer la production',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Text('Le produit fini sera ajouté au stock.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qteCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantité réalisée',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _complete,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Terminer l\'OF', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _complete() async {
    final qte = double.tryParse(_qteCtrl.text) ?? 0;
    if (qte <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantité invalide'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _saving = true);
    final err = await context.read<ProductionProvider>().complete(widget.order.id!, qte);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'OF terminé — produit fini ajouté au stock'),
        backgroundColor: err == null ? Colors.green : Colors.red,
      ));
    }
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
            SizedBox(width: 140,
                child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
            Expanded(child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          ],
        ),
      );
}
