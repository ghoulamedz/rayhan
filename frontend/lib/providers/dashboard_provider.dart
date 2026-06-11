import 'package:flutter/material.dart';
import '../models/dashboard_kpi.dart';
import '../models/suggestion.dart';
import '../models/trending_product.dart';
import '../models/article.dart';
import '../models/sales_order.dart';
import '../models/purchase_order.dart';
import '../models/production_order.dart';
import '../services/dashboard_service.dart';
import '../services/suggestion_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService dashboardService;

  DashboardProvider({required this.dashboardService});

  DashboardKpi? _kpi;
  List<Suggestion> _suggestions = [];
  List<TrendingProduct> _trendingProducts = [];
  bool _isLoading = false;
  bool _suggestionsLoading = false;
  bool _trendingLoading = false;
  String? _error;

  DashboardKpi? get kpi => _kpi;
  List<Suggestion> get suggestions => _suggestions;
  List<TrendingProduct> get trendingProducts => _trendingProducts;
  bool get isLoading => _isLoading;
  bool get suggestionsLoading => _suggestionsLoading;
  bool get trendingLoading => _trendingLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _kpi = await dashboardService.fetchKpis();
    } catch (_) {
      _error = 'Impossible de charger les données. Vérifiez la connexion.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSuggestions({
    required List<Article> articles,
    required List<SalesOrder> salesOrders,
    required List<PurchaseOrder> purchaseOrders,
    required List<ProductionOrder> productionOrders,
  }) async {
    if (_kpi == null) return;
    _suggestionsLoading = true;
    notifyListeners();
    try {
      _suggestions = await SuggestionService.generate(
        kpis: _kpi!,
        articles: articles,
        salesOrders: salesOrders,
        purchaseOrders: purchaseOrders,
        productionOrders: productionOrders,
      );
    } catch (_) {
      _suggestions = [];
    } finally {
      _suggestionsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrendingProducts() async {
    _trendingLoading = true;
    notifyListeners();
    try {
      _trendingProducts = await dashboardService.fetchTrendingProducts();
    } catch (_) {
      _trendingProducts = [];
    } finally {
      _trendingLoading = false;
      notifyListeners();
    }
  }

  void dismissSuggestion(int id) {
    _suggestions.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
