import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherData? _currentWeather;
  List<WeatherRisk> _weatherRisks = [];
  bool _isLoading = false;
  String? _error;

  WeatherData? get currentWeather => _currentWeather;
  List<WeatherRisk> get weatherRisks => _weatherRisks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> getCurrentWeather(
      {String? city, double? lat, double? lon}) async {
    _setLoading(true);
    try {
      _currentWeather = await _weatherService.getCurrentWeather(
        city: city,
        lat: lat,
        lon: lon,
      );

      if (_currentWeather != null) {
        await getWeatherRisks(city: city, lat: lat, lon: lon);
      }

      _error = null;
      _setLoading(false);
      return _currentWeather != null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> getWeatherRisks({String? city, double? lat, double? lon}) async {
    try {
      _weatherRisks = await _weatherService.getWeatherRisks(
        city: city,
        lat: lat,
        lon: lon,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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
}
