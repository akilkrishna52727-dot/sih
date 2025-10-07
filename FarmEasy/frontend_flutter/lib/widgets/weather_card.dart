import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;
  final List<WeatherRisk> risks;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.risks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryGreen,
              AppConstants.accentGreen,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location and Temperature
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.location,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        weather.description.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Feels like ${weather.feelsLike.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Weather Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherDetail(
                      'Humidity', '${weather.humidity}%', Icons.water_drop),
                  _buildWeatherDetail('Wind',
                      '${weather.windSpeed.toStringAsFixed(1)} m/s', Icons.air),
                  _buildWeatherDetail(
                      'Pressure',
                      '${weather.pressure.toStringAsFixed(0)} hPa',
                      Icons.speed),
                ],
              ),

              // Weather Risks
              if (risks.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white30),
                const SizedBox(height: 12),
                const Text(
                  'Agricultural Alerts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...risks.take(2).map((risk) => _buildRiskAlert(risk)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskAlert(WeatherRisk risk) {
    Color alertColor = _getRiskColor(risk.severity);
    IconData alertIcon = _getRiskIcon(risk.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: alertColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(alertIcon, color: alertColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              risk.message,
              style: TextStyle(
                fontSize: 12,
                color: alertColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.yellow;
    }
  }

  IconData _getRiskIcon(String type) {
    switch (type.toLowerCase()) {
      case 'high_temperature':
        return Icons.thermostat;
      case 'low_humidity':
        return Icons.water_drop_outlined;
      case 'high_wind':
        return Icons.air;
      case 'heavy_rainfall':
        return Icons.umbrella;
      case 'no_rainfall':
        return Icons.wb_sunny;
      default:
        return Icons.warning;
    }
  }
}
