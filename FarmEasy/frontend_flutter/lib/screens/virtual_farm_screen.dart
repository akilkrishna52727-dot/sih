import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class VirtualFarmScreen extends StatefulWidget {
  const VirtualFarmScreen({super.key});

  @override
  State<VirtualFarmScreen> createState() => _VirtualFarmScreenState();
}

class _VirtualFarmScreenState extends State<VirtualFarmScreen>
    with TickerProviderStateMixin {
  late AnimationController _growthController;
  late Animation<double> _growthAnimation;

  String selectedCrop = 'Rice';
  int currentGrowthStage = 0;
  bool isSimulating = false;

  final List<String> growthStages = [
    'Seed',
    'Germination',
    'Seedling',
    'Vegetative',
    'Flowering',
    'Maturation',
    'Harvest'
  ];

  @override
  void initState() {
    super.initState();
    _growthController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _growthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _growthController,
      curve: Curves.easeInOut,
    ));

    _growthController.addListener(() {
      setState(() {
        currentGrowthStage =
            (_growthAnimation.value * (growthStages.length - 1)).round();
      });
    });
  }

  @override
  void dispose() {
    _growthController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    setState(() {
      isSimulating = true;
      currentGrowthStage = 0;
    });

    _growthController.forward(from: 0);

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          isSimulating = false;
        });
      }
    });
  }

  void _resetSimulation() {
    _growthController.reset();
    setState(() {
      currentGrowthStage = 0;
      isSimulating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Virtual Farm Twin',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppConstants.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    Icon(Icons.agriculture, size: 50, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Virtual Farm Twin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Simulate crop growth and predict yields',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Crop Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Crop',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCrop,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.agriculture,
                              color: AppConstants.primaryGreen),
                        ),
                        items: ['Rice', 'Wheat', 'Cotton', 'Sugarcane', 'Maize']
                            .map((crop) => DropdownMenuItem(
                                  value: crop,
                                  child: Text(crop),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCrop = value;
                            });
                            _resetSimulation();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Virtual Farm Visualization
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.lightBlue.withValues(alpha: 0.3),
                        Colors.green.withValues(alpha: 0.1),
                        Colors.brown.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background - Sky and Ground
                      Positioned.fill(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(), // Sky
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.brown.withValues(alpha: 0.3),
                              ), // Ground
                            ),
                          ],
                        ),
                      ),

                      // Crop Visualization
                      Center(
                        child: _buildCropVisualization(),
                      ),

                      // Growth Stage Indicator
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Stage: ${growthStages[currentGrowthStage]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Progress Indicator
                      if (isSimulating)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: LinearProgressIndicator(
                            value: _growthAnimation.value,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppConstants.accentGreen),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Growth Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Growth Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                          'Current Stage', growthStages[currentGrowthStage]),
                      _buildInfoRow('Days to Harvest',
                          '${120 - (currentGrowthStage * 20)} days'),
                      _buildInfoRow('Expected Yield',
                          '${2500 + (currentGrowthStage * 100)} kg/ha'),
                      _buildInfoRow('Water Requirement',
                          '${500 + (currentGrowthStage * 50)} liters'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Control Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: isSimulating ? 'Simulating...' : 'Start Simulation',
                      onPressed: isSimulating ? null : _startSimulation,
                      isLoading: isSimulating,
                      icon: Icons.play_arrow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Reset',
                      onPressed: _resetSimulation,
                      backgroundColor: AppConstants.greyColor,
                      icon: Icons.refresh,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropVisualization() {
    double height = 20 + (currentGrowthStage * 15.0);
    Color color =
        Color.lerp(Colors.brown, Colors.green, currentGrowthStage / 6.0) ??
            Colors.green;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Crop plant
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: height,
          width: 8 + (currentGrowthStage * 2.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // Ground line
        Container(
          height: 4,
          width: 60,
          color: Colors.brown,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.greyColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppConstants.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
