class WeatherData {
  final String location;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double pressure;
  final String description;
  final String icon;
  final double windSpeed;
  final int windDirection;
  final double visibility;
  final double uvIndex;
  final int timestamp;

  WeatherData({
    required this.location,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.uvIndex,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] ?? '',
      country: json['country'] ?? '',
      temperature: json['temperature']?.toDouble() ?? 0.0,
      feelsLike: json['feels_like']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toInt() ?? 0,
      pressure: json['pressure']?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      windSpeed: json['wind_speed']?.toDouble() ?? 0.0,
      windDirection: json['wind_direction']?.toInt() ?? 0,
      visibility: json['visibility']?.toDouble() ?? 0.0,
      uvIndex: json['uv_index']?.toDouble() ?? 0.0,
      timestamp: json['timestamp']?.toInt() ?? 0,
    );
  }
}

class WeatherRisk {
  final String type;
  final String severity;
  final String message;
  final String recommendation;

  WeatherRisk({
    required this.type,
    required this.severity,
    required this.message,
    required this.recommendation,
  });

  factory WeatherRisk.fromJson(Map<String, dynamic> json) {
    return WeatherRisk(
      type: json['type'] ?? '',
      severity: json['severity'] ?? '',
      message: json['message'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }
}
