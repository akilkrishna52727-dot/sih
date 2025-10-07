import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../models/soil_test_model.dart';
import '../services/api_service.dart';
import '../models/enhanced_models.dart';
import '../utils/constants.dart';

class CropProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Crop> _crops = [];
  List<Map<String, dynamic>> _recommendations = [];
  // Enhanced (typed) state
  List<EnhancedRecommendation> _enhancedRecs = [];
  SoilHealthAnalysis? _enhancedSoil;
  SoilTest? _lastSoilTest;
  bool _isLoading = false;
  String? _error;

  List<Crop> get crops => _crops;
  List<Map<String, dynamic>> get recommendations => _recommendations;
  List<EnhancedRecommendation> get enhancedRecommendations => _enhancedRecs;
  SoilHealthAnalysis? get enhancedSoilAnalysis => _enhancedSoil;
  SoilTest? get lastSoilTest => _lastSoilTest;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> getCropRecommendations(SoilTest soilTest) async {
    _setLoading(true);
    try {
      final response =
          await _apiService.post(ApiEndpoints.cropRecommend, soilTest.toJson());

      _lastSoilTest = SoilTest.fromJson(response['soil_test']);
      _recommendations =
          List<Map<String, dynamic>>.from(response['recommendations']);

      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> analyzeSoilEnhanced(SoilTest soilTest,
      {double? temperature,
      double? humidity,
      double? rainfall,
      double? farmSize,
      String? location}) async {
    _setLoading(true);
    try {
      final response = await _apiService.analyzeEnhancedSoil(
        nitrogen: soilTest.nitrogen,
        phosphorus: soilTest.phosphorus,
        potassium: soilTest.potassium,
        phLevel: soilTest.phLevel,
        organicCarbon: soilTest.organicCarbon,
        temperature: temperature,
        humidity: humidity,
        rainfall: rainfall,
        farmSize: farmSize,
        location: location,
      );

      _lastSoilTest = SoilTest.fromJson(response['soil_test']);
      final enhanced = Map<String, dynamic>.from(response['enhanced'] ?? {});
      final recs = List<Map<String, dynamic>>.from(
          enhanced['recommendations'] ?? const []);
      _enhancedRecs =
          recs.map((r) => EnhancedRecommendation.fromJson(r)).toList();
      _enhancedSoil = enhanced['soil_analysis'] != null
          ? SoilHealthAnalysis.fromJson(
              Map<String, dynamic>.from(enhanced['soil_analysis']))
          : null;
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loadAllCrops() async {
    _setLoading(true);
    try {
      final response = await _apiService.get('/crops/all');
      final List<dynamic> cropsData = response['crops'];

      _crops = cropsData.map((crop) => Crop.fromJson(crop)).toList();

      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendationHistory() async {
    try {
      final response = await _apiService.get('/crops/history');
      return List<Map<String, dynamic>>.from(response['history']);
    } catch (e) {
      _error = e.toString();
      return [];
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
