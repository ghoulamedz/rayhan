import 'package:flutter/material.dart';
import '../models/sales_order.dart';
import '../models/client.dart';
import '../services/sales_order_service.dart';
import '../services/client_service.dart';
import '../mock/mock_services.dart';
import '../mock/mock_config.dart';

class VentesProvider extends ChangeNotifier {
  List<SalesOrder> _orders = [];
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<SalesOrder> get orders => _orders;
  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (MockConfig.useMock) {
        final results = await Future.wait([
          MockSalesOrderService.fetchAll(),
          MockClientService.fetchAll(),
        ]);
        _orders = results[0] as List<SalesOrder>;
        _clients = results[1] as List<Client>;
      } else {
        final results = await Future.wait([
          SalesOrderService.fetchAll(),
          ClientService.fetchAll(),
        ]);
        _orders = results[0] as List<SalesOrder>;
        _clients = results[1] as List<Client>;
      }
    } catch (_) {
      _error = 'Impossible de charger les commandes.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createOrder(SalesOrder order) async {
    try {
      final SalesOrder created;
      if (MockConfig.useMock) {
        created = await MockSalesOrderService.create(order);
      } else {
        created = await SalesOrderService.create(order);
      }
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
      if (MockConfig.useMock) {
        await MockSalesOrderService.deliver(orderId, payload);
      } else {
        await SalesOrderService.deliver(orderId, payload);
      }
      await load();
      return null;
    } catch (e) {
      return 'Erreur lors de la livraison';
    }
  }
}
