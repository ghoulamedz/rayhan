import 'api_client.dart';
import '../models/sales_order.dart';

abstract class SalesOrderService {
  Future<List<SalesOrder>> fetchAll();
  Future<SalesOrder> create(SalesOrder order);
  Future<void> deliver(int orderId, Map<String, dynamic> bonLivraison);
}

class RealSalesOrderService implements SalesOrderService {
  @override
  Future<List<SalesOrder>> fetchAll() async {
    final res = await ApiClient.instance.get('/sales-orders');
    return (res.data as List).map((e) => SalesOrder.fromJson(e)).toList();
  }

  @override
  Future<SalesOrder> create(SalesOrder order) async {
    final res = await ApiClient.instance.post('/sales-orders', data: order.toJson());
    return SalesOrder.fromJson(res.data);
  }

  @override
  Future<void> deliver(int orderId, Map<String, dynamic> bonLivraison) async {
    await ApiClient.instance.post('/sales-orders/$orderId/deliver', data: bonLivraison);
  }
}
