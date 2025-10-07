class VirtualFarm {
  final String id;
  final String userId;
  final double landSize; // hectares
  final String cropType;
  final DateTime plantingDate;
  final String location;
  final Map<String, dynamic> soilData;
  final List<GrowthStage> growthStages;
  final double expectedYield;
  final double expectedProfit;
  final List<ClimateRisk> climateRisks;
  final DateTime createdAt;

  VirtualFarm({
    required this.id,
    required this.userId,
    required this.landSize,
    required this.cropType,
    required this.plantingDate,
    required this.location,
    required this.soilData,
    required this.growthStages,
    required this.expectedYield,
    required this.expectedProfit,
    required this.climateRisks,
    required this.createdAt,
  });

  factory VirtualFarm.fromJson(Map<String, dynamic> json) {
    return VirtualFarm(
      id: json['id'],
      userId: json['user_id'].toString(),
      landSize: (json['land_size'] as num).toDouble(),
      cropType: json['crop_type'],
      plantingDate: DateTime.parse(json['planting_date']),
      location: json['location'],
      soilData: Map<String, dynamic>.from(json['soil_data'] ?? {}),
      growthStages: (json['growth_stages'] as List<dynamic>)
          .map((e) => GrowthStage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      expectedYield: (json['expected_yield'] as num).toDouble(),
      expectedProfit: (json['expected_profit'] as num).toDouble(),
      climateRisks: (json['climate_risks'] as List<dynamic>)
          .map((e) => ClimateRisk.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'land_size': landSize,
      'crop_type': cropType,
      'planting_date': plantingDate.toIso8601String(),
      'location': location,
      'soil_data': soilData,
      'growth_stages': growthStages.map((e) => e.toJson()).toList(),
      'expected_yield': expectedYield,
      'expected_profit': expectedProfit,
      'climate_risks': climateRisks.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class GrowthStage {
  final String stage; // 'seed', 'germination', 'growth', 'flowering', 'harvest'
  final int daysFromPlanting;
  final double progress; // 0-100
  final String description;
  final bool isCompleted;

  GrowthStage({
    required this.stage,
    required this.daysFromPlanting,
    required this.progress,
    required this.description,
    required this.isCompleted,
  });

  factory GrowthStage.fromJson(Map<String, dynamic> json) {
    return GrowthStage(
      stage: json['stage'],
      daysFromPlanting: json['days_from_planting'],
      progress: (json['progress'] as num).toDouble(),
      description: json['description'],
      isCompleted: json['is_completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'days_from_planting': daysFromPlanting,
      'progress': progress,
      'description': description,
      'is_completed': isCompleted,
    };
  }
}

class ClimateRisk {
  final String riskType; // 'drought', 'flood', 'temperature', 'pest'
  final String severity; // 'low', 'medium', 'high'
  final double impactPercentage;
  final String description;
  final List<String> mitigation;

  ClimateRisk({
    required this.riskType,
    required this.severity,
    required this.impactPercentage,
    required this.description,
    required this.mitigation,
  });

  factory ClimateRisk.fromJson(Map<String, dynamic> json) {
    return ClimateRisk(
      riskType: json['risk_type'],
      severity: json['severity'],
      impactPercentage: (json['impact_percentage'] as num).toDouble(),
      description: json['description'],
      mitigation: List<String>.from(json['mitigation'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'risk_type': riskType,
      'severity': severity,
      'impact_percentage': impactPercentage,
      'description': description,
      'mitigation': mitigation,
    };
  }
}
