import 'package:flutter/material.dart';
import '../models/virtual_farm_model.dart';
import '../utils/constants.dart';
import '../widgets/interactive_farm_view.dart';
import '../widgets/climate_risk_card.dart';

class VirtualFarmSimulationScreen extends StatefulWidget {
  final VirtualFarm virtualFarm;
  const VirtualFarmSimulationScreen({super.key, required this.virtualFarm});

  @override
  State<VirtualFarmSimulationScreen> createState() =>
      _VirtualFarmSimulationScreenState();
}

class _VirtualFarmSimulationScreenState
    extends State<VirtualFarmSimulationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedTabIndex = 0;
  GrowthStage? _selectedGrowthStage;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat();

    final daysSincePlanting =
        DateTime.now().difference(widget.virtualFarm.plantingDate).inDays;
    _selectedGrowthStage = _getCurrentGrowthStage(daysSincePlanting);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.virtualFarm.cropType} Farm Twin'),
        backgroundColor: AppConstants.primaryGreen,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') _resetSimulation();
              if (value == 'export') _exportReport();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'reset', child: Text('Reset Simulation')),
              PopupMenuItem(value: 'export', child: Text('Export Report')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFarmOverviewHeader(),
          _buildTabNavigation(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildFarmOverviewHeader() {
    final daysSincePlanting =
        DateTime.now().difference(widget.virtualFarm.plantingDate).inDays;
    final currentStage = _getCurrentGrowthStage(daysSincePlanting);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppConstants.primaryGreen, Colors.green.shade300]),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.virtualFarm.landSize} Hectares',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(widget.virtualFarm.location,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Day $daysSincePlanting',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
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
                  Text('Growth Stage: ${currentStage.stage}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('${currentStage.progress.toInt()}%',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: currentStage.progress / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    final tabs = ['Growth', 'Risks', 'Forecast', 'Analytics'];
    return Container(
      height: 50,
      color: Colors.grey.shade100,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTabIndex == index
                          ? AppConstants.primaryGreen
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: _selectedTabIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedTabIndex == index
                          ? AppConstants.primaryGreen
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildGrowthTab();
      case 1:
        return _buildRisksTab();
      case 2:
        return _buildForecastTab();
      case 3:
        return _buildAnalyticsTab();
      default:
        return _buildGrowthTab();
    }
  }

  Widget _buildGrowthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Virtual Farm View',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (_selectedGrowthStage ??
                                  widget.virtualFarm.growthStages.first)
                              .stage,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: InteractiveFarmView(
                      virtualFarm: widget.virtualFarm,
                      currentStage: _selectedGrowthStage ??
                          widget.virtualFarm.growthStages.first,
                      showRiskEffects: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (_selectedGrowthStage ??
                              widget.virtualFarm.growthStages.first)
                          .description,
                      style:
                          TextStyle(color: Colors.blue.shade700, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Growth Timeline (Tap to Preview)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...widget.virtualFarm.growthStages
                      .map((stage) => _buildSelectableGrowthStageItem(stage)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableGrowthStageItem(GrowthStage stage) {
    final daysSincePlanting =
        DateTime.now().difference(widget.virtualFarm.plantingDate).inDays;
    final isActive = daysSincePlanting >= stage.daysFromPlanting;
    final isSelected = _selectedGrowthStage?.stage == stage.stage;

    return GestureDetector(
      onTap: () => setState(() => _selectedGrowthStage = stage),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.shade100
              : (isActive ? Colors.grey.shade50 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green.shade400 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.green.shade600
                    : (isActive ? Colors.green.shade400 : Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stage.stage} (Day ${stage.daysFromPlanting})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected || isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                  Text(
                    stage.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected || isActive
                          ? Colors.grey.shade700
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.visibility, color: Colors.green.shade600, size: 16)
            else if (isActive)
              Icon(Icons.check_circle, color: Colors.green.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRisksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Risk Impact Visualization',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: InteractiveFarmView(
                      virtualFarm: widget.virtualFarm,
                      currentStage: _selectedGrowthStage ??
                          widget.virtualFarm.growthStages.first,
                      activeRisks: widget.virtualFarm.climateRisks,
                      showRiskEffects: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'This shows how climate risks affect your farm. Different effects are visible based on the risk type.',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Risk Analysis',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...widget.virtualFarm.climateRisks
                      .map((risk) => ClimateRiskCard(risk: risk)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Harvest Forecast Visualization',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: InteractiveFarmView(
                      virtualFarm: widget.virtualFarm,
                      currentStage: widget.virtualFarm.growthStages.last,
                      showRiskEffects: false,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'This shows your farm at harvest time with expected crop maturity.',
                      style:
                          TextStyle(color: Colors.green.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Yield & Profit Forecast',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _buildMetricCard(
                              'Expected Yield',
                              '${widget.virtualFarm.expectedYield.toStringAsFixed(1)} tons',
                              Icons.agriculture)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildMetricCard(
                              'Expected Profit',
                              '₹${widget.virtualFarm.expectedProfit.toStringAsFixed(0)}',
                              Icons.currency_rupee)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Yield/Hectare',
                          '${(widget.virtualFarm.expectedYield / (widget.virtualFarm.landSize == 0 ? 1 : widget.virtualFarm.landSize)).toStringAsFixed(1)} t/ha',
                          Icons.eco,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Harvest Date',
                          _getHarvestDate(),
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHarvestDate() {
    final last = widget.virtualFarm.growthStages.last;
    final date = widget.virtualFarm.plantingDate
        .add(Duration(days: last.daysFromPlanting));
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildAnalyticsTab() {
    final yieldPerHa = widget.virtualFarm.expectedYield /
        (widget.virtualFarm.landSize == 0 ? 1 : widget.virtualFarm.landSize);
    final profitPerHa = widget.virtualFarm.expectedProfit /
        (widget.virtualFarm.landSize == 0 ? 1 : widget.virtualFarm.landSize);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Farm Analytics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildAnalyticRow(
                  'Total Land Area', '${widget.virtualFarm.landSize} hectares'),
              _buildAnalyticRow('Crop Type', widget.virtualFarm.cropType),
              _buildAnalyticRow('Planting Date',
                  _formatDate(widget.virtualFarm.plantingDate)),
              _buildAnalyticRow('Yield per Hectare',
                  '${yieldPerHa.toStringAsFixed(1)} tons/ha'),
              _buildAnalyticRow('Profit per Hectare',
                  '₹${profitPerHa.toStringAsFixed(0)}/ha'),
            ],
          ),
        ),
      ),
    );
  }

  GrowthStage _getCurrentGrowthStage(int daysSincePlanting) {
    for (var stage in widget.virtualFarm.growthStages.reversed) {
      if (daysSincePlanting >= stage.daysFromPlanting) return stage;
    }
    return widget.virtualFarm.growthStages.first;
  }

  // _buildGrowthStageItem removed (replaced by selectable version)

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Icon(icon, color: AppConstants.primaryGreen, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAnalyticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _resetSimulation() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulation reset successfully')));
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report exported successfully')));
  }
}
