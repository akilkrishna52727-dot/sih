import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import '../utils/constants.dart';
import '../widgets/crop_card.dart';
import '../widgets/custom_button.dart';
import '../services/notification_service.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';
import 'subsidy_screen.dart';

class CropRecommendScreen extends StatefulWidget {
  const CropRecommendScreen({super.key});

  @override
  State<CropRecommendScreen> createState() => _CropRecommendScreenState();
}

class _CropRecommendScreenState extends State<CropRecommendScreen> {
  @override
  void initState() {
    super.initState();
    _showRecommendationNotification();
  }

  void _promptLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login to access this feature.'),
        backgroundColor: AppConstants.warningColor,
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showRecommendationNotification() {
    final cropProvider = Provider.of<CropProvider>(context, listen: false);
    if (cropProvider.recommendations.isNotEmpty) {
      final topRecommendation = cropProvider.recommendations.first;
      NotificationService().showCropRecommendation(
        topRecommendation['crop']['name'],
        topRecommendation['confidence'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Crop Recommendations',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          Consumer<UserProvider>(builder: (context, userProvider, _) {
            return IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                if (userProvider.isGuest) {
                  _promptLogin();
                } else {
                  _showRecommendationHistory();
                }
              },
            );
          })
        ],
      ),
      body: Consumer<CropProvider>(
        builder: (context, cropProvider, child) {
          if (cropProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.primaryGreen),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing your soil...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.greyColor,
                    ),
                  ),
                ],
              ),
            );
          }

          if (cropProvider.recommendations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.agriculture,
                    size: 80,
                    color: AppConstants.greyColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No recommendations yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Take a soil test to get personalized crop recommendations',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.greyColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Take Soil Test',
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.science,
                    width: 200,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🌾 Crop Recommendations',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Based on your soil analysis, here are the best crops for your field:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Soil Test Summary
                if (cropProvider.lastSoilTest != null) ...[
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
                              'Your Soil Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSoilParameter(
                                    'N',
                                    cropProvider.lastSoilTest!.nitrogen
                                        .toStringAsFixed(1),
                                    Colors.green,
                                  ),
                                ),
                                Expanded(
                                  child: _buildSoilParameter(
                                    'P',
                                    cropProvider.lastSoilTest!.phosphorus
                                        .toStringAsFixed(1),
                                    Colors.blue,
                                  ),
                                ),
                                Expanded(
                                  child: _buildSoilParameter(
                                    'K',
                                    cropProvider.lastSoilTest!.potassium
                                        .toStringAsFixed(1),
                                    Colors.orange,
                                  ),
                                ),
                                Expanded(
                                  child: _buildSoilParameter(
                                    'pH',
                                    cropProvider.lastSoilTest!.phLevel
                                        .toStringAsFixed(1),
                                    Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Recommendations List
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Recommended Crops',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textDark,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Top Recommendation (Featured)
                if (cropProvider.recommendations.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.accentGreen.withValues(alpha: 0.1),
                          Colors.transparent
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppConstants.accentGreen, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: AppConstants.accentGreen),
                              SizedBox(width: 8),
                              Text(
                                'Top Recommendation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.accentGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CropCard(
                          crop: cropProvider.recommendations.first['crop'],
                          confidence:
                              cropProvider.recommendations.first['confidence'],
                          onTap: () => _showCropDetails(
                              cropProvider.recommendations.first),
                        ),
                      ],
                    ),
                  ),
                ],

                // Other Recommendations
                ...cropProvider.recommendations.skip(1).map(
                      (recommendation) => CropCard(
                        crop: recommendation['crop'],
                        confidence: recommendation['confidence'],
                        onTap: () => _showCropDetails(recommendation),
                      ),
                    ),

                const SizedBox(height: 20),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                        return CustomButton(
                          text: 'View Subsidy Information',
                          onPressed: () {
                            if (userProvider.isGuest) {
                              _promptLogin();
                            } else {
                              _showSubsidyInfo();
                            }
                          },
                          icon: Icons.monetization_on,
                          backgroundColor: AppConstants.accentGreen,
                        );
                      }),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Get New Recommendations',
                        onPressed: () => Navigator.pop(context),
                        icon: Icons.refresh,
                        backgroundColor: AppConstants.lightGreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSoilParameter(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppConstants.textDark,
          ),
        ),
      ],
    );
  }

  void _showCropDetails(Map<String, dynamic> recommendation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppConstants.greyColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Crop details content
                Text(
                  recommendation['crop']['name'].toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark,
                  ),
                ),

                const SizedBox(height: 16),

                // Confidence badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Confidence: ${(recommendation['confidence'] * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Crop information
                _buildDetailRow('Season', recommendation['crop']['season']),
                _buildDetailRow('Expected Yield',
                    '${recommendation['crop']['expected_yield']} kg/ha'),
                _buildDetailRow('Market Price',
                    '₹${recommendation['crop']['market_price']}/kg'),
                _buildDetailRow('Temperature Range',
                    '${recommendation['crop']['min_temp']}-${recommendation['crop']['max_temp']}°C'),
                _buildDetailRow('Rainfall Requirement',
                    '${recommendation['crop']['min_rainfall']}-${recommendation['crop']['max_rainfall']}mm'),
                _buildDetailRow(
                    'Soil Type', recommendation['crop']['soil_type']),

                const SizedBox(height: 20),

                CustomButton(
                  text: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppConstants.greyColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubsidyInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubsidyScreen()),
    );
  }

  void _showRecommendationHistory() {
    // Navigate to recommendation history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recommendation history feature coming soon! 📊'),
        backgroundColor: AppConstants.primaryGreen,
      ),
    );
  }
}
