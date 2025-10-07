import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP client (injectable for testing)
  http.Client _client = http.Client();

  /// Allows tests to inject a mock HTTP client
  void setClient(http.Client client) {
    _client = client;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  String? _token;

  String? get token => _token;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      // Log request
      // ignore: avoid_print
      print('[POST] ${uri.toString()}');
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.timeout);
      // Log response
      // ignore: avoid_print
      print('[POST] ${uri.path} -> ${response.statusCode}');

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      // ignore: avoid_print
      print('[GET] ${uri.toString()}');
      final response = await _client
          .get(
            uri,
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);
      // ignore: avoid_print
      print('[GET] ${uri.path} -> ${response.statusCode}');

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      // ignore: avoid_print
      print('[PUT] ${uri.toString()}');
      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.timeout);
      // ignore: avoid_print
      print('[PUT] ${uri.path} -> ${response.statusCode}');

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Enhanced soil analysis convenience method
  Future<Map<String, dynamic>> analyzeEnhancedSoil({
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required double phLevel,
    required double organicCarbon,
    double? farmSize,
    String? location,
    double? temperature,
    double? humidity,
    double? rainfall,
  }) async {
    final payload = <String, dynamic>{
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph_level': phLevel,
      'organic_carbon': organicCarbon,
      'farm_size': farmSize ?? 1.0,
      'location': location,
      'temperature': temperature ?? 25.0,
      'humidity': humidity ?? 65.0,
      'rainfall': rainfall ?? 200.0,
    };
    // Remove null values to keep payload tidy
    payload.removeWhere((key, value) => value == null);

    return post(ApiEndpoints.soilAnalyzeEnhanced, payload);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> data;
    try {
      data = response.body.isNotEmpty
          ? json.decode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};
    } on FormatException {
      throw Exception(
          'Invalid response format (status ${response.statusCode})');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final msg = (data['message'] ?? data['error'] ?? 'API Error').toString();
      throw Exception('$msg: ${response.statusCode}');
    }
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
