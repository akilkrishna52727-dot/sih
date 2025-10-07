import 'package:flutter/material.dart';
import '../models/soil_condition.dart';

class YieldChart extends StatelessWidget {
  final List<HarvestEntry> harvestRecords;

  const YieldChart({super.key, required this.harvestRecords});

  @override
  Widget build(BuildContext context) {
    if (harvestRecords.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final maxYield = harvestRecords
        .map((r) => r.yieldTons)
        .fold<double>(0, (prev, v) => v > prev ? v : prev);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: harvestRecords
                .map((record) => _buildYieldBar(record, maxYield))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: harvestRecords
              .map((record) =>
                  Text('${record.year}', style: const TextStyle(fontSize: 10)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildYieldBar(HarvestEntry record, double maxYield) {
    final heightRatio = maxYield == 0 ? 0 : record.yieldTons / maxYield;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${record.yieldTons.toStringAsFixed(1)}t',
            style: const TextStyle(fontSize: 8)),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: (120.0 * heightRatio),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(record.crop, style: const TextStyle(fontSize: 8)),
      ],
    );
  }
}
