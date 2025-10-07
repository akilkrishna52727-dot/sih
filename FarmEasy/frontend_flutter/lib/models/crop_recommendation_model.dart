class CropRecommendation {
  final String cropName;
  final double suitabilityScore;
  final double expectedYield;
  final String profitPotential;
  final String seasonality;
  final String waterRequirement;
  final String riskLevel;
  final double marketPrice;
  final String description;
  final List<String> requirements;
  final List<String> tips;

  CropRecommendation({
    required this.cropName,
    required this.suitabilityScore,
    required this.expectedYield,
    required this.profitPotential,
    required this.seasonality,
    required this.waterRequirement,
    required this.riskLevel,
    required this.marketPrice,
    required this.description,
    required this.requirements,
    required this.tips,
  });

  Map<String, dynamic> toJson() {
    return {
      'crop_name': cropName,
      'suitability_score': suitabilityScore,
      'expected_yield': expectedYield,
      'profit_potential': profitPotential,
      'seasonality': seasonality,
      'water_requirement': waterRequirement,
      'risk_level': riskLevel,
      'market_price': marketPrice,
      'description': description,
      'requirements': requirements,
      'tips': tips,
    };
  }

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      cropName: json['crop_name'] as String,
      suitabilityScore: (json['suitability_score'] as num).toDouble(),
      expectedYield: (json['expected_yield'] as num).toDouble(),
      profitPotential: json['profit_potential'] as String,
      seasonality: json['seasonality'] as String,
      waterRequirement: json['water_requirement'] as String,
      riskLevel: json['risk_level'] as String,
      marketPrice: (json['market_price'] as num).toDouble(),
      description: json['description'] as String,
      requirements: List<String>.from(json['requirements'] as List<dynamic>),
      tips: List<String>.from(json['tips'] as List<dynamic>),
    );
  }
}
