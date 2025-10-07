import 'package:flutter/material.dart';
import '../models/disease_models.dart';

class DiseaseDetailsScreen extends StatelessWidget {
  final PlantDisease disease;
  const DiseaseDetailsScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(disease.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(disease.scientificName,
                style: const TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.grey)),
            const SizedBox(height: 12),
            Text(disease.description),
            const SizedBox(height: 16),
            _buildSection('Symptoms', disease.symptoms),
            _buildSection('Causes', disease.causes),
            _buildSection('Treatments', disease.treatments),
            _buildSection('Prevention', disease.prevention),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(e)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
