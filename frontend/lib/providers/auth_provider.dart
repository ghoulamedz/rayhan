import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _role;
  String? _errorMessage;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await AuthService.login(username, password);
      final token = data['token'] as String;
      final roles = data['roles'] as List<dynamic>;
      final role = roles.isNotEmpty ? roles.first as String : 'ROLE_USER';

      await AuthService.saveToken(token, role);
      _isAuthenticated = true;
      _role = role;
      return true;
    } catch (e) {
      _errorMessage = 'Identifiants incorrects. Vérifiez votre nom d\'utilisateur et mot de passe.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _isAuthenticated = false;
    _role = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await AuthService.getToken();
    _isAuthenticated = token != null;
    _role = await AuthService.getRole();
    notifyListeners();
  }
}
