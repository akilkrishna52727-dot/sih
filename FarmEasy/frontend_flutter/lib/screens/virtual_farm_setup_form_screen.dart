import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/virtual_farm_provider.dart';
import '../utils/constants.dart';
import 'virtual_farm_simulation_screen.dart';

class VirtualFarmSetupFormScreen extends StatefulWidget {
  const VirtualFarmSetupFormScreen({super.key});

  @override
  State<VirtualFarmSetupFormScreen> createState() =>
      _VirtualFarmSetupFormScreenState();
}

class _VirtualFarmSetupFormScreenState
    extends State<VirtualFarmSetupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _landSizeController = TextEditingController();

  String _selectedCrop = 'Rice';
  String _selectedLandUnit = 'hectares';
  String _selectedState = '';
  String _selectedDistrict = '';
  DateTime _plantingDate = DateTime.now();

  final List<String> _cropOptions = [
    'Rice',
    'Wheat',
    'Corn',
    'Cotton',
    'Sugarcane',
    'Tomato'
  ];
  final List<String> _landUnits = ['hectares', 'acres', 'cents'];

  final Map<String, List<String>> _stateDistricts = const {
    'Andhra Pradesh': [
      'Visakhapatnam',
      'Vijayawada',
      'Guntur',
      'Nellore',
      'Kurnool'
    ],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'],
    'Kerala': [
      'Kochi',
      'Thiruvananthapuram',
      'Kozhikode',
      'Thrissur',
      'Kollam'
    ],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Salem',
      'Tiruchirappalli'
    ],
    'Maharashtra': ['Mumbai', 'Pune', 'Nashik', 'Aurangabad', 'Solapur'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda'],
    'Haryana': ['Gurgaon', 'Faridabad', 'Rohtak', 'Hisar', 'Panipat'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Meerut'],
  };

  @override
  void dispose() {
    _landSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Virtual Farm'),
        backgroundColor: AppConstants.primaryGreen,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppConstants.primaryGreen,
                            Colors.green.shade300
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.add, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create New Virtual Farm 🌱',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set up another farm simulation to compare different crops and strategies',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildSectionTitle('Farm Details'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _landSizeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Land size is required';
                        }
                        final size = double.tryParse(value);
                        if (size == null || size <= 0) {
                          return 'Please enter a valid land size';
                        }
                        if (size > 1000) {
                          return 'Maximum supported size is 1000 hectares';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Land Size',
                        hintText: 'Enter farm size',
                        prefixIcon: const Icon(Icons.landscape,
                            color: AppConstants.primaryGreen),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppConstants.primaryGreen),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedLandUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _landUnits
                          .map((unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedLandUnit = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Farm Location'),
              DropdownButtonFormField<String>(
                initialValue: _selectedState.isEmpty ? null : _selectedState,
                decoration: InputDecoration(
                  labelText: 'Select State',
                  prefixIcon: const Icon(Icons.location_on,
                      color: AppConstants.primaryGreen),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a state'
                    : null,
                items: _stateDistricts.keys
                    .map((state) =>
                        DropdownMenuItem(value: state, child: Text(state)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value!;
                    _selectedDistrict = '';
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedState.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue:
                      _selectedDistrict.isEmpty ? null : _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: 'Select District/City',
                    prefixIcon: const Icon(Icons.location_city,
                        color: AppConstants.primaryGreen),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a district'
                      : null,
                  items: (_stateDistricts[_selectedState] ?? [])
                      .map((district) => DropdownMenuItem(
                          value: district, child: Text(district)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedDistrict = value!),
                ),
              const SizedBox(height: 32),
              _buildSectionTitle('Crop Selection'),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCrop,
                  decoration: const InputDecoration(
                    labelText: 'Select Crop Type',
                    prefixIcon:
                        Icon(Icons.eco, color: AppConstants.primaryGreen),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  items: _cropOptions
                      .map((crop) => DropdownMenuItem(
                            value: crop,
                            child: Row(
                              children: [
                                _getCropIcon(crop),
                                const SizedBox(width: 8),
                                Text(crop),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCrop = value!),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Planting Schedule'),
              InkWell(
                onTap: _selectPlantingDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppConstants.primaryGreen),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Planting Date',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            '${_plantingDate.day}/${_plantingDate.month}/${_plantingDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _createVirtualFarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Create Virtual Farm',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Icon _getCropIcon(String crop) {
    final icons = {
      'Rice': Icons.grain,
      'Wheat': Icons.grass,
      'Corn': Icons.eco,
      'Cotton': Icons.cloud,
      'Sugarcane': Icons.local_florist,
      'Tomato': Icons.circle,
    };
    return Icon(icons[crop] ?? Icons.eco, color: AppConstants.primaryGreen);
  }

  Future<void> _selectPlantingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _plantingDate = picked);
    }
  }

  double _convertToHectares(double size, String unit) {
    switch (unit) {
      case 'acres':
        return size * 0.404686;
      case 'cents':
        return size * 0.004047;
      case 'hectares':
      default:
        return size;
    }
  }

  Future<void> _createVirtualFarm() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<VirtualFarmProvider>();

      final landSizeInHectares = _convertToHectares(
        double.parse(_landSizeController.text),
        _selectedLandUnit,
      );

      final location =
          '${_selectedDistrict.isNotEmpty ? '$_selectedDistrict, ' : ''}$_selectedState';

      final success = await provider.createVirtualFarm(
        landSize: landSizeInHectares,
        cropType: _selectedCrop,
        location: location,
        plantingDate: _plantingDate,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VirtualFarmSimulationScreen(
              virtualFarm: provider.currentFarm!,
            ),
          ),
        );
      } else if (mounted) {
        final error = provider.error ?? 'Failed to create virtual farm';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }
}
