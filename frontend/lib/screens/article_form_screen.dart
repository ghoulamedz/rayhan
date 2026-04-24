import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/article_provider.dart';

class ArticleFormScreen extends StatefulWidget {
  final Article? article;
  const ArticleFormScreen({super.key, this.article});

  @override
  State<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _refCtrl;
  late final TextEditingController _desCtrl;
  late final TextEditingController _uniteCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _stockMinCtrl;
  late final TextEditingController _stockActuelCtrl;
  late String _type;
  bool _saving = false;

  bool get _isEdit => widget.article != null;

  @override
  void initState() {
    super.initState();
    final a = widget.article;
    _refCtrl = TextEditingController(text: a?.reference ?? '');
    _desCtrl = TextEditingController(text: a?.designation ?? '');
    _uniteCtrl = TextEditingController(text: a?.uniteMesure ?? '');
    _prixCtrl = TextEditingController(
        text: a != null ? a.prixUnitaire.toString() : '');
    _stockMinCtrl = TextEditingController(
        text: a != null ? a.stockMinimum.toString() : '');
    _stockActuelCtrl = TextEditingController(
        text: a != null ? a.stockActuel.toString() : '0');
    _type = a?.type ?? 'MP';
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _desCtrl.dispose();
    _uniteCtrl.dispose();
    _prixCtrl.dispose();
    _stockMinCtrl.dispose();
    _stockActuelCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final article = Article(
      id: widget.article?.id,
      reference: _refCtrl.text.trim(),
      designation: _desCtrl.text.trim(),
      type: _type,
      uniteMesure: _uniteCtrl.text.trim().isEmpty ? null : _uniteCtrl.text.trim(),
      prixUnitaire: double.tryParse(_prixCtrl.text) ?? 0,
      stockMinimum: double.tryParse(_stockMinCtrl.text) ?? 0,
      stockActuel: double.tryParse(_stockActuelCtrl.text) ?? 0,
    );

    final provider = context.read<ArticleProvider>();
    final ok = _isEdit
        ? await provider.update(article.id!, article)
        : await provider.create(article);

    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Article modifié' : 'Article créé'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur — vérifiez les champs (référence déjà utilisée ?)'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEdit ? 'Modifier l\'article' : 'Nouvel article',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Card(
                title: 'Identification',
                children: [
                  _Field(
                    label: 'Référence',
                    controller: _refCtrl,
                    hint: 'Ex: MP-001',
                    enabled: !_isEdit,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Obligatoire'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Désignation',
                    controller: _desCtrl,
                    hint: 'Ex: Granulés PEHD',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Obligatoire'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: _inputDeco('Type d\'article'),
                    items: const [
                      DropdownMenuItem(value: 'MP', child: Text('Matière Première (MP)')),
                      DropdownMenuItem(value: 'PSF', child: Text('Produit Semi-Fini (PSF)')),
                      DropdownMenuItem(value: 'PF', child: Text('Produit Fini (PF)')),
                    ],
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Unité & Prix',
                children: [
                  _Field(
                    label: 'Unité de mesure',
                    controller: _uniteCtrl,
                    hint: 'kg, unité, rouleau, m…',
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Prix unitaire (TND)',
                    controller: _prixCtrl,
                    hint: '0.000',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (double.tryParse(v) == null) return 'Nombre invalide';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Stock',
                children: [
                  _Field(
                    label: 'Stock actuel',
                    controller: _stockActuelCtrl,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (double.tryParse(v) == null) return 'Nombre invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Seuil minimum (alerte)',
                    controller: _stockMinCtrl,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (double.tryParse(v) == null) return 'Nombre invalide';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
                      : Text(
                          _isEdit ? 'Enregistrer les modifications' : 'Créer l\'article',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF6B7280))),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.enabled = true,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: _inputDeco(label).copyWith(hintText: hint),
      validator: validator,
    );
  }
}

InputDecoration _inputDeco(String label) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
