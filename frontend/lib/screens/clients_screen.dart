import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clients_provider.dart';
import '../models/client.dart';
import '../widgets/app_drawer.dart';
import '../widgets/brand_app_bar.dart';
import '../constants/app_theme.dart';
import 'client_form_screen.dart';
import 'client_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientsProvider>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(BrandAppBar.heightFor(context)),
        child: BrandAppBar(
          title: 'Clients',
          subtitle: !provider.isLoading
              ? '${provider.clients.length} client(s)'
              : null,
          currentRoute: '/clients',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: () => context.read<ClientsProvider>().load(),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/clients'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ClientFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau client'),
      ),
      body: AppTheme.glassBackground(
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(ClientsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.kTextHint),
            const SizedBox(height: 12),
            Text(provider.error!,
                style: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.kTextSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ClientsProvider>().load(),
              style: AppTheme.primaryButton,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (provider.clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_outlined,
                size: 64, color: AppTheme.kBorderLight),
            const SizedBox(height: 16),
            Text('Aucun client',
                style: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.kTextSecondary)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ClientFormScreen())),
              child: const Text('Créer le premier client'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ClientsProvider>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.clients.length,
        itemBuilder: (ctx, i) => _ClientCard(client: provider.clients[i]),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ClientDetailScreen(client: client)),
      ),
      child: AppTheme.withGlass(
        radius: 12,
        blur: 16,
        opacity: 0.7,
        margin: const EdgeInsets.only(bottom: 10),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: client.actif
                      ? AppTheme.kSuccessGreen
                      : AppTheme.kTextHint,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(client.raisonSociale,
                                style: AppTheme.titleSmall.copyWith(fontSize: 15)),
                          ),
                          if (client.typeClient != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.kPrimaryOrange
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(client.typeClient!,
                                  style: TextStyle(
                                      color: AppTheme.kPrimaryOrange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (client.matriculeFiscal != null)
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined,
                                size: 14, color: AppTheme.kTextSecondary),
                            const SizedBox(width: 4),
                            Text('MF: ${client.matriculeFiscal}',
                                style: AppTheme.bodySmall
                                    .copyWith(fontSize: 12)),
                            const SizedBox(width: 16),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 13, color: AppTheme.kTextSecondary),
                          const SizedBox(width: 4),
                          Text(client.telephone ?? '—',
                              style: AppTheme.bodySmall
                                  .copyWith(color: AppTheme.kTextSecondary)),
                          const SizedBox(width: 16),
                          const Icon(Icons.email_outlined,
                              size: 13, color: AppTheme.kTextSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(client.email ?? '—',
                                style: AppTheme.bodySmall
                                    .copyWith(color: AppTheme.kTextSecondary)),
                          ),
                        ],
                      ),
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
