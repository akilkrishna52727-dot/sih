class EnhancedRecommendation {
  final String crop;
  final double confidence;
  final double predictedYieldTonsPerHectare;
  final double predictedPricePerKg;
  final ProfitAnalysis profitAnalysis;
  final List<SubsidyInfo> applicableSubsidies;
  final String growingSeason;

  EnhancedRecommendation({
    required this.crop,
    required this.confidence,
    required this.predictedYieldTonsPerHectare,
    required this.predictedPricePerKg,
    required this.profitAnalysis,
    required this.applicableSubsidies,
    required this.growingSeason,
  });

  factory EnhancedRecommendation.fromJson(Map<String, dynamic> json) {
    return EnhancedRecommendation(
      crop: json['crop'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      predictedYieldTonsPerHectare:
          (json['predicted_yield_tons_per_hectare'] as num).toDouble(),
      predictedPricePerKg: (json['predicted_price_per_kg'] as num).toDouble(),
      profitAnalysis: ProfitAnalysis.fromJson(
          Map<String, dynamic>.from(json['profit_analysis'] ?? {})),
      applicableSubsidies:
          (json['applicable_subsidies'] as List<dynamic>? ?? [])
              .map((s) => SubsidyInfo.fromJson(Map<String, dynamic>.from(s)))
              .toList(),
      growingSeason: (json['growing_season'] as String?) ?? 'All Season',
    );
  }
}

class ProfitAnalysis {
  final double grossIncome;
  final double totalCost;
  final double netProfit;
  final double roiPercentage;
  final double profitPerHectare;

  ProfitAnalysis({
    required this.grossIncome,
    required this.totalCost,
    required this.netProfit,
    required this.roiPercentage,
    required this.profitPerHectare,
  });

  factory ProfitAnalysis.fromJson(Map<String, dynamic> json) {
    return ProfitAnalysis(
      grossIncome: (json['gross_income'] as num? ?? 0).toDouble(),
      totalCost: (json['total_cost'] as num? ?? 0).toDouble(),
      netProfit: (json['net_profit'] as num? ?? 0).toDouble(),
      roiPercentage: (json['roi_percentage'] as num? ?? 0).toDouble(),
      profitPerHectare: (json['profit_per_hectare'] as num? ?? 0).toDouble(),
    );
  }
}

class SoilHealthAnalysis {
  final String overallHealth;
  final List<String> deficiencies;
  final List<String> recommendations;

  SoilHealthAnalysis({
    required this.overallHealth,
    required this.deficiencies,
    required this.recommendations,
  });

  factory SoilHealthAnalysis.fromJson(Map<String, dynamic> json) {
    return SoilHealthAnalysis(
      overallHealth: json['overall_health'] as String? ?? 'Unknown',
      deficiencies:
          List<String>.from(json['deficiencies'] as List<dynamic>? ?? const []),
      recommendations: List<String>.from(
          json['recommendations'] as List<dynamic>? ?? const []),
    );
  }
}

class SubsidyInfo {
  final String scheme;
  final String? description;
  final double? amount;
  final double? premiumRate;
  final String? eligibility;

  SubsidyInfo({
    required this.scheme,
    this.description,
    this.amount,
    this.premiumRate,
    this.eligibility,
  });

  factory SubsidyInfo.fromJson(Map<String, dynamic> json) {
    return SubsidyInfo(
      scheme: json['scheme'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      premiumRate: (json['premium_rate'] as num?)?.toDouble(),
      eligibility: json['eligibility'] as String?,
    );
  }
}
