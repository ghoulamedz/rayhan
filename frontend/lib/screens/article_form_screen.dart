import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/article_provider.dart';
import '../constants/app_theme.dart';

class _BomEntry {
  Article? composant;
  final TextEditingController qtyCtrl;
  final TextEditingController unitCtrl;

  _BomEntry({this.composant, String? qty, String? unit})
      : qtyCtrl = TextEditingController(text: qty ?? ''),
        unitCtrl = TextEditingController(text: unit ?? '');

  void dispose() {
    qtyCtrl.dispose();
    unitCtrl.dispose();
  }
}

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
  final List<_BomEntry> _bomEntries = [];

  bool get _isEdit => widget.article != null;
  bool get _hasBom => _type == 'PF' || _type == 'PSF';

  @override
  void initState() {
    super.initState();
    final a = widget.article;
    _refCtrl = TextEditingController(text: a?.reference ?? '');
    _desCtrl = TextEditingController(text: a?.designation ?? '');
    _uniteCtrl = TextEditingController(text: a?.uniteMesure ?? '');
    _prixCtrl =
        TextEditingController(text: a != null ? a.prixUnitaire.toString() : '');
    _stockMinCtrl =
        TextEditingController(text: a != null ? a.stockMinimum.toString() : '');
    _stockActuelCtrl =
        TextEditingController(text: a != null ? a.stockActuel.toString() : '0');
    _type = a?.type ?? 'MP';

    _loadBomLines();
  }

  Future<void> _loadBomLines() async {
    if (!_isEdit) return;
    final provider = context.read<ArticleProvider>();
    await provider.fetchBomLines(widget.article!.id!);
    if (!mounted) return;
    setState(() {
      _bomEntries.clear();
      for (final bl in provider.selectedBomLines) {
        _bomEntries.add(_BomEntry(
          composant: bl.composant,
          qty: bl.quantiteParUnite.toString(),
          unit: bl.uniteMesure,
        ));
      }
    });
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _desCtrl.dispose();
    _uniteCtrl.dispose();
    _prixCtrl.dispose();
    _stockMinCtrl.dispose();
    _stockActuelCtrl.dispose();
    for (final e in _bomEntries) {
      e.dispose();
    }
    super.dispose();
  }

  void _addBomRow({Article? composant, String? qty, String? unit}) {
    setState(() {
      _bomEntries.add(_BomEntry(composant: composant, qty: qty, unit: unit));
    });
  }

  void _removeBomRow(int index) {
    setState(() {
      _bomEntries[index].dispose();
      _bomEntries.removeAt(index);
    });
  }

  List<Map<String, dynamic>> _buildBomLines() {
    return _bomEntries
        .where((e) => e.composant != null)
        .map((e) => {
              'composantId': e.composant!.id,
              'quantiteParUnite': double.tryParse(e.qtyCtrl.text) ?? 0,
              'uniteMesure': e.unitCtrl.text.trim(),
            })
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_bomNeededButEmpty()) return;
    setState(() => _saving = true);

    final article = Article(
      id: widget.article?.id,
      reference: _refCtrl.text.trim(),
      designation: _desCtrl.text.trim(),
      type: _type,
      uniteMesure:
          _uniteCtrl.text.trim().isEmpty ? null : _uniteCtrl.text.trim(),
      prixUnitaire: double.tryParse(_prixCtrl.text) ?? 0,
      stockMinimum: double.tryParse(_stockMinCtrl.text) ?? 0,
      stockActuel: double.tryParse(_stockActuelCtrl.text) ?? 0,
    );

    final bomLines = _buildBomLines();
    final provider = context.read<ArticleProvider>();
    final ok = _isEdit
        ? await provider.update(article.id!, article, bomLines: bomLines)
        : await provider.create(article, bomLines: bomLines);

    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Article modifié' : 'Article créé'),
          backgroundColor: AppTheme.kSuccessGreen,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Erreur — vérifiez les champs (référence déjà utilisée ?)'),
          backgroundColor: AppTheme.kErrorRed,
        ));
      }
    }
  }

  bool _bomNeededButEmpty() {
    if (!_hasBom) return false;
    if (_buildBomLines().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Un produit fini ou semi-fini doit avoir au moins un composant dans la nomenclature'),
        backgroundColor: AppTheme.kErrorRed,
      ));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final articles = context.watch<ArticleProvider>().articles;
    final composants = articles.where((a) => a.type == 'MP' || a.type == 'PSF').toList();

    return Scaffold(
      backgroundColor: AppTheme.kSurface,
      appBar: AppBar(
        title: Text(_isEdit ? "Modifier l'article" : 'Nouvel article'),
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
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Obligatoire' : null,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Désignation',
                    controller: _desCtrl,
                    hint: 'Ex: Granulés PEHD',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Obligatoire' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: "Type d'article"),
                    items: const [
                      DropdownMenuItem(
                          value: 'MP',
                          child: Text('Matière Première (MP)')),
                      DropdownMenuItem(
                          value: 'PSF',
                          child: Text('Produit Semi-Fini (PSF)')),
                      DropdownMenuItem(
                          value: 'PF',
                          child: Text('Produit Fini (PF)')),
                    ],
                    onChanged: (v) {
                      setState(() => _type = v!);
                      if (_hasBom && _bomEntries.isEmpty) {
                        _addBomRow();
                      }
                    },
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
              if (_hasBom) ...[
                const SizedBox(height: 16),
                _BomCard(
                  entries: _bomEntries,
                  composants: composants,
                  onAdd: _addBomRow,
                  onRemove: _removeBomRow,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: AppTheme.primaryButton,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _isEdit
                              ? 'Enregistrer les modifications'
                              : "Créer l'article",
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

class _BomCard extends StatelessWidget {
  final List<_BomEntry> entries;
  final List<Article> composants;
  final void Function({Article? composant, String? qty, String? unit}) onAdd;
  final void Function(int index) onRemove;

  const _BomCard({
    required this.entries,
    required this.composants,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Composition (Nomenclature)',
      children: [
        ...List.generate(entries.length, (i) {
          final e = entries[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _ComposantDropdown(
                    value: e.composant,
                    composants: composants,
                    onChanged: (a) => e.composant = a,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: e.qtyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Qté/unité',
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.kInputFill,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: e.unitCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Unité',
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.kInputFill,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppTheme.kErrorRed, size: 22),
                  onPressed: entries.length > 1
                      ? () => onRemove(i)
                      : null,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () => onAdd(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Ajouter un composant'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.kPrimary,
            side: const BorderSide(color: AppTheme.kPrimary),
          ),
        ),
        if (composants.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Aucune matière première ou PSF disponible. Créez d\'abord des articles MP ou PSF.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary),
            ),
          ),
      ],
    );
  }
}

class _ComposantDropdown extends StatelessWidget {
  final Article? value;
  final List<Article> composants;
  final ValueChanged<Article?> onChanged;

  const _ComposantDropdown({
    required this.value,
    required this.composants,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Article>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Composant',
        isDense: true,
        filled: true,
        fillColor: AppTheme.kInputFill,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      hint: const Text('Sélectionner', style: TextStyle(fontSize: 13)),
      items: composants.map((a) {
        return DropdownMenuItem(
          value: a,
          child: Text(
            '${a.reference} - ${a.designation}',
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
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
      decoration: AppTheme.cardDecorationMd,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.kTextSecondary)),
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppTheme.kInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: validator,
    );
  }
}
