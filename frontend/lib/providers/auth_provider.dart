import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../mock/mock_services.dart';
import '../mock/mock_config.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _role;
  String? _user;
  String? _errorMessage;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  String? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> data;
      if (MockConfig.useMock) {
        data = await MockAuthService.login(username, password);
      } else {
        data = await AuthService.login(username, password);
      }
      final token = data['token'] as String;
      final roles = data['roles'] as List<dynamic>;
      final user = data['username'] as String;
      final role = roles.isNotEmpty ? roles.first as String : 'Visiteur';

      if (MockConfig.useMock) {
        await MockAuthService.saveToken(token, role);
      } else {
        await AuthService.saveToken(token, role);
      }
      _isAuthenticated = true;
      _role = role;
      _user = user;
      return true;
    } catch (e) {
      _errorMessage =
          'Identifiants incorrects. Vérifiez votre nom d\'utilisateur et mot de passe.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (MockConfig.useMock) {
      await MockAuthService.logout();
    } else {
      await AuthService.logout();
    }
    _isAuthenticated = false;
    _role = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    if (MockConfig.useMock) {
      _isAuthenticated = true;
      _role = await MockAuthService.getRole();
    } else {
      final token = await AuthService.getToken();
      _isAuthenticated = token != null;
      _role = await AuthService.getRole();
    }
    notifyListeners();
  }
}
