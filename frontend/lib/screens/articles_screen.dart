import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/article_provider.dart';
import '../models/article.dart';
import '../widgets/app_drawer.dart';
import 'article_form_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArticleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Articles',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<ArticleProvider>().load(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/articles'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel article'),
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchController, provider: provider),
          _FilterChips(provider: provider),
          Expanded(child: _ArticleList(provider: provider)),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, [Article? article]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleFormScreen(article: article),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ArticleProvider provider;

  const _SearchBar({required this.controller, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: provider.setSearch,
        decoration: InputDecoration(
          hintText: 'Rechercher par référence ou désignation…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    provider.setSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final ArticleProvider provider;
  const _FilterChips({required this.provider});

  static const filters = [
    ('TOUS', 'Tous'),
    ('MP', 'Matières Premières'),
    ('PSF', 'Semi-Finis'),
    ('PF', 'Produits Finis'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final selected = provider.filterType == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f.$2),
                selected: selected,
                onSelected: (_) => provider.setFilter(f.$1),
                selectedColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.15),
                checkmarkColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[700],
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ArticleList extends StatelessWidget {
  final ArticleProvider provider;
  const _ArticleList({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(provider.error!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ArticleProvider>().load(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (provider.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Aucun article trouvé',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ArticleProvider>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.articles.length,
        itemBuilder: (ctx, i) =>
            _ArticleCard(article: provider.articles[i]),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  const _ArticleCard({required this.article});

  static const typeColors = {
    'MP': Color(0xFF3B82F6),
    'PSF': Color(0xFF8B5CF6),
    'PF': Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final color = typeColors[article.type] ?? Colors.grey;
    final priceFmt = NumberFormat.currency(
        locale: 'fr_TN', symbol: 'TND', decimalDigits: 3);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
        border: article.enAlerte
            ? Border.all(color: Colors.red[300]!, width: 1.5)
            : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              article.type,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                article.designation,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            if (article.enAlerte)
              const Icon(Icons.warning_amber,
                  color: Colors.orange, size: 16),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Réf: ${article.reference}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  'Stock: ${article.stockActuel} ${article.uniteMesure ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: article.enAlerte
                        ? Colors.red[600]
                        : Colors.grey[600],
                    fontWeight: article.enAlerte
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  priceFmt.format(article.prixUnitaire),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF374151)),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (val) => _onAction(context, val),
          itemBuilder: (_) => [
            const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer',
                      style: TextStyle(color: Colors.red)),
                ])),
          ],
        ),
      ),
    );
  }

  void _onAction(BuildContext context, String action) {
    if (action == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ArticleFormScreen(article: article)),
      );
    } else if (action == 'delete') {
      _confirmDelete(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'article ?'),
        content: Text(
            'Voulez-vous vraiment archiver "${article.designation}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await context
                  .read<ArticleProvider>()
                  .delete(article.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? 'Article archivé'
                      : 'Erreur lors de la suppression'),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ));
              }
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
