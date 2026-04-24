import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/article.dart';
import '../models/stock_movement.dart';
import '../providers/stock_provider.dart';
import '../providers/article_provider.dart';

class StockDetailScreen extends StatefulWidget {
  final Article article;
  const StockDetailScreen({super.key, required this.article});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadHistorique(widget.article.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();
    final historique = stockProvider.historiqueOf(widget.article.id!);
    final article = widget.article;
    final priceFmt = NumberFormat.currency(locale: 'fr_TN', symbol: 'TND', decimalDigits: 3);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(article.reference, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Ajustement manuel',
            onPressed: () => _showAdjustDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Carte résumé article
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: article.enAlerte
                    ? [Colors.red[600]!, Colors.red[400]!]
                    : [const Color(0xFF1565C0), const Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.designation,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${article.type} · ${article.uniteMesure ?? ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCol(label: 'Stock actuel', value: article.stockActuel.toStringAsFixed(2)),
                    _StatCol(label: 'Seuil minimum', value: article.stockMinimum.toStringAsFixed(2)),
                    _StatCol(label: 'Prix unitaire', value: priceFmt.format(article.prixUnitaire)),
                  ],
                ),
                if (article.enAlerte) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Stock inférieur au seuil minimum — réapprovisionner',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Historique
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Historique des mouvements',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              if (stockProvider.isLoading)
                const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 10),

          if (historique.isEmpty && !stockProvider.isLoading)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text('Aucun mouvement enregistré',
                    style: TextStyle(color: Colors.grey[500])),
              ),
            ),

          ...historique.map((m) => _MovementCard(movement: m)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAdjustDialog(BuildContext context) {
    final qteCtrl = TextEditingController();
    final motifCtrl = TextEditingController();
    String type = 'IN';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Ajustement de stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.article.designation,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Stock actuel : ${widget.article.stockActuel}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TypeBtn(
                      label: 'Entrée',
                      icon: Icons.add_circle_outline,
                      color: Colors.green,
                      selected: type == 'IN',
                      onTap: () => setDlgState(() => type = 'IN'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypeBtn(
                      label: 'Sortie',
                      icon: Icons.remove_circle_outline,
                      color: Colors.red,
                      selected: type == 'OUT',
                      onTap: () => setDlgState(() => type = 'OUT'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qteCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: motifCtrl,
                decoration: InputDecoration(
                  labelText: 'Motif',
                  hintText: 'Inventaire, correction, perte…',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: type == 'IN' ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final qte = double.tryParse(qteCtrl.text) ?? 0;
                if (qte <= 0) return;
                Navigator.pop(ctx);
                final err = await context.read<StockProvider>().adjust(
                      articleId: widget.article.id!,
                      quantite: qte,
                      type: type,
                      motif: motifCtrl.text.trim().isEmpty
                          ? 'Ajustement manuel'
                          : motifCtrl.text.trim(),
                    );
                // Recharger l'article pour mettre à jour le stock affiché
                if (context.mounted) {
                  context.read<ArticleProvider>().load();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(err ?? 'Stock ajusté avec succès'),
                    backgroundColor: err == null ? Colors.green : Colors.red,
                  ));
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  const _StatCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      );
}

class _MovementCard extends StatelessWidget {
  final StockMovement movement;
  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isIn = movement.isEntree;
    final color = isIn ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isIn ? '+${movement.quantite}' : '-${movement.quantite}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: color),
                      ),
                      Text(movement.dateFormatted,
                          style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(movement.sourceLabel,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  if (movement.referenceDocument != null &&
                      movement.referenceDocument != 'ADJ') ...[
                    Text(movement.referenceDocument!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ],
                  if (movement.motif != null) ...[
                    Text(movement.motif!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ],
                  if (movement.stockApres != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Stock après : ${movement.stockApres!.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _TypeBtn({
    required this.label, required this.icon, required this.color,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? color : Colors.grey[300]!, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? color : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: selected ? color : Colors.grey[600],
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13)),
            ],
          ),
        ),
      );
}
