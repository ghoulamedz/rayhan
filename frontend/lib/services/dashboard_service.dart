import 'api_client.dart';
import '../models/dashboard_kpi.dart';
import '../models/trending_product.dart';

abstract class DashboardService {
  Future<DashboardKpi> fetchKpis();
  Future<List<TrendingProduct>> fetchTrendingProducts();
}

class RealDashboardService implements DashboardService {
  @override
  Future<DashboardKpi> fetchKpis() async {
    final response = await ApiClient.instance.get('/dashboard');
    return DashboardKpi.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<TrendingProduct>> fetchTrendingProducts() async {
    final response = await ApiClient.instance.get('/dashboard/trending-products');
    return (response.data as List)
        .map((e) => TrendingProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
