class Crop {
  final int? id;
  final String name;
  final String season;
  final double minTemp;
  final double maxTemp;
  final double minRainfall;
  final double maxRainfall;
  final String soilType;
  final double expectedYield;
  final double marketPrice;

  Crop({
    this.id,
    required this.name,
    required this.season,
    required this.minTemp,
    required this.maxTemp,
    required this.minRainfall,
    required this.maxRainfall,
    required this.soilType,
    required this.expectedYield,
    required this.marketPrice,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      season: json['season'],
      minTemp: json['min_temp'].toDouble(),
      maxTemp: json['max_temp'].toDouble(),
      minRainfall: json['min_rainfall'].toDouble(),
      maxRainfall: json['max_rainfall'].toDouble(),
      soilType: json['soil_type'],
      expectedYield: json['expected_yield'].toDouble(),
      marketPrice: json['market_price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'season': season,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'min_rainfall': minRainfall,
      'max_rainfall': maxRainfall,
      'soil_type': soilType,
      'expected_yield': expectedYield,
      'market_price': marketPrice,
    };
  }
}
