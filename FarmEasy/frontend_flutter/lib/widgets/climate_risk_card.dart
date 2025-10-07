import 'package:flutter/material.dart';
import '../models/virtual_farm_model.dart';

class ClimateRiskCard extends StatelessWidget {
  final ClimateRisk risk;

  const ClimateRiskCard({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getRiskIcon(), color: riskColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          risk.riskType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: riskColor,
                          ),
                        ),
                        Text(
                          '${risk.severity.toUpperCase()} Risk',
                          style: TextStyle(
                              fontSize: 12,
                              color: riskColor.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: riskColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${risk.impactPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(risk.description, style: const TextStyle(fontSize: 14)),
              if (risk.mitigation.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Mitigation:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ...risk.mitigation.take(2).map((m) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('-  ', style: TextStyle(color: riskColor)),
                          Expanded(
                              child: Text(m,
                                  style: const TextStyle(fontSize: 11))),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor() {
    switch (risk.severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  IconData _getRiskIcon() {
    switch (risk.riskType.toLowerCase()) {
      case 'drought':
        return Icons.wb_sunny;
      case 'flood':
        return Icons.water;
      case 'pest':
        return Icons.bug_report;
      case 'disease':
        return Icons.local_hospital;
      case 'temperature':
        return Icons.thermostat;
      default:
        return Icons.warning;
    }
  }
}
