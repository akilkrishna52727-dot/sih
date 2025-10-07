import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _skippedLoginKey = 'skipped_login';

  final ApiService _apiService = ApiService();

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final payload = {
      // backend accepts either username or name; prefer name here
      'name': name,
      'email': email,
      'password': password,
      'phone': phone ?? '',
    };
    final response = await _apiService.post(ApiEndpoints.register, payload);
    final token = (response['access_token'] ?? response['token']) as String?;
    final userJson = response['user'];
    if (token != null && userJson != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(userJson));
      await prefs.remove(_skippedLoginKey);
      // also set ApiService token for subsequent requests
      await _apiService.setToken(token);
      return User.fromJson(userJson);
    }
    throw Exception(response['message'] ?? 'Registration failed');
  }

  Future<User?> login(String email, String password) async {
    final response = await _apiService.post(ApiEndpoints.login, {
      'email': email,
      'password': password,
    });
    final token = (response['access_token'] ?? response['token']) as String?;
    final userJson = response['user'];
    if (token != null && userJson != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(userJson));
      await prefs.remove(_skippedLoginKey);
      await _apiService.setToken(token);
      return User.fromJson(userJson);
    }
    throw Exception(response['message'] ?? 'Invalid credentials');
  }

  Future<bool> verifyToken() async {
    try {
      await _apiService.loadToken();
      if (_apiService.token == null) return false;
      final res = await _apiService.get(ApiEndpoints.verify);
      return res['valid'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userData = prefs.getString(_userKey);
    if (token != null && userData != null) {
      // If guest flag is set, treat as not logged in
      final skipped = prefs.getBool(_skippedLoginKey) ?? false;
      if (skipped) return false;
      // verify with backend
      await _apiService.setToken(token);
      final valid = await verifyToken();
      if (!valid) {
        // clear invalid credentials
        await logout();
      }
      return valid;
    }
    return false;
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_skippedLoginKey);
    await _apiService.clearToken();
  }

  Future<bool> hasSkippedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSkipped = prefs.getBool(_skippedLoginKey) ?? false;
    final hasToken = prefs.getString(_tokenKey) != null;
    // only guest if skipped and there is no real token
    return hasSkipped && !hasToken;
  }

  Future<void> skipLogin() async {
    final prefs = await SharedPreferences.getInstance();
    // only mark skipped when there's no real login
    final hasToken = prefs.getString(_tokenKey) != null;
    if (!hasToken) {
      await prefs.setBool(_skippedLoginKey, true);
    }
  }

  Future<void> clearSkippedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_skippedLoginKey);
  }

  User getGuestUser() {
    return User(
      id: null,
      username: 'Guest User',
      email: 'guest@example.com',
      phone: '',
    );
  }
}
