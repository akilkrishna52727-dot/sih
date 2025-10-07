import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/virtual_farm_provider.dart';
import '../utils/constants.dart';
import 'virtual_farm_simulation_screen.dart';
import 'virtual_farm_list_screen.dart';

class VirtualFarmSetupScreen extends StatefulWidget {
  const VirtualFarmSetupScreen({super.key});

  @override
  State<VirtualFarmSetupScreen> createState() => _VirtualFarmSetupScreenState();
}

class _VirtualFarmSetupScreenState extends State<VirtualFarmSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _landSizeController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = true;

  String _selectedCrop = 'Rice';
  String _selectedLandUnit = 'hectares';
  String _selectedState = '';
  String _selectedDistrict = '';
  DateTime _plantingDate = DateTime.now();
  final List<String> _cropOptions = const [
    'Rice',
    'Wheat',
    'Corn',
    'Cotton',
    'Sugarcane',
    'Tomato'
  ];
  final List<String> _landUnits = const ['hectares', 'acres', 'cents'];
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
  void initState() {
    super.initState();
    _checkExistingFarms();
  }

  Future<void> _checkExistingFarms() async {
    try {
      final provider = context.read<VirtualFarmProvider>();
      await provider.loadUserFarms();
      if (!mounted) return;
      if (provider.farms.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VirtualFarmListScreen(farms: provider.farms),
          ),
        );
        return;
      }
    } catch (e) {
      // ignore, fallback to form
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _landSizeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VirtualFarmProvider>();
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Virtual Farm Twin'),
          backgroundColor: AppConstants.primaryGreen,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your farms...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Farm Twin Setup'),
        backgroundColor: AppConstants.primaryGreen,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                          const Icon(Icons.eco, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('Create Your Virtual Farm 🌱',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        'Simulate your farm operations and predict outcomes',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Land Size',
                        hintText: 'Enter farm size',
                        prefixIcon: const Icon(Icons.landscape),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
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
              const SizedBox(height: 16),
              _buildSectionTitle('Farm Location'),
              DropdownButtonFormField<String>(
                initialValue: _selectedState.isEmpty ? null : _selectedState,
                decoration: InputDecoration(
                  labelText: 'Select State',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => (value == null || value.isEmpty)
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
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please select a district'
                      : null,
                  items: (_stateDistricts[_selectedState] ?? [])
                      .map((district) => DropdownMenuItem(
                          value: district, child: Text(district)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedDistrict = value!),
                ),
              const SizedBox(height: 24),
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
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  items: _cropOptions
                      .map((crop) =>
                          DropdownMenuItem(value: crop, child: Text(crop)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCrop = value!),
                ),
              ),
              const SizedBox(height: 24),
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
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Planting Date',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                              '${_plantingDate.day}/${_plantingDate.month}/${_plantingDate.year}',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _createVirtualFarm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Create Virtual Farm',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What you\'ll get:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('- Real-time crop growth simulation'),
                    Text('- Harvest time and yield predictions'),
                    Text('- Profit forecasts and risk analysis'),
                    Text('- Climate impact assessments'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Future<void> _selectPlantingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _plantingDate = picked);
  }

  Future<void> _createVirtualFarm() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<VirtualFarmProvider>();
    final landSizeInput = double.parse(_landSizeController.text);
    final landSizeHa = _convertToHectares(landSizeInput, _selectedLandUnit);
    final location = _selectedDistrict.isNotEmpty && _selectedState.isNotEmpty
        ? '$_selectedDistrict, $_selectedState'
        : _locationController.text;
    final success = await provider.createVirtualFarm(
      landSize: landSizeHa,
      cropType: _selectedCrop,
      location: location,
      plantingDate: _plantingDate,
    );
    if (!mounted) return;
    if (success && provider.currentFarm != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VirtualFarmSimulationScreen(virtualFarm: provider.currentFarm!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.error ?? 'Failed to create virtual farm')),
      );
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
}
