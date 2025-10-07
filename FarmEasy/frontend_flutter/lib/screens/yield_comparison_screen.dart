import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/soil_condition_provider.dart';
import '../models/soil_condition.dart';
import '../utils/constants.dart';
import '../widgets/yield_chart.dart';
import 'login_screen.dart';

class YieldComparisonScreen extends StatefulWidget {
  const YieldComparisonScreen({super.key});

  @override
  State<YieldComparisonScreen> createState() => _YieldComparisonScreenState();
}

class _YieldComparisonScreenState extends State<YieldComparisonScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _yieldController = TextEditingController();
  final _areaController = TextEditingController();
  final _costController = TextEditingController();
  final _revenueController = TextEditingController();

  String _selectedSeason = 'Kharif';
  int _selectedYear = DateTime.now().year;
  String _selectedCrop = 'Rice';

  // Filters
  String? _filterCrop; // null = all
  String? _filterSeason; // null = all

  final List<String> _seasons = const ['Kharif', 'Rabi', 'Zaid'];
  final List<String> _crops = const [
    'Rice',
    'Wheat',
    'Corn',
    'Cotton',
    'Sugarcane',
    'Tomato'
  ];

  @override
  void initState() {
    super.initState();
    // No local sample data; records come from provider persistence.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yield Comparison'),
        backgroundColor: AppConstants.primaryGreen,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.analytics,
                          color: Colors.orange.shade700, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compare Your Harvest Results',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Track your farming progress across seasons and years',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Filters row
              _buildFilters(),

              const SizedBox(height: 16),

              // Add New Harvest Record
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.add_circle,
                              color: AppConstants.primaryGreen),
                          SizedBox(width: 8),
                          Text(
                            'Add New Harvest Record',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildCropDropdown()),
                                const SizedBox(width: 12),
                                Expanded(child: _buildSeasonDropdown()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildYearDropdown()),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _buildTextField('Area (hectares)',
                                        _areaController, 'ha')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildTextField('Yield (tons)',
                                        _yieldController, 'tons')),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _buildTextField(
                                        'Total Cost', _costController, '₹')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                                'Total Revenue', _revenueController, '₹'),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _addHarvestRecord,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.primaryGreen),
                                child: const Text('Add Record',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Harvest Records List
              if (_filteredRecords(context).isNotEmpty) ...[
                const Text(
                  'Harvest History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._filteredRecords(context)
                    .reversed
                    .map((record) => _buildHarvestCard(record)),
              ],

              const SizedBox(height: 24),

              // Yield Comparison Chart
              if (_filteredRecords(context).length > 1) _buildYieldChart(),

              const SizedBox(height: 24),

              // Analytics Summary
              if (_filteredRecords(context).isNotEmpty)
                _buildAnalyticsSummary(),
            ],
          ),
        ),
      ),
    );
  }

  List<HarvestEntry> _filteredRecords(BuildContext context) {
    final all = context.watch<SoilConditionProvider>().harvestHistory;
    return all.where((r) {
      final byCrop = _filterCrop == null || r.crop == _filterCrop;
      final bySeason = _filterSeason == null || r.season == _filterSeason;
      return byCrop && bySeason;
    }).toList();
  }

  Widget _buildFilters() {
    // Build options from current data to keep list relevant
    final all = context.watch<SoilConditionProvider>().harvestHistory;
    final crops = [
      'All',
      ...{for (final r in all) r.crop}
    ];
    final seasons = [
      'All',
      ...{for (final r in all) r.season}
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _filterCrop ?? 'All',
                decoration: const InputDecoration(
                  labelText: 'Filter by Crop',
                  border: OutlineInputBorder(),
                ),
                items: crops
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(
                    () => _filterCrop = v == null || v == 'All' ? null : v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _filterSeason ?? 'All',
                decoration: const InputDecoration(
                  labelText: 'Filter by Season',
                  border: OutlineInputBorder(),
                ),
                items: seasons
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(
                    () => _filterSeason = v == null || v == 'All' ? null : v),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCrop,
      decoration: const InputDecoration(
        labelText: 'Crop Type',
        border: OutlineInputBorder(),
      ),
      items: _crops
          .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
          .toList(),
      onChanged: (value) => setState(() => _selectedCrop = value!),
    );
  }

  Widget _buildSeasonDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedSeason,
      decoration: const InputDecoration(
        labelText: 'Season',
        border: OutlineInputBorder(),
      ),
      items: _seasons
          .map((season) => DropdownMenuItem(value: season, child: Text(season)))
          .toList(),
      onChanged: (value) => setState(() => _selectedSeason = value!),
    );
  }

  Widget _buildYearDropdown() {
    final years = List.generate(10, (index) => DateTime.now().year - index);
    return DropdownButtonFormField<int>(
      initialValue: _selectedYear,
      decoration: const InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(),
      ),
      items: years
          .map((year) =>
              DropdownMenuItem(value: year, child: Text(year.toString())))
          .toList(),
      onChanged: (value) => setState(() => _selectedYear = value!),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String suffix) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        final cleanValue = value.replaceAll(',', '');
        if (double.tryParse(cleanValue) == null) {
          return 'Enter valid number';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      inputFormatters: suffix == '₹'
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : null,
      onChanged: suffix == '₹'
          ? (value) {
              // Optional: format with commas as user types
              final clean = value.replaceAll(',', '');
              final numVal = double.tryParse(clean);
              if (numVal != null && numVal >= 1000) {
                final formatted = _formatNumberWithCommas(numVal);
                if (formatted != value) {
                  controller.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
              }
            }
          : null,
    );
  }

  Widget _buildHarvestCard(HarvestEntry record) {
    final profitLabel = record.profit >= 0 ? 'Profit ✓' : 'Loss ✗';
    final profitColor =
        record.profit >= 0 ? Colors.green.shade700 : Colors.red.shade700;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${record.crop} - ${record.season} ${record.year}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.profit >= 0
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profitLabel,
                    style: TextStyle(
                        color: profitColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildMetricTile('Yield', '${record.yieldTons} tons',
                        Icons.agriculture)),
                Expanded(
                    child: _buildMetricTile(
                        'Area', '${record.area} ha', Icons.landscape)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _buildMetricTile(
                        'Revenue',
                        '₹${_formatCurrency(record.revenue)}',
                        Icons.currency_rupee)),
                Expanded(
                    child: _buildMetricTile(
                        'Profit',
                        '₹${_formatCurrency(record.profit.abs())}',
                        record.profit >= 0
                            ? Icons.trending_up
                            : Icons.trending_down)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, color: AppConstants.primaryGreen, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildYieldChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yield Comparison Chart',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: YieldChart(harvestRecords: _filteredRecords(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSummary() {
    final records = _filteredRecords(context);
    final avgYield = records.map((r) => r.yieldTons).reduce((a, b) => a + b) /
        records.length;
    final totalProfit = records.map((r) => r.profit).reduce((a, b) => a + b);
    final bestYear = records.reduce((a, b) => a.profit > b.profit ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildSummaryTile(
                        'Avg Yield', '${avgYield.toStringAsFixed(1)} tons')),
                Expanded(
                    child: _buildSummaryTile(
                        'Total ${totalProfit >= 0 ? 'Profit' : 'Loss'}',
                        '₹${_formatCurrency(totalProfit.abs())}')),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryTile('Best Performance',
                '${bestYear.crop} ${bestYear.season} ${bestYear.year}'),
          ],
        ),
      ),
    );
  }

  // Currency helpers for Indian number system
  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)} K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  String _formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,##,##0.##');
    return formatter.format(number);
  }

  Widget _buildSummaryTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  void _addHarvestRecord() {
    if (_formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();

      if (userProvider.isGuest || !userProvider.isLoggedIn) {
        _showLoginDialog();
        return;
      }

      final cost = double.parse(_costController.text.replaceAll(',', ''));
      final revenue = double.parse(_revenueController.text.replaceAll(',', ''));

      final record = HarvestEntry(
        crop: _selectedCrop,
        season: _selectedSeason,
        year: _selectedYear,
        area: double.parse(_areaController.text),
        yieldTons: double.parse(_yieldController.text),
        cost: cost,
        revenue: revenue,
        profit: revenue - cost,
      );

      // Save via provider so it's persisted and visible across app
      context.read<SoilConditionProvider>().addHarvest(record);
      _clearForm();

      final profit = record.profit;
      final msg = profit >= 0
          ? 'Harvest added! Profit: ₹${_formatCurrency(profit.abs())}'
          : 'Harvest added! Loss: ₹${_formatCurrency(profit.abs())}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: profit >= 0 ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _yieldController.clear();
    _areaController.clear();
    _costController.clear();
    _revenueController.clear();
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to save your harvest records.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
