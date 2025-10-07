import 'package:flutter/material.dart';
import '../models/subsidy_model.dart';
import '../services/subsidy_service.dart';

class SubsidyEligibilityChecker extends StatelessWidget {
  final double landSize; // in hectares
  final String cropType; // e.g., 'wheat', 'rice', 'horticulture'
  final String location; // state/district (not used in basic demo rules)

  const SubsidyEligibilityChecker({
    super.key,
    required this.landSize,
    required this.cropType,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final eligibleSchemes = _getEligibleSchemes();
    if (eligibleSchemes.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You may be eligible for:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...eligibleSchemes.map(
              (scheme) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(scheme.name),
                subtitle: Text(scheme.benefits),
                trailing: TextButton(
                  onPressed: () => _showSchemeDetails(context, scheme),
                  child: const Text('Learn More'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SubsidyScheme> _getEligibleSchemes() {
    final all = SubsidyService.getSubsidySchemes();
    final loc = location.toLowerCase();
    final crop = cropType.toLowerCase();
    return all.where((s) {
      if (!s.isActive) return false;
      // State filter (if states provided)
      final stateOk = s.states == null
          ? true
          : s.states!.map((e) => e.toLowerCase()).contains(loc);
      if (!stateOk) return false;
      // Crop filter (if crops provided)
      final cropOk = s.crops == null
          ? true
          : s.crops!.map((e) => e.toLowerCase()).contains(crop);
      if (!cropOk) return false;
      // Land size thresholds
      if (s.minLandSize != null && landSize < s.minLandSize!) return false;
      if (s.maxLandSize != null && landSize > s.maxLandSize!) return false;
      // Scheme-specific extras (examples)
      if (s.id == 'pm_kisan' && landSize > 2.0) return false;
      return true;
    }).toList();
  }

  void _showSchemeDetails(BuildContext context, SubsidyScheme scheme) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(scheme.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(scheme.description),
              const SizedBox(height: 12),
              _info('Eligibility', scheme.eligibility),
              _info('Benefits', scheme.benefits),
              _info('How to Apply', scheme.applicationProcess),
              _info('Ministry', scheme.ministry),
              _info('Contact', scheme.contactInfo),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      );
}
