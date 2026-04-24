import 'package:flutter/material.dart';
import '../models/dashboard_kpi.dart';
import '../services/dashboard_service.dart';

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
      _kpi = await DashboardService.fetchKpis();
    } catch (_) {
      _error = 'Impossible de charger les données. Vérifiez la connexion.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
