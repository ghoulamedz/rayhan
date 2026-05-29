import 'package:flutter/material.dart';
import '../models/sales_order.dart';
import '../services/sales_order_service.dart';

class VentesProvider extends ChangeNotifier {
  final SalesOrderService salesOrderService;

  VentesProvider({
    required this.salesOrderService,
  });

  List<SalesOrder> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<SalesOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await salesOrderService.fetchAll();
    } catch (_) {
      _error = 'Impossible de charger les commandes.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createOrder(SalesOrder order) async {
    try {
      final created = await salesOrderService.create(order);
      _orders.insert(0, created);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().contains('Stock insuffisant')
          ? 'Stock insuffisant pour un ou plusieurs articles'
          : 'Erreur lors de la création de la commande';
    }
  }

  Future<String?> deliver(int orderId, List<SalesOrderLine> lignes) async {
    try {
      final payload = {
        'dateLivraison': DateTime.now().toIso8601String().substring(0, 10),
        'lignes': lignes.map((l) => {
          'salesOrderLine': {'id': l.id},
          'article': {'id': l.article!.id},
          'quantiteLivree': l.quantiteCommandee,
        }).toList(),
      };
      await salesOrderService.deliver(orderId, payload);
      await load();
      return null;
    } catch (e) {
      return 'Erreur lors de la livraison';
    }
  }
}