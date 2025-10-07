import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/crop_recommendation_model.dart';
import 'crop_recommendation_results_screen.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import '../models/soil_condition.dart';
import '../models/crop_recommendation_history.dart';
import '../services/data_persistence_service.dart';
import 'crop_recommendation_history_screen.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _phController = TextEditingController();
  final _organicCarbonController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _phController.dispose();
    _organicCarbonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
        backgroundColor: AppConstants.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: _showRecommendationHistory,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                color: Colors.green.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.eco,
                          color: AppConstants.primaryGreen, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Get AI-Powered Crop Recommendations',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(
                                'Enter your soil test parameters to get personalized crop suggestions',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recent recommendations quick access
              _buildRecentRecommendationsCard(),

              const SizedBox(height: 24),
              _buildSectionHeader('Soil Test Parameters'),
              _buildTextField('Nitrogen (N)', _nitrogenController, 'mg/kg',
                  'Available nitrogen content'),
              _buildTextField('Phosphorus (P)', _phosphorusController, 'mg/kg',
                  'Available phosphorus content'),
              _buildTextField('Potassium (K)', _potassiumController, 'mg/kg',
                  'Available potassium content'),
              _buildTextField('pH Level', _phController, '0-14 scale',
                  'Soil acidity/alkalinity level'),
              _buildTextField('Organic Carbon', _organicCarbonController, '%',
                  'Organic matter percentage'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _getRecommendations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white)),
                            SizedBox(width: 12),
                            Text('Analyzing...',
                                style: TextStyle(color: Colors.white)),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.psychology, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Get AI Recommendations',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              if (_shouldShowChart()) _buildSoilAnalysisChart(),
              const SizedBox(height: 20),
              _buildTipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRecommendationsCard() {
    return FutureBuilder<List<CropRecommendationHistory>>(
      future: DataPersistenceService.loadCropRecommendationHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final recent = snapshot.data!.take(3).toList();
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Recommendations',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: _showRecommendationHistory,
                        child: const Text('View All'),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...recent.map(_buildRecentHistoryItem),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecentHistoryItem(CropRecommendationHistory history) {
    final top = history.recommendations.isNotEmpty
        ? history.recommendations.first
        : null;
    return InkWell(
      onTap: () => _viewHistoryDetails(history),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.history,
                color: AppConstants.primaryGreen, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${history.date.day}/${history.date.month}/${history.date.year}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  if (top != null)
                    Text(
                      'Top: ${top.cropName} (${top.suitabilityScore.toInt()}%)',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  bool _shouldShowChart() {
    return _nitrogenController.text.isNotEmpty ||
        _phosphorusController.text.isNotEmpty ||
        _potassiumController.text.isNotEmpty ||
        _phController.text.isNotEmpty ||
        _organicCarbonController.text.isNotEmpty;
  }

  Widget _buildSoilAnalysisChart() {
    final soilData = {
      'Nitrogen': double.tryParse(_nitrogenController.text) ?? 0,
      'Phosphorus': double.tryParse(_phosphorusController.text) ?? 0,
      'Potassium': double.tryParse(_potassiumController.text) ?? 0,
      'pH Level': (double.tryParse(_phController.text) ?? 0) * 10,
      'Organic Carbon':
          (double.tryParse(_organicCarbonController.text) ?? 0) * 10,
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: AppConstants.primaryGreen),
                SizedBox(width: 8),
                Text('Soil Nutrient Analysis',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...soilData.entries.map((e) => _buildNutrientBar(e.key, e.value)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'This chart visualizes your soil nutrient levels. Tap "Get AI Recommendations" above for detailed crop suggestions.',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber),
                SizedBox(width: 8),
                Text('Soil Testing Tips',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text('-  Collect soil samples from multiple points in your field'),
            Text('-  Test soil during the same season each year'),
            Text('-  Avoid testing immediately after fertilizer application'),
            Text('-  Store samples in clean, dry containers'),
            Text('-  Test soil every 2-3 years for best results'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBar(String nutrient, double value) {
    final percentage = (value / 100).clamp(0.0, 1.0);
    Color barColor = AppConstants.primaryGreen;
    if (percentage < 0.3) {
      barColor = Colors.red;
    } else if (percentage < 0.6) barColor = Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text(nutrient, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10)),
              child: FractionallySizedBox(
                widthFactor: percentage,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                      color: barColor, borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String hint, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        validator: (value) {
          if (value == null || value.isEmpty) return '$label is required';
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: description,
          helperMaxLines: 2,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppConstants.primaryGreen),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _getRecommendations() async {
    if (_formKey.currentState?.validate() != true) return;
    final userProvider = context.read<UserProvider>();

    // Require authenticated user (no guest)
    if (userProvider.isGuest || !userProvider.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final soilData = {
        'nitrogen': double.parse(_nitrogenController.text),
        'phosphorus': double.parse(_phosphorusController.text),
        'potassium': double.parse(_potassiumController.text),
        'ph_level': double.parse(_phController.text),
        'organic_carbon': double.parse(_organicCarbonController.text),
      };

      final recommendations = await _generateCropRecommendations(soilData);

      // Save to history
      final soilCondition = SoilCondition(
        nitrogen: (soilData['nitrogen'] as num).toDouble(),
        phosphorus: (soilData['phosphorus'] as num).toDouble(),
        potassium: (soilData['potassium'] as num).toDouble(),
        phLevel: (soilData['ph_level'] as num).toDouble(),
        organicCarbon: (soilData['organic_carbon'] as num).toDouble(),
      );
      await _saveToHistory(soilCondition, recommendations);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropRecommendationResultsScreen(
            soilData: soilData,
            recommendations: recommendations,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToHistory(SoilCondition soilCondition,
      List<CropRecommendation> recommendations) async {
    try {
      final existing =
          await DataPersistenceService.loadCropRecommendationHistory();
      final newItem = CropRecommendationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        soilCondition: soilCondition,
        recommendations: recommendations,
        location: 'Current Location',
        notes: 'Generated from soil analysis',
      );
      existing.insert(0, newItem);
      if (existing.length > 20) {
        existing.removeRange(20, existing.length);
      }
      await DataPersistenceService.saveCropRecommendationHistory(existing);
    } catch (e) {
      // ignore errors for history saving to not block UX
    }
  }

  void _showRecommendationHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CropRecommendationHistoryScreen(),
      ),
    );
  }

  void _viewHistoryDetails(CropRecommendationHistory history) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CropRecommendationResultsScreen.fromHistory(history),
      ),
    );
  }

  Future<List<CropRecommendation>> _generateCropRecommendations(
      Map<String, dynamic> soilData) async {
    // Simulate analysis latency
    await Future.delayed(const Duration(seconds: 2));

    final List<CropRecommendation> recs = [];

    double scoreFor(String crop) {
      double score = 50.0;
      switch (crop.toLowerCase()) {
        case 'rice':
          if (soilData['ph_level'] >= 5.5 && soilData['ph_level'] <= 7.0) {
            score += 20;
          }
          if (soilData['nitrogen'] >= 40) score += 15;
          if (soilData['organic_carbon'] >= 1.0) score += 10;
          break;
        case 'wheat':
          if (soilData['ph_level'] >= 6.0 && soilData['ph_level'] <= 7.5) {
            score += 20;
          }
          if (soilData['phosphorus'] >= 20) score += 15;
          if (soilData['potassium'] >= 20) score += 10;
          break;
        case 'corn':
          if (soilData['potassium'] >= 25) score += 20;
          if (soilData['nitrogen'] >= 30) score += 15;
          if (soilData['ph_level'] >= 6.0 && soilData['ph_level'] <= 7.0) {
            score += 10;
          }
          break;
      }
      return score.clamp(0.0, 100.0);
    }

    // Rice
    if (soilData['ph_level'] >= 5.5 && soilData['ph_level'] <= 7.0) {
      recs.add(CropRecommendation(
        cropName: 'Rice',
        suitabilityScore: scoreFor('rice'),
        expectedYield: 4.2 + (soilData['nitrogen'] / 100),
        profitPotential: 'High',
        seasonality: 'Kharif',
        waterRequirement: 'High',
        riskLevel: 'Low',
        marketPrice: 2500.0,
        description: 'Suitable for your soil pH and nitrogen levels',
        requirements: [
          'pH: 5.5-7.0 (Your pH: ${soilData['ph_level']})',
          'Nitrogen: 40+ mg/kg (Your N: ${soilData['nitrogen']} mg/kg)',
          'Requires good water management',
        ],
        tips: [
          'Plant during monsoon season',
          'Maintain water levels consistently',
          'Apply organic fertilizers for better yield',
        ],
      ));
    }

    // Wheat
    if (soilData['ph_level'] >= 6.0 && soilData['ph_level'] <= 7.5) {
      recs.add(CropRecommendation(
        cropName: 'Wheat',
        suitabilityScore: scoreFor('wheat'),
        expectedYield: 3.8 + (soilData['phosphorus'] / 50),
        profitPotential: 'Medium',
        seasonality: 'Rabi',
        waterRequirement: 'Medium',
        riskLevel: 'Low',
        marketPrice: 2200.0,
        description: 'Good phosphorus levels support wheat cultivation',
        requirements: [
          'pH: 6.0-7.5 (Your pH: ${soilData['ph_level']})',
          'Phosphorus: 20+ mg/kg (Your P: ${soilData['phosphorus']} mg/kg)',
          'Well-drained soil preferred',
        ],
        tips: [
          'Sow in November-December',
          'Ensure proper drainage',
          'Monitor for pest attacks',
        ],
      ));
    }

    // Corn
    if (soilData['potassium'] >= 25) {
      recs.add(CropRecommendation(
        cropName: 'Corn',
        suitabilityScore: scoreFor('corn'),
        expectedYield: 4.0 + (soilData['potassium'] / 60),
        profitPotential: 'High',
        seasonality: 'Kharif/Rabi',
        waterRequirement: 'Medium',
        riskLevel: 'Medium',
        marketPrice: 1800.0,
        description: 'High potassium content favors corn growth',
        requirements: [
          'Potassium: 25+ mg/kg (Your K: ${soilData['potassium']} mg/kg)',
          'Organic Carbon: 1.0+ % (Your OC: ${soilData['organic_carbon']}%)',
          'Deep, well-drained soil',
        ],
        tips: [
          'Plant spacing is crucial',
          'Regular weeding required',
          'Harvest at right moisture content',
        ],
      ));
    }

    recs.sort((a, b) => b.suitabilityScore.compareTo(a.suitabilityScore));
    return recs.take(5).toList();
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
            'Please login to get personalized crop recommendations and save your analysis.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  // Notification UI removed from this screen; notifications now live in dashboard header
}
