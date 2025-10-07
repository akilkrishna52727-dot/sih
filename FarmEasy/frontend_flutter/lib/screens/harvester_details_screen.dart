import 'package:flutter/material.dart';

import '../models/harvester_models.dart';
import '../widgets/harvester_card.dart';
import 'harvest_booking_screen.dart';

class HarvesterDetailsScreen extends StatelessWidget {
  final Harvester harvester;
  const HarvesterDetailsScreen({super.key, required this.harvester});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(harvester.businessName)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          HarvesterCard(
            harvester: harvester,
            onCall: () => _call(context, harvester.phoneNumber),
            onBook: () => _openBooking(context, harvester),
          ),
          const SizedBox(height: 12),
          Text('About', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(harvester.description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                  Icons.location_on, '${harvester.address}, ${harvester.city}'),
              _infoChip(
                  Icons.access_time, _formatHours(harvester.businessHours)),
              _infoChip(Icons.currency_rupee,
                  '₹${harvester.pricePerAcre.toStringAsFixed(0)} ${harvester.priceUnit.replaceAll('_', ' ')}'),
              _infoChip(Icons.route,
                  '~${harvester.serviceRadius.toStringAsFixed(0)} km radius'),
              _infoChip(Icons.verified,
                  harvester.isVerified ? 'Verified' : 'Unverified'),
              _infoChip(
                  Icons.emergency,
                  harvester.emergencyService
                      ? 'Emergency available'
                      : 'No emergency'),
              _infoChip(Icons.event_available,
                  'Season: ${harvester.preferredSeason}'),
              _infoChip(Icons.badge, 'Since ${harvester.established}'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Equipment', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...harvester.equipment.map(
            (e) => ListTile(
              leading: const Icon(Icons.build),
              title: Text('${e.brand} ${e.model} (${e.name})'),
              subtitle: Text(
                  'Type: ${e.type} • Year: ${e.yearOfManufacture} • ${e.capacity} • Crops: ${e.suitableCrops.join(', ')}'),
              trailing: Icon(
                e.isWorking ? Icons.check_circle : Icons.error,
                color: e.isWorking ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Certifications', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: harvester.certifications
                .map((c) => Chip(label: Text(c)))
                .toList(),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openBooking(context, harvester),
            icon: const Icon(Icons.calendar_month),
            label: const Text('Book this Harvester'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
    );
  }

  String _formatHours(Map<String, String> hours) {
    if (hours.isEmpty) return 'Hours: N/A';
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return 'Hours: ${days.where((d) => hours.containsKey(d)).map((d) => '$d ${hours[d]}').join(', ')}';
  }

  void _openBooking(BuildContext context, Harvester h) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HarvestBookingScreen(harvester: h),
      ),
    );
  }

  void _call(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Call $phone')),
    );
  }
}
