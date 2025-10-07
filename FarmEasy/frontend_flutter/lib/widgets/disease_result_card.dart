import 'package:flutter/material.dart';
import '../models/disease_models.dart';

class DiseaseResultCard extends StatelessWidget {
  final PlantDisease disease;
  final VoidCallback onTap;

  const DiseaseResultCard(
      {super.key, required this.disease, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: _getSeverityColor(disease.severity).withValues(alpha: 0.3),
            width: 2),
      ),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(disease.severity)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getDiseaseIcon(disease.name),
                        color: _getSeverityColor(disease.severity), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(disease.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        if (disease.scientificName.isNotEmpty)
                          Text(
                            disease.scientificName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(disease.severity),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          disease.severity.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${(disease.confidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getSeverityColor(disease.severity))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                disease.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildInfoChip(
                      'Crop: ${disease.crop}', Icons.eco, Colors.green),
                  _buildInfoChip('Affects: ${disease.affectedParts}',
                      Icons.visibility, Colors.blue),
                  if (disease.isContagious)
                    _buildInfoChip('Contagious', Icons.warning, Colors.orange),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.info_outline, size: 16),
                      label:
                          const Text('Details', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showQuickTreatment(context),
                      icon: const Icon(Icons.medical_services,
                          size: 16, color: Colors.white),
                      label: const Text('Treatment',
                          style: TextStyle(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _getSeverityColor(disease.severity),
                          padding: const EdgeInsets.symmetric(vertical: 8)),
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

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return Colors.red.shade600;
      case 'moderate':
        return Colors.orange.shade600;
      case 'mild':
        return Colors.yellow.shade700;
      case 'none':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getDiseaseIcon(String diseaseName) {
    final name = diseaseName.toLowerCase();
    if (name.contains('healthy')) return Icons.check_circle;
    if (name.contains('blight')) return Icons.coronavirus;
    if (name.contains('spot')) return Icons.circle;
    if (name.contains('rust')) return Icons.local_fire_department;
    return Icons.bug_report;
  }

  void _showQuickTreatment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Treatment for ${disease.name}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...disease.treatments.take(3).map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(t)),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onTap();
                },
                child: const Text('View Full Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
