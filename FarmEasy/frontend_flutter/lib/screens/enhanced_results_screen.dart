import 'package:flutter/material.dart';
import '../models/enhanced_models.dart';
import '../utils/constants.dart';

class EnhancedResultsScreen extends StatelessWidget {
  final List<EnhancedRecommendation> recommendations;
  final SoilHealthAnalysis soilAnalysis;

  const EnhancedResultsScreen(
      {super.key, required this.recommendations, required this.soilAnalysis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('AI+ Recommendations',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SoilHealthCard(soil: soilAnalysis),
          const SizedBox(height: 12),
          for (final rec in recommendations) _RecommendationCard(rec: rec),
        ],
      ),
    );
  }
}

class _SoilHealthCard extends StatelessWidget {
  final SoilHealthAnalysis soil;
  const _SoilHealthCard({required this.soil});

  @override
  Widget build(BuildContext context) {
    final overall = soil.overallHealth;
    final List<String> defs = soil.deficiencies;
    final List<String> tips = soil.recommendations;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.health_and_safety,
                  color: AppConstants.primaryGreen),
              const SizedBox(width: 8),
              Text('Soil Health: $overall',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            if (defs.isNotEmpty) Text('Deficiencies: ${defs.join(', ')}'),
            if (tips.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text('Recommendations:'),
              for (final t in tips) Text('• $t'),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final EnhancedRecommendation rec;
  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final crop = rec.crop;
    final conf = rec.confidence;
    final season = rec.growingSeason;
    final profit = rec.profitAnalysis;
    final subs = rec.applicableSubsidies;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(crop,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Chip(
                  label: Text('${(conf * 100).toStringAsFixed(1)}%'),
                  backgroundColor:
                      AppConstants.lightGreen.withValues(alpha: 0.2),
                ),
              ],
            ),
            Text('Season: $season'),
            Text(
                'Predicted yield: ${rec.predictedYieldTonsPerHectare.toStringAsFixed(2)} t/ha'),
            Text(
                'Predicted price: ₹${rec.predictedPricePerKg.toStringAsFixed(2)}/kg'),
            const SizedBox(height: 8),
            _ProfitView(profit: profit),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            if (subs.isNotEmpty)
              const Text('Eligible subsidies:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            for (final s in subs) Text('• ${s.scheme}: ${s.description ?? ''}'),
          ],
        ),
      ),
    );
  }
}

class _ProfitView extends StatelessWidget {
  final ProfitAnalysis profit;
  const _ProfitView({required this.profit});

  @override
  Widget build(BuildContext context) {
    final gross = _fmt(profit.grossIncome);
    final cost = _fmt(profit.totalCost);
    final net = _fmt(profit.netProfit);
    final roi = _fmt(profit.roiPercentage);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profit analysis',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Gross income: ₹$gross'),
        Text('Total cost: ₹$cost'),
        Text('Net profit: ₹$net'),
        Text('ROI: $roi%'),
      ],
    );
  }

  String _fmt(dynamic n) {
    if (n is num) return n.toStringAsFixed(2);
    return n?.toString() ?? '-';
  }
}
