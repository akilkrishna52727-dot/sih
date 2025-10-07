import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isGuest = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && !_isGuest;
  bool get isGuest => _isGuest;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    bool success = false;
    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      if (_user != null) {
        _isGuest = false;
        _error = null;
        success = true;
        await _authService.clearSkippedLogin();
      }
    } catch (e) {
      _error = e.toString();
      _user = null;
      _isGuest = false;
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    bool success = false;
    try {
      _user = await _authService.login(email, password);
      if (_user != null) {
        _isGuest = false; // ensure we are not in guest
        _error = null;
        success = true;
      }
    } catch (e) {
      _error = e.toString();
      _user = null;
      _isGuest = false;
      success = false;
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.logout();
      _user = null;
      _isGuest = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null; // force-clear any local state
      _isGuest = false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    if (await _authService.isLoggedIn()) {
      _user = await _authService.getCurrentUser();
      _isGuest = false;
      notifyListeners();
    } else if (await _authService.hasSkippedLogin()) {
      setGuestUser(_authService.getGuestUser());
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setGuestUser(User guestUser) {
    _user = guestUser;
    _isGuest = true;
    _error = null;
    notifyListeners();
  }
}
