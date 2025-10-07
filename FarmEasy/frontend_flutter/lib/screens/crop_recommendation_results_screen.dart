import 'package:flutter/material.dart';
import '../models/crop_recommendation_model.dart';
import '../models/crop_recommendation_history.dart';
import '../utils/constants.dart';

class CropRecommendationResultsScreen extends StatelessWidget {
  final Map<String, dynamic>? soilData;
  final List<CropRecommendation> recommendations;
  final CropRecommendationHistory? history;

  const CropRecommendationResultsScreen({
    super.key,
    required this.soilData,
    required this.recommendations,
  }) : history = null;

  const CropRecommendationResultsScreen.fromHistory(this.history, {super.key})
      : soilData = null,
        recommendations = const [];

  List<CropRecommendation> get _recommendations =>
      history?.recommendations ?? recommendations;

  Map<String, dynamic> get _soilData =>
      soilData ??
      {
        'nitrogen': history?.soilCondition.nitrogen ?? 0,
        'phosphorus': history?.soilCondition.phosphorus ?? 0,
        'potassium': history?.soilCondition.potassium ?? 0,
        'ph_level': history?.soilCondition.phLevel ?? 0,
        'organic_carbon': history?.soilCondition.organicCarbon ?? 0,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(history != null
            ? 'Historical Recommendations'
            : 'Crop Recommendations'),
        backgroundColor: AppConstants.primaryGreen,
        actions: [
          if (history != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${history!.date.day}/${history!.date.month}/${history!.date.year}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareRecommendations(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSoilSummaryCard(),
            if (_recommendations.isNotEmpty)
              ..._recommendations
                  .map((rec) => _buildRecommendationCard(context, rec))
            else
              _buildNoRecommendationsCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.eco, color: AppConstants.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Your Soil Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildSoilMetric(
                        'Nitrogen', '${_soilData['nitrogen']} mg/kg')),
                Expanded(
                    child: _buildSoilMetric(
                        'Phosphorus', '${_soilData['phosphorus']} mg/kg')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _buildSoilMetric(
                        'Potassium', '${_soilData['potassium']} mg/kg')),
                Expanded(
                    child: _buildSoilMetric(
                        'pH Level', '${_soilData['ph_level']}')),
              ],
            ),
            const SizedBox(height: 8),
            _buildSoilMetric(
                'Organic Carbon', '${_soilData['organic_carbon']}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, CropRecommendation recommendation) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getScoreColor(recommendation.suitabilityScore),
          child: Text(
            '${recommendation.suitabilityScore.toInt()}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          recommendation.cropName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recommendation.description),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildChip(
                    '${recommendation.expectedYield.toStringAsFixed(1)} tons/ha',
                    Colors.green),
                const SizedBox(width: 4),
                _buildChip(recommendation.profitPotential, Colors.blue),
                const SizedBox(width: 4),
                _buildChip(recommendation.riskLevel,
                    _getRiskColor(recommendation.riskLevel)),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoTile('Season',
                            recommendation.seasonality, Icons.calendar_today)),
                    Expanded(
                        child: _buildInfoTile('Water Need',
                            recommendation.waterRequirement, Icons.water_drop)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildInfoTile(
                            'Market Price',
                            '₹${recommendation.marketPrice.toStringAsFixed(0)}/ton',
                            Icons.currency_rupee)),
                    Expanded(
                        child: _buildInfoTile('Risk Level',
                            recommendation.riskLevel, Icons.warning)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Requirements:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...recommendation.requirements.map((req) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(req,
                                  style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                const Text(
                  'Growing Tips:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...recommendation.tips.map((tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(tip,
                                  style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _startVirtualFarm(context, recommendation),
                        icon: const Icon(Icons.eco),
                        label: const Text('Start Virtual Farm'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryGreen),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _viewMarketPrices(context, recommendation),
                        icon: const Icon(Icons.trending_up),
                        label: const Text('Market Info'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNoRecommendationsCard() {
    return const Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Suitable Crops Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your soil parameters may need adjustment. Consider soil treatment or consult an agricultural expert.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _startVirtualFarm(BuildContext context, CropRecommendation rec) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting virtual farm for ${rec.cropName}...')),
    );
  }

  void _viewMarketPrices(BuildContext context, CropRecommendation rec) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing market info for ${rec.cropName}...')),
    );
  }

  void _shareRecommendations(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share not implemented in demo')),
    );
  }
}
