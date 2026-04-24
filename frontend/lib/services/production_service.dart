import 'api_client.dart';
import '../models/production_order.dart';

class ProductionService {
  static Future<List<ProductionOrder>> fetchAll() async {
    final res = await ApiClient.instance.get('/production/orders');
    return (res.data as List).map((e) => ProductionOrder.fromJson(e)).toList();
  }

  static Future<List<BomLine>> getBom(int produitFiniId) async {
    final res = await ApiClient.instance.get('/production/bom/$produitFiniId');
    return (res.data as List).map((e) => BomLine.fromJson(e)).toList();
  }

  static Future<ProductionOrder> plan({
    required int produitFiniId,
    required double quantite,
    required String datePlanifiee,
  }) async {
    final res = await ApiClient.instance.post('/production/orders/plan', data: {
      'produitFiniId': produitFiniId,
      'quantite': quantite,
      'datePlanifiee': datePlanifiee,
    });
    return ProductionOrder.fromJson(res.data);
  }

  static Future<ProductionOrder> launch(int id) async {
    final res = await ApiClient.instance.post('/production/orders/$id/launch');
    return ProductionOrder.fromJson(res.data);
  }

  static Future<ProductionOrder> complete(int id, double quantiteRealisee) async {
    final res = await ApiClient.instance.post('/production/orders/$id/complete', data: {
      'quantiteRealisee': quantiteRealisee,
    });
    return ProductionOrder.fromJson(res.data);
  }
}
