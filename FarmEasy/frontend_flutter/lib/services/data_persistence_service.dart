import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/marketplace_models.dart';
import '../models/virtual_farm_model.dart';
import '../models/soil_condition.dart';
import '../models/crop_recommendation_history.dart';

class DataPersistenceService {
  static const String _marketplaceListingsKey = 'marketplace_listings';
  static const String _marketplaceOrdersKey = 'marketplace_orders';
  static const String _virtualFarmsKey = 'virtual_farms';
  // Align with SoilConditionProvider storage to avoid divergence
  static const String _harvestHistoryKey = 'harvest_history';
  static const String _recommendationHistoryKey = 'recommendation_history';

  // Marketplace Listings
  static Future<void> saveMarketplaceListings(
      List<MarketplaceItem> listings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = listings.map((e) => e.toJson()).toList();
    await prefs.setString(_marketplaceListingsKey, jsonEncode(jsonList));
  }

  static Future<List<MarketplaceItem>> loadMarketplaceListings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_marketplaceListingsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => MarketplaceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Marketplace Orders
  static Future<void> saveMarketplaceOrders(List<OrderItem> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = orders.map((e) => e.toJson()).toList();
    await prefs.setString(_marketplaceOrdersKey, jsonEncode(jsonList));
  }

  static Future<List<OrderItem>> loadMarketplaceOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_marketplaceOrdersKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Virtual Farms
  static Future<void> saveVirtualFarms(List<VirtualFarm> farms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = farms.map((e) => e.toJson()).toList();
    await prefs.setString(_virtualFarmsKey, jsonEncode(jsonList));
  }

  static Future<List<VirtualFarm>> loadVirtualFarms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_virtualFarmsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => VirtualFarm.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Harvest History (shared with SoilConditionProvider)
  static Future<void> saveHarvestEntries(List<HarvestEntry> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((e) => e.toJson()).toList();
    await prefs.setString(_harvestHistoryKey, jsonEncode(jsonList));
  }

  static Future<List<HarvestEntry>> loadHarvestEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_harvestHistoryKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => HarvestEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_marketplaceListingsKey);
    await prefs.remove(_marketplaceOrdersKey);
    await prefs.remove(_virtualFarmsKey);
    await prefs.remove(_harvestHistoryKey);
    await prefs.remove(_recommendationHistoryKey);
  }

  // Crop Recommendation History
  static Future<void> saveCropRecommendationHistory(
      List<CropRecommendationHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = history.map((e) => e.toJson()).toList();
    await prefs.setString(_recommendationHistoryKey, jsonEncode(historyJson));
  }

  static Future<List<CropRecommendationHistory>>
      loadCropRecommendationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recommendationHistoryKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) =>
            CropRecommendationHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
