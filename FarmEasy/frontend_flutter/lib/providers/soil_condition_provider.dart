import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/soil_condition.dart';

class SoilConditionProvider extends ChangeNotifier {
  static const _kSoilConditionKey = 'soil_condition';
  static const _kCropRotationKey = 'crop_rotation';
  static const _kHarvestHistoryKey = 'harvest_history';

  SoilCondition? _soilCondition;
  CropRotation? _rotation;
  List<HarvestEntry> _harvestHistory = [];
  bool _loading = false;
  String? _error;

  SoilCondition? get soilCondition => _soilCondition;
  CropRotation? get rotation => _rotation;
  List<HarvestEntry> get harvestHistory => List.unmodifiable(_harvestHistory);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _soilCondition =
          SoilCondition.decode(prefs.getString(_kSoilConditionKey));

      final rotRaw = prefs.getString(_kCropRotationKey);
      if (rotRaw != null && rotRaw.isNotEmpty) {
        _rotation = CropRotation.fromJson(jsonDecode(rotRaw));
      }

      final histRaw = prefs.getString(_kHarvestHistoryKey);
      if (histRaw != null && histRaw.isNotEmpty) {
        final list = jsonDecode(histRaw) as List<dynamic>;
        _harvestHistory = list
            .map((e) => HarvestEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveSoilCondition(SoilCondition sc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSoilConditionKey, SoilCondition.encode(sc));
    _soilCondition = sc;
    notifyListeners();
  }

  Future<void> saveRotation(CropRotation rotation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCropRotationKey, jsonEncode(rotation.toJson()));
    _rotation = rotation;
    notifyListeners();
  }

  Future<void> addHarvest(HarvestEntry entry,
      {SoilCondition? updatedSoil}) async {
    final prefs = await SharedPreferences.getInstance();
    _harvestHistory.add(entry);
    await prefs.setString(
      _kHarvestHistoryKey,
      jsonEncode(_harvestHistory.map((e) => e.toJson()).toList()),
    );
    if (updatedSoil != null) {
      await prefs.setString(
          _kSoilConditionKey, SoilCondition.encode(updatedSoil));
      _soilCondition = updatedSoil;
    }
    notifyListeners();
  }

  Future<void> setHarvestHistory(List<HarvestEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    _harvestHistory = List.from(entries);
    await prefs.setString(
      _kHarvestHistoryKey,
      jsonEncode(_harvestHistory.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSoilConditionKey);
    await prefs.remove(_kCropRotationKey);
    await prefs.remove(_kHarvestHistoryKey);
    _soilCondition = null;
    _rotation = null;
    _harvestHistory = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
