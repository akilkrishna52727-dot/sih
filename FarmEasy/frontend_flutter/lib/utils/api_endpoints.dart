import 'network_config.dart';

class ApiEndpoints {
  static String get baseUrl => NetworkConfig.getApiBaseUrl();
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get soilTest => '$baseUrl/soil/test';
  static String get crops => '$baseUrl/crops';
  static String get marketplace => '$baseUrl/marketplace';
  static String get alerts => '$baseUrl/alerts';
  static String get subsidies => '$baseUrl/subsidies';
  static String get weather => '$baseUrl/weather';
}
