import 'package:flutter/material.dart';
import '../models/virtual_farm_model.dart';
import '../utils/constants.dart';
import 'virtual_farm_simulation_screen.dart';
import 'virtual_farm_setup_form_screen.dart';
import 'harvest_done_screen.dart';

class VirtualFarmListScreen extends StatelessWidget {
  final List<VirtualFarm> farms;

  const VirtualFarmListScreen({super.key, required this.farms});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Virtual Farms'),
        backgroundColor: AppConstants.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewFarm(context),
            tooltip: 'Create New Farm',
          ),
        ],
      ),
      body:
          farms.isEmpty ? _buildEmptyState(context) : _buildFarmsList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No Virtual Farms Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first virtual farm to start simulating crop growth and predicting outcomes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _createNewFarm(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Virtual Farm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmsList(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Virtual Farms (${farms.length})',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _createNewFarm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add New'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...farms.map((farm) => _buildFarmCard(context, farm)),
        ],
      ),
    );
  }

  Widget _buildFarmCard(BuildContext context, VirtualFarm farm) {
    final daysSincePlanting =
        DateTime.now().difference(farm.plantingDate).inDays;
    final currentStage = _getCurrentGrowthStage(farm, daysSincePlanting);
    final isHarvestReady = currentStage.stage.toLowerCase() == 'harvest';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () => _openFarmSimulation(context, farm),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: AppConstants.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${farm.cropType} Farm',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${farm.landSize} hectares -  ${farm.location}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isHarvestReady)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ready to Harvest',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Growth Stage: ${currentStage.stage}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Day $daysSincePlanting',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: currentStage.progress / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppConstants.primaryGreen),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile(
                      'Expected Yield',
                      '${farm.expectedYield.toStringAsFixed(1)} tons',
                      Icons.agriculture,
                    ),
                  ),
                  Expanded(
                    child: _buildStatTile(
                      'Expected Profit',
                      '₹${farm.expectedProfit.toStringAsFixed(0)}',
                      Icons.currency_rupee,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openFarmSimulation(context, farm),
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isHarvestReady
                          ? () => _harvestFarm(context, farm)
                          : () => _openFarmSimulation(context, farm),
                      icon: Icon(
                          isHarvestReady ? Icons.download : Icons.play_arrow),
                      label: Text(isHarvestReady ? 'Harvest' : 'Simulate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHarvestReady
                            ? Colors.orange
                            : AppConstants.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildStatTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  GrowthStage _getCurrentGrowthStage(VirtualFarm farm, int daysSincePlanting) {
    for (var stage in farm.growthStages.reversed) {
      if (daysSincePlanting >= stage.daysFromPlanting) {
        return stage;
      }
    }
    return farm.growthStages.first;
  }

  void _createNewFarm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VirtualFarmSetupFormScreen(),
      ),
    );
  }

  void _openFarmSimulation(BuildContext context, VirtualFarm farm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VirtualFarmSimulationScreen(virtualFarm: farm),
      ),
    );
  }

  void _harvestFarm(BuildContext context, VirtualFarm farm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Harvest Ready!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your ${farm.cropType} farm is ready for harvest!'),
            const SizedBox(height: 8),
            Text(
                'Expected Yield: ${farm.expectedYield.toStringAsFixed(1)} tons'),
            Text('Expected Profit: ₹${farm.expectedProfit.toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToHarvest(context, farm);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Harvest Now',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _proceedToHarvest(BuildContext context, VirtualFarm farm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HarvestDoneScreen(
          preFillData: {
            'crop': farm.cropType,
            'yield': farm.expectedYield.toString(),
            'area': farm.landSize.toString(),
            'expectedProfit': farm.expectedProfit.toString(),
          },
        ),
      ),
    );
  }
}
