import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const Duration timeout = Duration(seconds: 10);
  static const int maxRetries = 3;

  static String get baseUrl {
    const env = String.fromEnvironment('API_ENV', defaultValue: 'development');
    final laptopIp = Platform.environment['LAPTOP_IP'];
    try {
      if (env == 'production') {
        return 'https://api.farmeasy.com/api';
      } else if (env == 'staging') {
        return 'https://staging.farmeasy.com/api';
      } else if (Platform.isAndroid) {
        if (laptopIp != null && laptopIp.isNotEmpty) {
          return 'http://$laptopIp:5000/api';
        }
        // Emulator fallback
        return 'http://10.0.2.2:5000/api';
      } else if (Platform.isIOS) {
        return 'http://localhost:5000/api';
      }
      // Default fallback
      return 'http://localhost:5000/api';
    } catch (e) {
      debugPrint('ApiConfig error: $e');
      return 'http://localhost:5000/api';
    }
  }

  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(timeout);
      debugPrint('API connection status: ${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      debugPrint('API connection error: $e');
      return false;
    }
  }

  static String getEnv() {
    return const String.fromEnvironment('API_ENV', defaultValue: 'development');
  }
}
