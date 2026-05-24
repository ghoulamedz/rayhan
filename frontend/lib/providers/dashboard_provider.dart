import 'package:flutter/material.dart';
import '../models/dashboard_kpi.dart';
import '../services/dashboard_service.dart';
import '../mock/mock_services.dart';
import '../mock/mock_config.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardKpi? _kpi;
  bool _isLoading = false;
  String? _error;

  DashboardKpi? get kpi => _kpi;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (MockConfig.useMock) {
        _kpi = await MockDashboardService.fetchKpis();
      } else {
        _kpi = await DashboardService.fetchKpis();
      }
    } catch (_) {
      _error = 'Impossible de charger les données. Vérifiez la connexion.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
