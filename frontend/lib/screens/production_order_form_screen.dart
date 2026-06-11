import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/production_provider.dart';
import '../providers/article_provider.dart';
import '../models/article.dart';
import '../constants/app_theme.dart';

class ProductionOrderFormScreen extends StatefulWidget {
  const ProductionOrderFormScreen({super.key});

  @override
  State<ProductionOrderFormScreen> createState() => _ProductionOrderFormScreenState();
}

class _ProductionOrderFormScreenState extends State<ProductionOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  DateTime? _datePlanifiee;
  Article? _selectedProduct;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  List<Article> _pfArticles(BuildContext context) {
    final articles = context.read<ArticleProvider>().articles;
    return articles.where((a) => a.type == 'PF').toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      _showError('Veuillez sélectionner un produit fini');
      return;
    }
    if (_datePlanifiee == null) {
      _showError('Veuillez choisir une date planifiée');
      return;
    }

    setState(() => _isSubmitting = true);

    final err = await context.read<ProductionProvider>().plan(
      produitFiniId: _selectedProduct!.id!,
      quantite: double.tryParse(_qtyCtrl.text) ?? 0,
      datePlanifiee: DateFormat('yyyy-MM-dd').format(_datePlanifiee!),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (err == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ordre de fabrication planifié avec succès'),
            backgroundColor: AppTheme.kSuccessGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        _showError(err);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.kErrorRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pfArticles = _pfArticles(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvel Ordre de Fabrication'),
      ),
      body: AppTheme.glassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionCard(
                  title: 'PRODUIT FINI',
                  child: GestureDetector(
                    onTap: () => _pickProduct(context, pfArticles),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.kInputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.kBorderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _selectedProduct != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_selectedProduct!.designation,
                                          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                      Text('${_selectedProduct!.reference} — Stock: ${_selectedProduct!.stockActuel.toStringAsFixed(0)} ${_selectedProduct!.uniteMesure ?? ''}',
                                          style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
                                    ],
                                  )
                                : Text('Sélectionner un produit fini',
                                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.kTextHint)),
                          ),
                          const Icon(Icons.search, color: AppTheme.kTextHint),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'QUANTITÉ',
                  child: TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Ex: 5000',
                      suffixText: 'unités',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      final n = double.tryParse(v);
                      if (n == null || n <= 0) return 'Doit être > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'DATE PLANIFIÉE',
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _datePlanifiee = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.kInputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.kBorderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.kTextHint),
                          const SizedBox(width: 8),
                          Text(
                            _datePlanifiee != null
                                ? DateFormat('dd/MM/yyyy').format(_datePlanifiee!)
                                : 'Choisir une date',
                            style: TextStyle(
                              color: _datePlanifiee != null ? AppTheme.kTextPrimary : AppTheme.kTextHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: AppTheme.primaryButton,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Planifier', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickProduct(BuildContext context, List<Article> articles) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final searchCtrl = TextEditingController();
        String query = '';

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final filtered = query.isEmpty
                ? articles
                : articles.where((a) =>
                    a.designation.toLowerCase().contains(query.toLowerCase()) ||
                    a.reference.toLowerCase().contains(query.toLowerCase())).toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un produit fini…',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setDialogState(() => query = v),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final a = filtered[i];
                      return ListTile(
                        title: Text(a.designation),
                        subtitle: Text('${a.reference} — Stock: ${a.stockActuel.toStringAsFixed(0)} ${a.uniteMesure ?? ''}'),
                        onTap: () {
                          setState(() => _selectedProduct = a);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: AppTheme.kTextHint)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
