import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fournisseur_service.dart';
import '../models/fournisseur.dart';
import '../widgets/app_drawer.dart';
import '../widgets/brand_app_bar.dart';
import '../constants/app_theme.dart';
import 'fournisseur_detail_screen.dart';

class FournisseursScreen extends StatefulWidget {
  const FournisseursScreen({super.key});

  @override
  State<FournisseursScreen> createState() => _FournisseursScreenState();
}

class _FournisseursScreenState extends State<FournisseursScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  List<Fournisseur> _fournisseurs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final service = context.read<FournisseurService>();
      _fournisseurs = await service.fetchAll();
    } catch (_) {
      _error = 'Impossible de charger les fournisseurs.';
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  List<Fournisseur> get _filtered => _fournisseurs.where((f) =>
    _search.isEmpty ||
    f.raisonSociale.toLowerCase().contains(_search.toLowerCase()) ||
    (f.matriculeFiscal?.contains(_search) ?? false)).toList();

  void _openForm([Fournisseur? fournisseur]) {
    final isEdit = fournisseur != null;
    final ctrlRaison = TextEditingController(text: fournisseur?.raisonSociale ?? '');
    final ctrlMf = TextEditingController(text: fournisseur?.matriculeFiscal ?? '');
    final ctrlTel = TextEditingController(text: fournisseur?.telephone ?? '');
    final ctrlEmail = TextEditingController(text: fournisseur?.email ?? '');
    final ctrlAdresse = TextEditingController(text: fournisseur?.adresse ?? '');
    final ctrlVille = TextEditingController(text: fournisseur?.ville ?? '');
    final ctrlPays = TextEditingController(text: fournisseur?.pays ?? 'Tunisie');
    final ctrlCategorie = TextEditingController(text: fournisseur?.categorieProduit ?? '');
    final ctrlPaiement = TextEditingController(text: fournisseur?.modePaiement ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(isEdit ? Icons.edit_outlined : Icons.add_business_outlined, size: 20, color: AppTheme.kPrimaryTeal),
          const SizedBox(width: 8),
          Text(isEdit ? 'Modifier le fournisseur' : 'Nouveau fournisseur', style: AppTheme.titleSmall),
        ]),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: ctrlRaison, decoration: const InputDecoration(labelText: 'Raison sociale *'), textCapitalization: TextCapitalization.words),
                const SizedBox(height: 12),
                TextField(controller: ctrlMf, decoration: const InputDecoration(labelText: 'Matricule fiscal')),
                const SizedBox(height: 12),
                TextField(controller: ctrlTel, decoration: const InputDecoration(labelText: 'Téléphone'), keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                TextField(controller: ctrlEmail, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                TextField(controller: ctrlAdresse, decoration: const InputDecoration(labelText: 'Adresse'), textCapitalization: TextCapitalization.sentences),
                const SizedBox(height: 12),
                TextField(controller: ctrlVille, decoration: const InputDecoration(labelText: 'Ville'), textCapitalization: TextCapitalization.words),
                const SizedBox(height: 12),
                TextField(controller: ctrlPays, decoration: const InputDecoration(labelText: 'Pays'), textCapitalization: TextCapitalization.words),
                const SizedBox(height: 12),
                TextField(controller: ctrlCategorie, decoration: const InputDecoration(labelText: 'Catégorie produit'), textCapitalization: TextCapitalization.sentences),
                const SizedBox(height: 12),
                TextField(controller: ctrlPaiement, decoration: const InputDecoration(labelText: 'Mode de paiement'), textCapitalization: TextCapitalization.sentences),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              if (ctrlRaison.text.trim().isEmpty) return;
              final updated = Fournisseur(
                id: fournisseur?.id,
                raisonSociale: ctrlRaison.text.trim(),
                matriculeFiscal: ctrlMf.text.trim().isEmpty ? null : ctrlMf.text.trim(),
                telephone: ctrlTel.text.trim().isEmpty ? null : ctrlTel.text.trim(),
                email: ctrlEmail.text.trim().isEmpty ? null : ctrlEmail.text.trim(),
                adresse: ctrlAdresse.text.trim().isEmpty ? null : ctrlAdresse.text.trim(),
                ville: ctrlVille.text.trim().isEmpty ? null : ctrlVille.text.trim(),
                pays: ctrlPays.text.trim().isEmpty ? 'Tunisie' : ctrlPays.text.trim(),
                categorieProduit: ctrlCategorie.text.trim().isEmpty ? null : ctrlCategorie.text.trim(),
                modePaiement: ctrlPaiement.text.trim().isEmpty ? null : ctrlPaiement.text.trim(),
                actif: fournisseur?.actif ?? true,
              );
              try {
                final service = context.read<FournisseurService>();
                if (isEdit && fournisseur!.id != null) {
                  await service.update(fournisseur.id!, updated);
                } else {
                  await service.create(updated);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              } catch (_) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'enregistrement')));
              }
            },
            child: Text(isEdit ? 'Enregistrer' : 'Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(BrandAppBar.heightFor(context)),
        child: BrandAppBar(
          title: 'Fournisseurs',
          subtitle: _loading ? null : '${_fournisseurs.length} fournisseur(s)',
          currentRoute: '/fournisseurs',
          actions: [
            IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _load),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/fournisseurs'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau fournisseur'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: AppTheme.kBackgroundLight,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Rechercher un fournisseur…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); })
                    : null,
                filled: true, fillColor: AppTheme.kInputFill,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(child: _buildBody(filtered)),
        ],
      ),
    );
  }

  Widget _buildBody(List<Fournisseur> filtered) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.kTextHint),
          const SizedBox(height: 12),
          Text(_error!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.kTextSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, style: AppTheme.primaryButton, child: const Text('Réessayer')),
        ]),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.business_outlined, size: 64, color: AppTheme.kBorderLight),
          const SizedBox(height: 16),
          Text('Aucun fournisseur trouvé', style: AppTheme.bodyMedium.copyWith(color: AppTheme.kTextSecondary)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => _FournisseurCard(
          fournisseur: filtered[i],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FournisseurDetailScreen(fournisseur: filtered[i]))),
          onEdit: () => _openForm(filtered[i]),
        ),
      ),
    );
  }
}

class _FournisseurCard extends StatelessWidget {
  final Fournisseur fournisseur;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  const _FournisseurCard({required this.fournisseur, required this.onTap, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppTheme.withGlass(
        radius: 12, blur: 16, opacity: 0.7,
        margin: const EdgeInsets.only(bottom: 10),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: AppTheme.kCtaOrange,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.kCtaOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_shipping_outlined, color: AppTheme.kCtaOrange, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(fournisseur.raisonSociale, style: AppTheme.titleSmall.copyWith(fontSize: 14)),
                            const SizedBox(height: 4),
                            if (fournisseur.matriculeFiscal != null)
                              Text('MF: ${fournisseur.matriculeFiscal}', style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
                            if (fournisseur.ville != null)
                              Text('${fournisseur.ville}${fournisseur.pays != null ? ', ${fournisseur.pays}' : ''}', style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.kTextSecondary),
                        onPressed: onEdit,
                      ),
                      const Icon(Icons.chevron_right, color: AppTheme.kTextHint),
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
