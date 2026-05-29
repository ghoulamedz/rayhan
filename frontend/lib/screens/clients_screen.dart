import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/client_service.dart';
import '../models/client.dart';
import '../widgets/app_drawer.dart';
import '../widgets/brand_app_bar.dart';
import '../constants/app_theme.dart';
import 'client_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  List<Client> _clients = [];
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
      final service = context.read<ClientService>();
      _clients = await service.fetchAll();
    } catch (_) {
      _error = 'Impossible de charger les clients.';
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  List<Client> get _filtered => _clients.where((c) =>
    _search.isEmpty ||
    c.raisonSociale.toLowerCase().contains(_search.toLowerCase()) ||
    (c.matriculeFiscal?.contains(_search) ?? false)).toList();

  void _openForm([Client? client]) {
    final isEdit = client != null;
    final ctrlRaison = TextEditingController(text: client?.raisonSociale ?? '');
    final ctrlMf = TextEditingController(text: client?.matriculeFiscal ?? '');
    final ctrlTel = TextEditingController(text: client?.telephone ?? '');
    final ctrlEmail = TextEditingController(text: client?.email ?? '');
    final ctrlAdresse = TextEditingController(text: client?.adresse ?? '');
    final ctrlVille = TextEditingController(text: client?.ville ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(isEdit ? Icons.edit_outlined : Icons.person_add_outlined, size: 20, color: AppTheme.kPrimaryTeal),
          const SizedBox(width: 8),
          Text(isEdit ? 'Modifier le client' : 'Nouveau client', style: AppTheme.titleSmall),
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
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              if (ctrlRaison.text.trim().isEmpty) return;
              final updated = Client(
                id: client?.id,
                raisonSociale: ctrlRaison.text.trim(),
                matriculeFiscal: ctrlMf.text.trim().isEmpty ? null : ctrlMf.text.trim(),
                telephone: ctrlTel.text.trim().isEmpty ? null : ctrlTel.text.trim(),
                email: ctrlEmail.text.trim().isEmpty ? null : ctrlEmail.text.trim(),
                adresse: ctrlAdresse.text.trim().isEmpty ? null : ctrlAdresse.text.trim(),
                ville: ctrlVille.text.trim().isEmpty ? null : ctrlVille.text.trim(),
                actif: client?.actif ?? true,
              );
              try {
                final service = context.read<ClientService>();
                if (isEdit && client!.id != null) {
                  await service.update(client.id!, updated);
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
          title: 'Clients',
          subtitle: _loading ? null : '${_clients.length} client(s)',
          currentRoute: '/clients',
          actions: [
            IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _load),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/clients'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau client'),
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
                hintText: 'Rechercher un client…',
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

  Widget _buildBody(List<Client> filtered) {
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
          Icon(Icons.people_outline, size: 64, color: AppTheme.kBorderLight),
          const SizedBox(height: 16),
          Text('Aucun client trouvé', style: AppTheme.bodyMedium.copyWith(color: AppTheme.kTextSecondary)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => _ClientCard(
          client: filtered[i],
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientDetailScreen(client: filtered[i]))),
          onEdit: () => _openForm(filtered[i]),
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  const _ClientCard({required this.client, required this.onTap, required this.onEdit});

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
                  color: AppTheme.kPrimaryTeal,
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
                          color: AppTheme.kPrimaryTeal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.business_outlined, color: AppTheme.kPrimaryTeal, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(client.raisonSociale, style: AppTheme.titleSmall.copyWith(fontSize: 14)),
                            const SizedBox(height: 4),
                            if (client.matriculeFiscal != null)
                              Text('MF: ${client.matriculeFiscal}', style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
                            if (client.telephone != null)
                              Text(client.telephone!, style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
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
