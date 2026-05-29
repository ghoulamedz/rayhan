import 'package:flutter/material.dart';
import '../models/purchase_order.dart';
import '../services/purchase_order_service.dart';

class AchatsProvider extends ChangeNotifier {
  final PurchaseOrderService purchaseOrderService;

  AchatsProvider({
    required this.purchaseOrderService,
  });

  List<PurchaseOrder> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<PurchaseOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await purchaseOrderService.fetchAll();
    } catch (_) {
      _error = 'Impossible de charger les commandes achats.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createOrder(PurchaseOrder order) async {
    try {
      final created = await purchaseOrderService.create(order);
      _orders.insert(0, created);
      notifyListeners();
      return null;
    } catch (_) {
      return 'Erreur lors de la création de la commande';
    }
  }

  Future<String?> receive(int orderId, List<PurchaseOrderLine> lignes) async {
    try {
      final payload = {
        'dateReception': DateTime.now().toIso8601String().substring(0, 10),
        'lignes': lignes.map((l) => {
          'purchaseOrderLine': {'id': l.id},
          'article': {'id': l.article!.id},
          'quantiteRecue': l.quantiteCommandee,
        }).toList(),
      };
      await purchaseOrderService.receive(orderId, payload);
      await load();
      return null;
    } catch (_) {
      return 'Erreur lors de la réception';
    }
  }
}