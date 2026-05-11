import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/production_provider.dart';
import '../providers/article_provider.dart';
import '../models/article.dart';
import '../models/production_order.dart';
import '../services/production_service.dart';

class ProductionFormScreen extends StatefulWidget {
  const ProductionFormScreen({super.key});

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Article? _selectedProduit;
  final _qteCtrl = TextEditingController();
  DateTime? _datePlanifiee;
  List<BomLine> _bom = [];
  bool _loadingBom = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ArticleProvider>().articles.isEmpty) {
        context.read<ArticleProvider>().load();
      }
    });
  }

  @override
  void dispose() {
    _qteCtrl.dispose();
    super.dispose();
  }

  List<Article> get _produitsFinis => context
      .read<ArticleProvider>()
      .articles
      .where((a) => a.type == 'PF')
      .toList();

  Future<void> _onProduitSelected(Article? article) async {
    setState(() {
      _selectedProduit = article;
      _bom = [];
    });
    if (article?.id != null) {
      setState(() => _loadingBom = true);
      try {
        final bom = await ProductionService.getBom(article!.id!);
        setState(() => _bom = bom);
      } catch (_) {}
      setState(() => _loadingBom = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduit == null) {
      _showErr('Sélectionnez un produit fini');
      return;
    }
    if (_datePlanifiee == null) {
      _showErr('Choisissez une date planifiée');
      return;
    }
    if (_bom.isEmpty) {
      _showErr('Ce produit n\'a pas de nomenclature BOM définie');
      return;
    }

    setState(() => _saving = true);

    final err = await context.read<ProductionProvider>().plan(
          produitFiniId: _selectedProduit!.id!,
          quantite: double.tryParse(_qteCtrl.text) ?? 0,
          datePlanifiee: _datePlanifiee!.toIso8601String().substring(0, 10),
        );

    if (mounted) {
      setState(() => _saving = false);
      if (err == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ordre de fabrication planifié'),
          backgroundColor: Colors.green,
        ));
      } else {
        _showErr(err);
      }
    }
  }

  void _showErr(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    final articles = context.watch<ArticleProvider>();
    final qte = double.tryParse(_qteCtrl.text) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Nouvel ordre de fabrication',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Card(
              title: 'Produit à fabriquer',
              child: articles.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Article>(
                      initialValue: _selectedProduit,
                      hint: const Text('Sélectionner un produit fini (PF)'),
                      decoration: _deco('Produit fini'),
                      items: _produitsFinis
                          .map((a) => DropdownMenuItem(
                                value: a,
                                child:
                                    Text('${a.reference} — ${a.designation}'),
                              ))
                          .toList(),
                      onChanged: _onProduitSelected,
                      validator: (v) => v == null ? 'Obligatoire' : null,
                    ),
            ),
            const SizedBox(height: 12),

            // BOM affiché après sélection
            if (_loadingBom)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator())),
            if (_bom.isNotEmpty) ...[
              _Card(
                title: 'Nomenclature (BOM)',
                child: Column(
                  children: _bom.map((b) {
                    final qteNecessaire = qte * b.quantiteParUnite;
                    final stock = b.composant?.stockActuel ?? 0;
                    final ok = stock >= qteNecessaire;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Icon(
                              ok
                                  ? Icons.check_circle_outline
                                  : Icons.warning_amber_outlined,
                              size: 16,
                              color: ok ? Colors.green : Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(b.composant?.designation ?? '—',
                                style: const TextStyle(fontSize: 13)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(b.quantiteParUnite * (qte > 0 ? qte : 1)).toStringAsFixed(2)} ${b.uniteMesure ?? ''}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ok
                                        ? const Color(0xFF374151)
                                        : Colors.orange),
                              ),
                              Text('Stock: ${stock.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_selectedProduit != null && !_loadingBom && _bom.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber,
                        color: Colors.orange[700], size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                          'Aucune nomenclature BOM définie pour ce produit.',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),

            _Card(
              title: 'Quantité & Date',
              child: Column(
                children: [
                  TextFormField(
                    controller: _qteCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _deco('Quantité à produire')
                        .copyWith(hintText: 'Ex: 1000'),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obligatoire';
                      if ((double.tryParse(v) ?? 0) <= 0)
                        return 'Doit être > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _datePlanifiee = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            _datePlanifiee != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(_datePlanifiee!)
                                : 'Date planifiée *',
                            style: TextStyle(
                                color: _datePlanifiee != null
                                    ? Colors.black87
                                    : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Planifier l\'OF',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF6B7280))),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
}

InputDecoration _deco(String label) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
