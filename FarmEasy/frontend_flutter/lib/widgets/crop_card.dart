import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../utils/constants.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final double? confidence;
  final VoidCallback? onTap;

  const CropCard({
    super.key,
    required this.crop,
    this.confidence,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.lightGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCropIcon(crop.name),
                      color: AppConstants.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textDark,
                          ),
                        ),
                        Text(
                          '${crop.season} Season',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (confidence != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(confidence!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(confidence! * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Expected Yield',
                      '${crop.expectedYield.toStringAsFixed(0)} kg/ha',
                      Icons.agriculture,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Market Price',
                      '₹${crop.marketPrice.toStringAsFixed(0)}/kg',
                      Icons.currency_rupee,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Temperature',
                      '${crop.minTemp.toStringAsFixed(0)}-${crop.maxTemp.toStringAsFixed(0)}°C',
                      Icons.thermostat,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Rainfall',
                      '${crop.minRainfall.toStringAsFixed(0)}-${crop.maxRainfall.toStringAsFixed(0)}mm',
                      Icons.water_drop,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppConstants.primaryGreen),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.greyColor,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppConstants.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getCropIcon(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'rice':
        return Icons.grass;
      case 'wheat':
        return Icons.agriculture;
      case 'cotton':
        return Icons.eco;
      case 'sugarcane':
        return Icons.local_florist;
      case 'maize':
        return Icons.grain;
      default:
        return Icons.eco;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
