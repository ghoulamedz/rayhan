import 'api_client.dart';
import '../models/sales_order.dart';

class SalesOrderService {
  static Future<List<SalesOrder>> fetchAll() async {
    final res = await ApiClient.instance.get('/sales-orders');
    return (res.data as List).map((e) => SalesOrder.fromJson(e)).toList();
  }

  static Future<SalesOrder> create(SalesOrder order) async {
    final res = await ApiClient.instance.post('/sales-orders', data: order.toJson());
    return SalesOrder.fromJson(res.data);
  }

  static Future<void> deliver(int orderId, Map<String, dynamic> bonLivraison) async {
    await ApiClient.instance.post('/sales-orders/$orderId/deliver', data: bonLivraison);
  }
}
