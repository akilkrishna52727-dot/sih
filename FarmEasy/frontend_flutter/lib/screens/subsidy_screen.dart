import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/subsidy_model.dart';
import '../services/subsidy_service.dart';
import '../widgets/subsidy_eligibility_checker.dart';

class SubsidyScreen extends StatefulWidget {
  const SubsidyScreen({super.key});

  @override
  State<SubsidyScreen> createState() => _SubsidyScreenState();
}

class _SubsidyScreenState extends State<SubsidyScreen> {
  String selectedCategory = 'all';
  late List<SubsidyScheme> subsidies;

  @override
  void initState() {
    super.initState();
    subsidies = SubsidyService.getSubsidySchemes();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubsidies = selectedCategory == 'all'
        ? subsidies
        : subsidies.where((s) => s.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Subsidies',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppConstants.backgroundColor,
      body: Column(
        children: [
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              children: [
                _buildCategoryChip('all', 'All Schemes'),
                _buildCategoryChip('income_support', 'Income Support'),
                _buildCategoryChip('insurance', 'Insurance'),
                _buildCategoryChip('credit', 'Credit'),
                _buildCategoryChip('equipment', 'Equipment'),
              ],
            ),
          ),

          // Optional: quick eligibility hints
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SubsidyEligibilityChecker(
              landSize: 1.5,
              cropType: 'wheat',
              location: 'Delhi',
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredSubsidies.length,
              itemBuilder: (context, index) {
                return _buildSubsidyCard(filteredSubsidies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final selected = selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppConstants.lightGreen,
        onSelected: (_) => setState(() => selectedCategory = value),
      ),
    );
  }

  Widget _buildSubsidyCard(SubsidyScheme scheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          scheme.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(scheme.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection('Eligibility', scheme.eligibility),
                _buildInfoSection('Benefits', scheme.benefits),
                _buildInfoSection('How to Apply', scheme.applicationProcess),
                _buildInfoSection('Contact', scheme.contactInfo),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openApplicationLink(scheme),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Apply Online'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareScheme(scheme),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }

  void _openApplicationLink(SubsidyScheme scheme) {
    // TODO: Integrate url_launcher to open official portals
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening application portal...')),
    );
  }

  void _shareScheme(SubsidyScheme scheme) {
    // TODO: Integrate share_plus to share scheme details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing scheme details...')),
    );
  }
}
