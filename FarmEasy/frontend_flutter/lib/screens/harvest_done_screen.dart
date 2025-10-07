import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/soil_condition.dart';
import '../providers/soil_condition_provider.dart';
import '../utils/constants.dart';

class HarvestDoneScreen extends StatefulWidget {
  final Map<String, String>? preFillData;

  const HarvestDoneScreen({super.key, this.preFillData});

  @override
  State<HarvestDoneScreen> createState() => _HarvestDoneScreenState();
}

class _HarvestDoneScreenState extends State<HarvestDoneScreen> {
  final _formKey = GlobalKey<FormState>();

  String _crop = 'Rice';
  String _season = 'Kharif';
  int _year = DateTime.now().year;
  final _areaController = TextEditingController();
  final _yieldController = TextEditingController();
  final _costController = TextEditingController();
  final _revenueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _preFillForm();
  }

  @override
  void dispose() {
    _areaController.dispose();
    _yieldController.dispose();
    _costController.dispose();
    _revenueController.dispose();
    super.dispose();
  }

  void _preFillForm() {
    final data = widget.preFillData;
    if (data == null) return;
    if (data['crop'] != null && data['crop']!.isNotEmpty) {
      _crop = data['crop']!;
    }
    if (data['yield'] != null) {
      _yieldController.text = data['yield']!;
    }
    if (data['area'] != null) {
      _areaController.text = data['area']!;
    }
    if (data['expectedProfit'] != null) {
      final expectedProfit = double.tryParse(data['expectedProfit']!) ?? 0;
      final estimatedRevenue = expectedProfit * 1.5;
      final estimatedCost =
          (estimatedRevenue - expectedProfit).clamp(0, double.infinity);
      _revenueController.text = estimatedRevenue.toStringAsFixed(0);
      _costController.text = estimatedCost.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Harvest'),
        backgroundColor: AppConstants.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppConstants.primaryGreen),
                      SizedBox(width: 8),
                      Text('Harvest Details',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _cropDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _seasonDropdown()),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _yearDropdown()),
                    const SizedBox(width: 12),
                    Expanded(
                        child:
                            _numberField('Area (ha)', _areaController, 'ha')),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: _numberField(
                            'Yield (tons)', _yieldController, 't')),
                    const SizedBox(width: 12),
                    Expanded(
                        child:
                            _numberField('Total Cost', _costController, '₹')),
                  ]),
                  const SizedBox(height: 16),
                  _numberField('Total Revenue', _revenueController, '₹'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitHarvest,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryGreen),
                      child: const Text('Save Harvest',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cropDropdown() {
    const crops = ['Rice', 'Wheat', 'Corn', 'Mustard', 'Pulses'];
    return DropdownButtonFormField<String>(
      initialValue: _crop,
      decoration: const InputDecoration(
          labelText: 'Crop', border: OutlineInputBorder()),
      items:
          crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) => setState(() => _crop = v ?? 'Rice'),
    );
  }

  Widget _seasonDropdown() {
    const seasons = ['Kharif', 'Rabi', 'Zaid'];
    return DropdownButtonFormField<String>(
      initialValue: _season,
      decoration: const InputDecoration(
          labelText: 'Season', border: OutlineInputBorder()),
      items: seasons
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) => setState(() => _season = v ?? 'Kharif'),
    );
  }

  Widget _yearDropdown() {
    final years = List.generate(6, (i) => DateTime.now().year - i);
    return DropdownButtonFormField<int>(
      initialValue: _year,
      decoration: const InputDecoration(
          labelText: 'Year', border: OutlineInputBorder()),
      items: years
          .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
          .toList(),
      onChanged: (v) => setState(() => _year = v ?? DateTime.now().year),
    );
  }

  Widget _numberField(String label, TextEditingController c, String suffix) {
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (v == null || v.isEmpty) return '$label is required';
        final clean = v.replaceAll(',', '');
        if (double.tryParse(clean) == null) return 'Enter valid number';
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
              final clean = value.replaceAll(',', '');
              final numVal = double.tryParse(clean);
              if (numVal != null && numVal >= 1000) {
                final formatted = _formatNumberWithCommas(numVal);
                if (formatted != value) {
                  c.value = TextEditingValue(
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

  String _formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,##,##0.##');
    return formatter.format(number);
  }

  Future<void> _submitHarvest() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<SoilConditionProvider>();

    final cost = double.parse(_costController.text.replaceAll(',', ''));
    final revenue = double.parse(_revenueController.text.replaceAll(',', ''));
    final entry = HarvestEntry(
      crop: _crop,
      season: _season,
      year: _year,
      area: double.parse(_areaController.text),
      yieldTons: double.parse(_yieldController.text),
      cost: cost,
      revenue: revenue,
      profit: revenue - cost,
    );

    // Simple heuristic to update soil: after legume/pulses, boost nitrogen slightly
    final current = provider.soilCondition;
    SoilCondition? updated;
    if (current != null) {
      var n = current.nitrogen;
      if (_crop.toLowerCase().contains('pulse')) {
        n += 10; // boost N fixing
      }
      // Reduce nutrients a bit due to harvest
      updated = current.copyWith(
        nitrogen: (n - 2).clamp(0, 9999).toDouble(),
        phosphorus: (current.phosphorus - 1).clamp(0, 9999).toDouble(),
        potassium: (current.potassium - 1).clamp(0, 9999).toDouble(),
        lastUpdated: DateTime.now(),
      );
    }

    await provider.addHarvest(entry, updatedSoil: updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Harvest saved successfully')),
    );
    Navigator.pop(context);
  }
}
