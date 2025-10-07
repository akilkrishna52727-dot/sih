import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class WeatherService {
  // Persistence helpers
  static const String _locationKey = 'selected_location';
  static const String _weatherDataKey = 'cached_weather_data';

  static Future<String> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_locationKey) ?? 'Delhi';
  }

  static Future<void> saveLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, location);
  }

  static Future<Map<String, dynamic>?> getCachedWeatherData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_weatherDataKey);
    if (cachedData != null) {
      return jsonDecode(cachedData) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> cacheWeatherData(Map<String, dynamic> weatherData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherDataKey, jsonEncode(weatherData));
  }

  static Map<String, dynamic> generateWeatherData(String location) {
    final locationMultiplier = location.hashCode % 20;
    return {
      'location': location,
      'temp': 20 + locationMultiplier,
      'humidity': 40 + (locationMultiplier * 2),
      'wind': 5 + (locationMultiplier % 15),
      'pressure': 1000 + (locationMultiplier % 50),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // API helpers
  final ApiService _apiService = ApiService();

  Future<WeatherData?> getCurrentWeather(
      {String? city, double? lat, double? lon}) async {
    try {
      String endpoint = ApiEndpoints.weather;

      if (city != null) {
        endpoint += '?city=$city';
      } else if (lat != null && lon != null) {
        endpoint += '?lat=$lat&lon=$lon';
      }

      final response = await _apiService.get(endpoint);
      return WeatherData.fromJson(response['weather']);
    } catch (e) {
      print('Weather service error: $e');
      return null;
    }
  }

  Future<List<WeatherRisk>> getWeatherRisks(
      {String? city, double? lat, double? lon}) async {
    try {
      String endpoint = '${ApiEndpoints.weather}/risks';

      if (city != null) {
        endpoint += '?city=$city';
      } else if (lat != null && lon != null) {
        endpoint += '?lat=$lat&lon=$lon';
      }

      final response = await _apiService.get(endpoint);
      final List<dynamic> risks = response['risks'] ?? [];

      return risks.map((risk) => WeatherRisk.fromJson(risk)).toList();
    } catch (e) {
      print('Weather risks error: $e');
      return [];
    }
  }
}
