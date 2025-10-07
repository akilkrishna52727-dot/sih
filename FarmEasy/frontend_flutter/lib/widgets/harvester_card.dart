import 'package:flutter/material.dart';

import '../models/harvester_models.dart';

class HarvesterCard extends StatelessWidget {
  final Harvester harvester;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onBook;

  const HarvesterCard({
    super.key,
    required this.harvester,
    this.onTap,
    this.onCall,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final img = harvester.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 84,
        height: 84,
        child: img != null
            ? Image.network(img, fit: BoxFit.cover)
            : Container(
                color: Colors.green[50],
                child:
                    Icon(Icons.agriculture, color: Colors.green[700], size: 36),
              ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                harvester.businessName,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            _AvailabilityPill(isAvailable: harvester.isAvailable),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.star, color: Colors.orange[700], size: 18),
            const SizedBox(width: 4),
            Text(
                '${harvester.rating.toStringAsFixed(1)} • ${harvester.reviewCount} reviews'),
            const SizedBox(width: 8),
            if (harvester.isVerified)
              const Icon(Icons.verified, color: Colors.blue, size: 18),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...harvester.services.take(3).map(
                  (s) => Chip(
                    label: Text(s),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            if (harvester.emergencyService)
              Chip(
                label: const Text('Emergency'),
                backgroundColor: Colors.red.shade50,
                side: BorderSide(color: Colors.red.shade200),
                labelStyle: TextStyle(color: Colors.red.shade800),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
            '${harvester.city}, ${harvester.state} • ~${harvester.serviceRadius.toStringAsFixed(0)} km'),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call),
              label: const Text('Call'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onBook,
              icon: const Icon(Icons.calendar_month),
              label: const Text('Book'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  final bool isAvailable;
  const _AvailabilityPill({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isAvailable ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.circle : Icons.circle_outlined,
            size: 10,
            color: isAvailable ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(isAvailable ? 'Available' : 'Busy'),
        ],
      ),
    );
  }
}
