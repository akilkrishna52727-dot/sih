class SoilTest {
  final int? id;
  final int userId;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double phLevel;
  final double organicCarbon;
  final DateTime? createdAt;

  SoilTest({
    this.id,
    required this.userId,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.phLevel,
    required this.organicCarbon,
    this.createdAt,
  });

  factory SoilTest.fromJson(Map<String, dynamic> json) {
    return SoilTest(
      id: json['id'],
      userId: json['user_id'],
      nitrogen: json['nitrogen'].toDouble(),
      phosphorus: json['phosphorus'].toDouble(),
      potassium: json['potassium'].toDouble(),
      phLevel: json['ph_level'].toDouble(),
      organicCarbon: json['organic_carbon'].toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph_level': phLevel,
      'organic_carbon': organicCarbon,
    };
  }
}
