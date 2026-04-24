import 'api_client.dart';
import '../models/stock_movement.dart';

class StockService {
  static Future<List<StockMovement>> getHistorique(int articleId) async {
    final res = await ApiClient.instance.get('/stock/historique/$articleId');
    return (res.data as List).map((e) => StockMovement.fromJson(e)).toList();
  }

  static Future<StockMovement> adjust({
    required int articleId,
    required double quantite,
    required String type, // IN ou OUT
    required String motif,
  }) async {
    final res = await ApiClient.instance.post('/stock/adjust', data: {
      'articleId': articleId,
      'quantite': quantite,
      'type': type,
      'motif': motif,
    });
    return StockMovement.fromJson(res.data);
  }
}
