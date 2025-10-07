import 'crop_recommendation_model.dart';
import 'soil_condition.dart';

class CropRecommendationHistory {
  final String id;
  final DateTime date;
  final SoilCondition soilCondition;
  final List<CropRecommendation> recommendations;
  final String location;
  final String notes;

  const CropRecommendationHistory({
    required this.id,
    required this.date,
    required this.soilCondition,
    required this.recommendations,
    required this.location,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'soil_condition': soilCondition.toJson(),
      'recommendations': recommendations.map((rec) => rec.toJson()).toList(),
      'location': location,
      'notes': notes,
    };
  }

  factory CropRecommendationHistory.fromJson(Map<String, dynamic> json) {
    return CropRecommendationHistory(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      soilCondition: SoilCondition.fromJson(
          json['soil_condition'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map(
              (rec) => CropRecommendation.fromJson(rec as Map<String, dynamic>))
          .toList(),
      location: (json['location'] as String?) ?? 'Unknown Location',
      notes: (json['notes'] as String?) ?? '',
    );
  }
}
