import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/article_provider.dart';
import '../providers/auth_provider.dart';
import '../services/sales_order_service.dart';
import '../services/client_service.dart';
import '../models/article.dart';
import '../models/client.dart';
import '../models/sales_order.dart';
import '../widgets/app_drawer.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/professional_dialogs.dart';
import '../constants/app_theme.dart';
import 'article_form_screen.dart';
import 'article_detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final _searchController = TextEditingController();
  final _cart = <Article, double>{};

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

  bool get _isClient {
    final auth = context.read<AuthProvider>();
    return auth.role == 'ROLE_CLIENT';
  }

  int get _cartCount => _cart.values.fold<int>(0, (s, q) => s + q.toInt());

  void _addToCart(Article article) {
    setState(() {
      _cart[article] = (_cart[article] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${article.designation} ajouté au panier'),
      duration: const Duration(seconds: 1),
      backgroundColor: AppTheme.kPrimaryTeal,
    ));
  }

  void _removeFromCart(Article article) {
    setState(() {
      if (_cart.containsKey(article)) {
        final qty = _cart[article]!;
        if (qty <= 1) {
          _cart.remove(article);
        } else {
          _cart[article] = qty - 1;
        }
      }
    });
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;
    try {
      final salesOrderService = context.read<SalesOrderService>();
      final clientService = context.read<ClientService>();

      final clients = await clientService.fetchAll();
      Client? client;
      if (clients.isNotEmpty) client = clients.first;

      final now = DateTime.now();
      final order = SalesOrder(
        dateCommande: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        client: client,
        lignes: _cart.entries.map((e) => SalesOrderLine(
          article: e.key,
          quantiteCommandee: e.value,
          prixUnitaireHT: e.key.prixUnitaire,
        )).toList(),
      );

      await salesOrderService.create(order);
      if (mounted) {
        setState(() => _cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Commande envoyée avec succès !'),
          backgroundColor: AppTheme.kSuccessGreen,
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Erreur lors de la création de la commande'),
          backgroundColor: AppTheme.kErrorRed,
        ));
      }
    }
  }

  void _showCart() {
    final total = _cart.entries.fold<double>(0, (s, e) => s + e.key.prixUnitaire * e.value);
    final fmt = NumberFormat.currency(locale: 'fr_TN', symbol: 'TND', decimalDigits: 3);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: AppTheme.kPrimaryTeal),
                const SizedBox(width: 8),
                Text('Panier (${_cartCount} article(s))', style: AppTheme.titleMedium),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            ..._cart.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(e.key.designation, style: AppTheme.bodyMedium)),
                  Text('x${e.value.toInt()}', style: AppTheme.bodyMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: Text(fmt.format(e.key.prixUnitaire * e.value), textAlign: TextAlign.right, style: AppTheme.titleSmall),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppTheme.kErrorRed),
                    onPressed: () { _removeFromCart(e.key); if (_cart.isEmpty) Navigator.pop(ctx); },
                  ),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTheme.titleMedium),
                Text(fmt.format(total), style: AppTheme.titleMedium.copyWith(color: AppTheme.kPrimaryTeal, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(ctx); _checkout(); },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmer la commande'),
                style: AppTheme.primaryButton,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArticleProvider>();
    final isClient = _isClient;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(BrandAppBar.heightFor(context)),
        child: BrandAppBar(
          title: isClient ? 'Catalogue Produits' : 'Articles',
          currentRoute: '/articles',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: () => context.read<ArticleProvider>().load(),
            ),
            if (isClient && _cart.isNotEmpty)
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: _showCart,
                  ),
                  Positioned(
                    right: 6, top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppTheme.kCtaOrange, shape: BoxShape.circle),
                      child: Text('$_cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      drawer: isClient ? null : const AppDrawer(currentRoute: '/articles'),
      floatingActionButton: isClient && _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showCart,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text('Panier ($_cartCount)'),
              backgroundColor: AppTheme.kCtaOrange,
            )
          : (isClient ? null : FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Nouvel article'),
            )),
      body: AppTheme.glassBackground(
        child: Column(
          children: [
            _SearchBar(controller: _searchController, provider: provider),
            _FilterChips(provider: provider),
            Expanded(child: _ArticleList(
              provider: provider,
              isClient: isClient,
              onAddToCart: _addToCart,
              cartQtys: _cart,
            )),
          ],
        ),
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
    return AppTheme.withGlass(
      radius: 0, blur: 16, opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextField(
          controller: controller,
          onChanged: provider.setSearch,
          decoration: InputDecoration(
            hintText: 'Rechercher par référence ou désignation…',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { controller.clear(); provider.setSearch(''); })
                : null,
            filled: true, fillColor: AppTheme.kInputFill,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
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
    return AppTheme.withGlass(
      radius: 0, blur: 16, opacity: 0.7,
      child: Container(
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
                  selectedColor: AppTheme.kPrimaryTeal.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.kPrimaryTeal,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: selected ? AppTheme.kPrimaryTeal : AppTheme.kTextSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ArticleList extends StatelessWidget {
  final ArticleProvider provider;
  final bool isClient;
  final void Function(Article) onAddToCart;
  final Map<Article, double> cartQtys;

  const _ArticleList({
    required this.provider,
    required this.isClient,
    required this.onAddToCart,
    required this.cartQtys,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.kTextHint),
          const SizedBox(height: 12),
          Text(provider.error!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.kTextSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => context.read<ArticleProvider>().load(), style: AppTheme.primaryButton, child: const Text('Réessayer')),
        ]),
      );
    }
    if (provider.articles.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isClient ? Icons.shopping_bag_outlined : Icons.inventory_2_outlined, size: 64, color: AppTheme.kBorderLight),
          const SizedBox(height: 16),
          Text(isClient ? 'Aucun produit disponible' : 'Aucun article trouvé', style: AppTheme.bodyMedium.copyWith(color: AppTheme.kTextSecondary)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ArticleProvider>().load(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.articles.length,
        itemBuilder: (ctx, i) => _ArticleCard(
          article: provider.articles[i],
          isClient: isClient,
          onAddToCart: () => onAddToCart(provider.articles[i]),
          cartQty: cartQtys[provider.articles[i]] ?? 0,
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final bool isClient;
  final VoidCallback onAddToCart;
  final double cartQty;

  const _ArticleCard({
    required this.article,
    required this.isClient,
    required this.onAddToCart,
    required this.cartQty,
  });

  static const typeColors = {
    'MP': AppTheme.kPrimaryTeal,
    'PSF': AppTheme.kCtaOrange,
    'PF': AppTheme.kPrimaryNavy,
  };

  @override
  Widget build(BuildContext context) {
    final color = typeColors[article.type] ?? AppTheme.kTextSecondary;
    final priceFmt = NumberFormat.currency(locale: 'fr_TN', symbol: 'TND', decimalDigits: 3);

    return GestureDetector(
      onTap: () {
        if (!isClient) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)));
        }
      },
      child: AppTheme.withGlass(
        radius: 12, blur: 16, opacity: 0.7,
        margin: const EdgeInsets.only(bottom: 10),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
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
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(article.type, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(article.designation, style: AppTheme.titleSmall.copyWith(fontSize: 14)),
                                ),
                                if (article.enAlerte && !isClient)
                                  const Icon(Icons.warning_amber, color: AppTheme.kWarningAmber, size: 16),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Réf: ${article.reference}', style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
                            const SizedBox(height: 2),
                            isClient
                                ? Text(priceFmt.format(article.prixUnitaire),
                                    style: AppTheme.titleSmall.copyWith(color: AppTheme.kPrimaryTeal, fontWeight: FontWeight.bold))
                                : Row(
                                    children: [
                                      Text('Stock: ${article.stockActuel} ${article.uniteMesure ?? ''}',
                                          style: TextStyle(fontSize: 12,
                                              color: article.enAlerte ? AppTheme.kErrorRed : AppTheme.kTextSecondary,
                                              fontWeight: article.enAlerte ? FontWeight.w600 : FontWeight.normal)),
                                      const SizedBox(width: 12),
                                      Text(priceFmt.format(article.prixUnitaire),
                                          style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextPrimary)),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      isClient
                          ? (cartQty > 0
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppTheme.kErrorRed),
                                      onPressed: onAddToCart,
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      padding: EdgeInsets.zero,
                                    ),
                                    Text('${cartQty.toInt()}', style: AppTheme.titleSmall.copyWith(color: AppTheme.kPrimaryTeal)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.kPrimaryTeal),
                                      onPressed: onAddToCart,
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                )
                              : IconButton(
                                  icon: const Icon(Icons.add_shopping_cart_outlined, size: 20, color: AppTheme.kPrimaryTeal),
                                  onPressed: onAddToCart,
                                  tooltip: 'Ajouter au panier',
                                ))
                          : PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppTheme.kTextSecondary),
                              onSelected: (val) => _onAction(context, val),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Modifier')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppTheme.kErrorRed), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: AppTheme.kErrorRed))])),
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

  void _onAction(BuildContext context, String action) {
    if (action == 'edit') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleFormScreen(article: article)));
    } else if (action == 'delete') {
      _confirmDelete(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    AppDialogs.showDelete(context: context, title: "Supprimer l'article ?", itemName: article.designation).then((confirmed) {
      if (confirmed == true) {
        context.read<ArticleProvider>().delete(article.id!).then((ok) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok ? 'Article archivé' : 'Erreur lors de la suppression'),
              backgroundColor: ok ? AppTheme.kSuccessGreen : AppTheme.kErrorRed,
            ));
          }
        });
      }
    });
  }
}
