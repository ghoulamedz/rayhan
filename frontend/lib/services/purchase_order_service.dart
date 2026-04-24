import 'api_client.dart';
import '../models/purchase_order.dart';

class PurchaseOrderService {
  static Future<List<PurchaseOrder>> fetchAll() async {
    final res = await ApiClient.instance.get('/purchase-orders');
    return (res.data as List).map((e) => PurchaseOrder.fromJson(e)).toList();
  }

  static Future<PurchaseOrder> create(PurchaseOrder order) async {
    final res = await ApiClient.instance.post('/purchase-orders', data: order.toJson());
    return PurchaseOrder.fromJson(res.data);
  }

  static Future<void> receive(int orderId, Map<String, dynamic> reception) async {
    await ApiClient.instance.post('/purchase-orders/$orderId/receive', data: reception);
  }
}
