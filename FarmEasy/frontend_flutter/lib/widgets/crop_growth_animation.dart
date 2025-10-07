import 'package:flutter/material.dart';
import '../models/virtual_farm_model.dart';

class CropGrowthAnimation extends StatelessWidget {
  final String cropType;
  final List<GrowthStage> growthStages;
  final AnimationController animationController;
  final GrowthStage? selectedStage;

  const CropGrowthAnimation({
    super.key,
    required this.cropType,
    required this.growthStages,
    required this.animationController,
    this.selectedStage,
  });

  @override
  Widget build(BuildContext context) {
    // Backward compatibility placeholder; prefer InteractiveFarmView
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Use InteractiveFarmView for better visualization',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
