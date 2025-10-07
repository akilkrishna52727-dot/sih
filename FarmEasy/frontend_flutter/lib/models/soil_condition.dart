import 'dart:convert';

class SoilCondition {
  final double nitrogen; // N (kg/ha)
  final double phosphorus; // P (kg/ha)
  final double potassium; // K (kg/ha)
  final double phLevel; // pH
  final double organicCarbon; // %
  final DateTime lastUpdated;
  final String? notes;

  SoilCondition({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.phLevel,
    required this.organicCarbon,
    DateTime? lastUpdated,
    this.notes,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  SoilCondition copyWith({
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    double? phLevel,
    double? organicCarbon,
    DateTime? lastUpdated,
    String? notes,
  }) {
    return SoilCondition(
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      phLevel: phLevel ?? this.phLevel,
      organicCarbon: organicCarbon ?? this.organicCarbon,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
    );
  }

  factory SoilCondition.fromJson(Map<String, dynamic> json) {
    return SoilCondition(
      nitrogen: (json['nitrogen'] ?? 0).toDouble(),
      phosphorus: (json['phosphorus'] ?? 0).toDouble(),
      potassium: (json['potassium'] ?? 0).toDouble(),
      phLevel: (json['phLevel'] ?? json['ph_level'] ?? 7).toDouble(),
      organicCarbon:
          (json['organicCarbon'] ?? json['organic_carbon'] ?? 0).toDouble(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nitrogen': nitrogen,
        'phosphorus': phosphorus,
        'potassium': potassium,
        'phLevel': phLevel,
        'organicCarbon': organicCarbon,
        'lastUpdated': lastUpdated.toIso8601String(),
        'notes': notes,
      };

  static String encode(SoilCondition sc) => jsonEncode(sc.toJson());
  static SoilCondition? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return SoilCondition.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

class CropRotation {
  final List<String> crops; // Ordered rotation plan
  final String startingSeason; // e.g., Kharif/Rabi/Zaid
  final int durationMonths; // Total duration covering the plan
  final DateTime createdAt;

  CropRotation({
    required this.crops,
    required this.startingSeason,
    required this.durationMonths,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CropRotation.fromJson(Map<String, dynamic> json) => CropRotation(
        crops: List<String>.from(json['crops'] ?? const []),
        startingSeason: json['startingSeason'] ?? 'Kharif',
        durationMonths: (json['durationMonths'] ?? 12) as int,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'crops': crops,
        'startingSeason': startingSeason,
        'durationMonths': durationMonths,
        'createdAt': createdAt.toIso8601String(),
      };
}

class HarvestEntry {
  final String crop;
  final String season; // Kharif/Rabi/Zaid
  final int year;
  final double area; // ha
  final double yieldTons; // tons
  final double cost; // currency
  final double revenue; // currency
  final double profit; // currency
  final DateTime date;

  HarvestEntry({
    required this.crop,
    required this.season,
    required this.year,
    required this.area,
    required this.yieldTons,
    required this.cost,
    required this.revenue,
    required this.profit,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory HarvestEntry.fromJson(Map<String, dynamic> json) => HarvestEntry(
        crop: json['crop'],
        season: json['season'],
        year: json['year'],
        area: (json['area'] ?? 0).toDouble(),
        yieldTons: (json['yieldTons'] ?? json['yield'] ?? 0).toDouble(),
        cost: (json['cost'] ?? 0).toDouble(),
        revenue: (json['revenue'] ?? 0).toDouble(),
        profit: _calcProfit(json),
        date: json['date'] != null ? DateTime.parse(json['date']) : null,
      );

  Map<String, dynamic> toJson() => {
        'crop': crop,
        'season': season,
        'year': year,
        'area': area,
        'yieldTons': yieldTons,
        'cost': cost,
        'revenue': revenue,
        'profit': profit,
        'date': date.toIso8601String(),
      };

  // Ensure profit integrity when reading legacy/varied JSON
  static double _calcProfit(Map<String, dynamic> json) {
    final cost = (json['cost'] ?? 0).toDouble();
    final revenue = (json['revenue'] ?? 0).toDouble();
    final stored = (json['profit'] ?? (revenue - cost)).toDouble();
    // Prefer consistent calculation in case of discrepancies
    final calculated = revenue - cost;
    // If stored differs significantly (> 0.5), trust calculation
    return (stored - calculated).abs() > 0.5 ? calculated : stored;
  }
}
