import 'dart:math';
import '../models/virtual_farm_model.dart';
import 'api_service.dart';

class VirtualFarmService {
  final ApiService _api = ApiService();

  Future<VirtualFarm> createVirtualFarm({
    required double landSize,
    required String cropType,
    required String location,
    required DateTime plantingDate,
  }) async {
    final payload =
        _generateSimulationData(landSize, cropType, location, plantingDate);
    final res = await _api.post('/virtual-farm/create', payload);
    return VirtualFarm.fromJson(res);
  }

  Future<List<VirtualFarm>> getUserFarms() async {
    final res = await _api.get('/virtual-farm/user-farms');
    final farms = (res['farms'] as List<dynamic>)
        .map((e) => VirtualFarm.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return farms;
  }

  Future<VirtualFarm?> updateFarmProgress(String farmId) async {
    final res =
        await _api.post('/virtual-farm/update-progress', {'farm_id': farmId});
    return VirtualFarm.fromJson(res);
  }

  Map<String, dynamic> _generateSimulationData(double landSize, String cropType,
      String location, DateTime plantingDate) {
    final random = Random();
    final growthStages = _generateGrowthStages(cropType);
    final yieldPerHectare =
        _getBaseYieldForCrop(cropType) + (random.nextDouble() * 2 - 1);
    final expectedYield = yieldPerHectare * landSize;
    final pricePerTon = _getBasePriceForCrop(cropType);
    final costPerHectare = _getCostPerHectareForCrop(cropType);
    final expectedProfit =
        (expectedYield * pricePerTon) - (costPerHectare * landSize);
    final climateRisks = _generateClimateRisks(location, cropType);

    return {
      'land_size': landSize,
      'crop_type': cropType,
      'location': location,
      'planting_date': plantingDate.toIso8601String(),
      'growth_stages': growthStages.map((e) => e.toJson()).toList(),
      'expected_yield': expectedYield,
      'expected_profit': expectedProfit,
      'climate_risks': climateRisks.map((e) => e.toJson()).toList(),
    };
  }

  List<GrowthStage> _generateGrowthStages(String cropType) {
    final map = {
      'Rice': [
        GrowthStage(
            stage: 'Seed',
            daysFromPlanting: 0,
            progress: 100,
            description: 'Seeds planted',
            isCompleted: true),
        GrowthStage(
            stage: 'Germination',
            daysFromPlanting: 7,
            progress: 80,
            description: 'Sprouting',
            isCompleted: false),
        GrowthStage(
            stage: 'Tillering',
            daysFromPlanting: 30,
            progress: 60,
            description: 'Multiple shoots',
            isCompleted: false),
        GrowthStage(
            stage: 'Panicle Formation',
            daysFromPlanting: 60,
            progress: 40,
            description: 'Panicles forming',
            isCompleted: false),
        GrowthStage(
            stage: 'Flowering',
            daysFromPlanting: 90,
            progress: 20,
            description: 'Flowers blooming',
            isCompleted: false),
        GrowthStage(
            stage: 'Harvest',
            daysFromPlanting: 120,
            progress: 0,
            description: 'Ready for harvest',
            isCompleted: false),
      ],
      'Wheat': [
        GrowthStage(
            stage: 'Seed',
            daysFromPlanting: 0,
            progress: 100,
            description: 'Seeds planted',
            isCompleted: true),
        GrowthStage(
            stage: 'Germination',
            daysFromPlanting: 5,
            progress: 80,
            description: 'Sprouting',
            isCompleted: false),
        GrowthStage(
            stage: 'Tillering',
            daysFromPlanting: 25,
            progress: 60,
            description: 'Tillering',
            isCompleted: false),
        GrowthStage(
            stage: 'Stem Extension',
            daysFromPlanting: 45,
            progress: 40,
            description: 'Stems extending',
            isCompleted: false),
        GrowthStage(
            stage: 'Flowering',
            daysFromPlanting: 65,
            progress: 20,
            description: 'Flowers blooming',
            isCompleted: false),
        GrowthStage(
            stage: 'Harvest',
            daysFromPlanting: 90,
            progress: 0,
            description: 'Harvest time',
            isCompleted: false),
      ],
    };
    return map[cropType] ?? map['Rice']!;
  }

  List<ClimateRisk> _generateClimateRisks(String location, String cropType) {
    final random = Random();
    final risks = <ClimateRisk>[];
    if (random.nextBool()) {
      risks.add(ClimateRisk(
        riskType: 'Drought',
        severity: ['low', 'medium', 'high'][random.nextInt(3)],
        impactPercentage: 10 + random.nextDouble() * 30,
        description: 'Prolonged dry conditions may affect crop growth',
        mitigation: [
          'Install drip irrigation',
          'Use drought-resistant varieties',
          'Mulching'
        ],
      ));
    }
    if (random.nextBool()) {
      risks.add(ClimateRisk(
        riskType: 'Flood',
        severity: ['low', 'medium'][random.nextInt(2)],
        impactPercentage: 15 + random.nextDouble() * 25,
        description: 'Excessive rainfall may cause waterlogging',
        mitigation: [
          'Improve drainage',
          'Raised bed cultivation',
          'Crop insurance'
        ],
      ));
    }
    risks.add(ClimateRisk(
      riskType: 'Pest',
      severity: ['low', 'medium'][random.nextInt(2)],
      impactPercentage: 5 + random.nextDouble() * 15,
      description: 'Pest attacks during growing season',
      mitigation: [
        'Regular monitoring',
        'Integrated pest management',
        'Resistant varieties'
      ],
    ));
    return risks;
  }

  double _getBaseYieldForCrop(String cropType) {
    final yields = {
      'Rice': 4.5,
      'Wheat': 3.8,
      'Corn': 4.1,
      'Cotton': 2.2,
      'Sugarcane': 75.0,
      'Tomato': 25.0,
    };
    return yields[cropType] ?? 4.0;
  }

  double _getBasePriceForCrop(String cropType) {
    final prices = {
      'Rice': 25000.0,
      'Wheat': 22000.0,
      'Corn': 18000.0,
      'Cotton': 85000.0,
      'Sugarcane': 3500.0,
      'Tomato': 15000.0,
    };
    return prices[cropType] ?? 20000.0;
  }

  double _getCostPerHectareForCrop(String cropType) {
    final costs = {
      'Rice': 45000.0,
      'Wheat': 35000.0,
      'Corn': 30000.0,
      'Cotton': 60000.0,
      'Sugarcane': 100000.0,
      'Tomato': 80000.0,
    };
    return costs[cropType] ?? 40000.0;
  }
}
