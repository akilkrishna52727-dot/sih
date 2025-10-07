import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../providers/user_provider.dart';
import '../models/soil_test_model.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/chart_widget.dart';
import 'login_screen.dart';
import 'enhanced_results_screen.dart';

class SoilTestScreen extends StatefulWidget {
  const SoilTestScreen({super.key});

  @override
  State<SoilTestScreen> createState() => _SoilTestScreenState();
}

class _SoilTestScreenState extends State<SoilTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _phController = TextEditingController();
  final _organicCarbonController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _locationController = TextEditingController();

  // Chart visibility is derived from input values; no explicit flag needed

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _phController.dispose();
    _organicCarbonController.dispose();
    _farmSizeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Removed old basic analysis handler to keep only AI-enhanced analysis

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Crop Recommendation',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      AppConstants.primaryGreen,
                      AppConstants.accentGreen
                    ],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.science, size: 50, color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'AI-Powered Crop Recommendations',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enter your soil test values to get personalized crop recommendations',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Soil Test Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Soil Test Parameters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nitrogen Field
                  _buildSoilInputField(
                    fieldKey: const Key('soil_nitrogen'),
                    controller: _nitrogenController,
                    label: 'Nitrogen (N)',
                    hint: 'Enter nitrogen content (0-100)',
                    icon: Icons.nature,
                    validator: (value) =>
                        Validators.soilValue(value, 'Nitrogen'),
                  ),

                  const SizedBox(height: 16),

                  // Phosphorus Field
                  _buildSoilInputField(
                    fieldKey: const Key('soil_phosphorus'),
                    controller: _phosphorusController,
                    label: 'Phosphorus (P)',
                    hint: 'Enter phosphorus content (0-100)',
                    icon: Icons.science,
                    validator: (value) =>
                        Validators.soilValue(value, 'Phosphorus'),
                  ),

                  const SizedBox(height: 16),

                  // Potassium Field
                  _buildSoilInputField(
                    fieldKey: const Key('soil_potassium'),
                    controller: _potassiumController,
                    label: 'Potassium (K)',
                    hint: 'Enter potassium content (0-100)',
                    icon: Icons.local_florist,
                    validator: (value) =>
                        Validators.soilValue(value, 'Potassium'),
                  ),

                  const SizedBox(height: 16),

                  // pH Level Field
                  _buildSoilInputField(
                    fieldKey: const Key('soil_ph'),
                    controller: _phController,
                    label: 'pH Level',
                    hint: 'Enter pH level (0-14)',
                    icon: Icons.water_drop,
                    validator: Validators.phValue,
                  ),

                  const SizedBox(height: 16),

                  // Organic Carbon Field
                  _buildSoilInputField(
                    fieldKey: const Key('soil_organic_carbon'),
                    controller: _organicCarbonController,
                    label: 'Organic Carbon',
                    hint: 'Enter organic carbon content (0-5)',
                    icon: Icons.eco,
                    validator: (value) =>
                        Validators.soilValue(value, 'Organic Carbon'),
                  ),

                  const SizedBox(height: 32),

                  // Analyze with AI+ Button
                  Consumer<CropProvider>(
                    builder: (context, cropProvider, child) {
                      return CustomButton(
                        key: const Key('btn_analyze_soil_enhanced'),
                        text: 'Analyze with AI',
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            if (userProvider.isGuest) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Please login to get personalized crop recommendations.'),
                                  action: SnackBarAction(
                                    label: 'Login',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginScreen()),
                                      );
                                    },
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            setState(
                                () {}); // trigger rebuild for chart visibility

                            final soilTest = SoilTest(
                              userId: 1,
                              nitrogen: double.parse(_nitrogenController.text),
                              phosphorus:
                                  double.parse(_phosphorusController.text),
                              potassium:
                                  double.parse(_potassiumController.text),
                              phLevel: double.parse(_phController.text),
                              organicCarbon:
                                  double.parse(_organicCarbonController.text),
                            );

                            final ok = await cropProvider.analyzeSoilEnhanced(
                              soilTest,
                              farmSize: _farmSizeController.text.isEmpty
                                  ? null
                                  : double.tryParse(_farmSizeController.text),
                              location: _locationController.text.isEmpty
                                  ? null
                                  : _locationController.text,
                            );
                            if (!mounted) return;
                            if (ok) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EnhancedResultsScreen(
                                    recommendations: context
                                        .read<CropProvider>()
                                        .enhancedRecommendations,
                                    soilAnalysis: context
                                        .read<CropProvider>()
                                        .enhancedSoilAnalysis!,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(cropProvider.error ??
                                        'Enhanced analysis failed'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        isLoading: cropProvider.isLoading,
                        icon: Icons.auto_graph,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Soil Analysis Chart - show when user starts entering values
                  if (_shouldShowChart()) ...[
                    SoilAnalysisChart(
                      nitrogen: double.tryParse(_nitrogenController.text) ?? 0,
                      phosphorus:
                          double.tryParse(_phosphorusController.text) ?? 0,
                      potassium:
                          double.tryParse(_potassiumController.text) ?? 0,
                      phLevel: double.tryParse(_phController.text) ?? 0,
                      organicCarbon:
                          double.tryParse(_organicCarbonController.text) ?? 0,
                    ),
                  ],

                  // Tips Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.tips_and_updates,
                                  color: AppConstants.primaryGreen),
                              SizedBox(width: 8),
                              Text(
                                'Soil Testing Tips',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTip('🌱',
                              'Collect soil samples from multiple spots in your field'),
                          _buildTip('📏',
                              'Take samples from 6-8 inch depth for best results'),
                          _buildTip('🕐',
                              'Test soil every 2-3 years or before major crop changes'),
                          _buildTip('📋',
                              'Keep records of your soil test results for comparison'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Removed optional farm info section
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilInputField({
    Key? fieldKey,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppConstants.primaryGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.primaryGreen, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(fontSize: 14, color: AppConstants.greyColor),
            ),
          ),
        ],
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
}
