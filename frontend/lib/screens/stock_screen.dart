import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/article_provider.dart';
import '../models/article.dart';
import '../widgets/app_drawer.dart';
import 'stock_detail_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _filter = 'TOUS';
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Article> _filtered(List<Article> articles) {
    return articles.where((a) {
      final matchType = _filter == 'TOUS' || a.type == _filter;
      final matchAlerte = _filter == 'ALERTE' ? a.enAlerte : true;
      final matchSearch = _search.isEmpty ||
          a.reference.toLowerCase().contains(_search.toLowerCase()) ||
          a.designation.toLowerCase().contains(_search.toLowerCase());
      return (matchType || matchAlerte) && matchSearch;
    }).toList()
      ..sort((a, b) {
        if (a.enAlerte && !b.enAlerte) return -1;
        if (!a.enAlerte && b.enAlerte) return 1;
        return a.designation.compareTo(b.designation);
      });
  }

  static const _filters = [
    ('TOUS', 'Tous'),
    ('ALERTE', '🔴 Alertes'),
    ('MP', 'MP'),
    ('PSF', 'PSF'),
    ('PF', 'PF'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArticleProvider>();
    final articles = _filtered(provider.articles);
    final alertCount = provider.articles.where((a) => a.enAlerte).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stock', style: TextStyle(fontWeight: FontWeight.bold)),
            if (!provider.isLoading)
              Text('${provider.articles.length} articles · $alertCount en alerte',
                  style: TextStyle(
                      fontSize: 11,
                      color: alertCount > 0 ? Colors.red[600] : Colors.grey[500])),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<ArticleProvider>().load(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/stock'),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Rechercher un article…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _search = '';
                        }),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          // Filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final selected = _filter == f.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f.$2),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = f.$1),
                      selectedColor: f.$1 == 'ALERTE'
                          ? Colors.red.withOpacity(0.15)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      checkmarkColor: f.$1 == 'ALERTE'
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? (f.$1 == 'ALERTE'
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary)
                            : Colors.grey[700],
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Liste
          Expanded(child: _buildList(provider, articles)),
        ],
      ),
    );
  }

  Widget _buildList(ArticleProvider provider, List<Article> articles) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ArticleProvider>().load(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Aucun article', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ArticleProvider>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        itemBuilder: (ctx, i) => _StockCard(article: articles[i]),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final Article article;
  const _StockCard({required this.article});

  static const typeColors = {
    'MP': Color(0xFF3B82F6),
    'PSF': Color(0xFF8B5CF6),
    'PF': Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final typeColor = typeColors[article.type] ?? Colors.grey;
    final pct = article.stockMinimum > 0
        ? (article.stockActuel / article.stockMinimum).clamp(0.0, 2.0)
        : 1.0;
    final barColor = article.enAlerte ? Colors.red : Colors.green;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => StockDetailScreen(article: article))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: article.enAlerte ? Border.all(color: Colors.red[300]!, width: 1.5) : null,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(article.type,
                        style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(article.designation,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  if (article.enAlerte)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, size: 12, color: Colors.red[600]),
                          const SizedBox(width: 3),
                          Text('ALERTE', style: TextStyle(color: Colors.red[600], fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(article.reference, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              const SizedBox(height: 10),
              // Barre de stock
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stock : ${article.stockActuel.toStringAsFixed(2)} ${article.uniteMesure ?? ''}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: article.enAlerte ? Colors.red[700] : const Color(0xFF374151)),
                            ),
                            Text(
                              'Min : ${article.stockMinimum.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (pct / 2).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            color: barColor,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
