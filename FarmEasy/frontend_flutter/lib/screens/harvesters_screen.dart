import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/harvester_models.dart';
import '../services/harvester_service.dart';
import '../widgets/harvester_card.dart';
import '../providers/user_provider.dart';
import 'harvester_details_screen.dart';
import 'harvest_booking_screen.dart';

class HarvestersScreen extends StatefulWidget {
  const HarvestersScreen({super.key});

  @override
  State<HarvestersScreen> createState() => _HarvestersScreenState();
}

class _HarvestersScreenState extends State<HarvestersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = HarvesterService();

  List<Harvester> _all = [];
  List<Harvester> _filtered = [];
  bool _loading = true;

  // Filters
  String _query = '';
  String _serviceFilter = '';
  String _cropFilter = '';
  bool _emergencyOnly = false;
  bool _availableOnly = true;
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _service.getHarvesters();
    setState(() {
      _all = list;
      _filtered = list;
      _loading = false;
    });
  }

  Future<void> _applyFilters() async {
    final results = await _service.search(
      query: _query,
      service: _serviceFilter.isEmpty ? null : _serviceFilter,
      crop: _cropFilter.isEmpty ? null : _cropFilter,
      emergencyOnly: _emergencyOnly,
      availableOnly: _availableOnly,
      minRating: _minRating > 0 ? _minRating : null,
    );
    setState(() => _filtered = results);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harvesters'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.agriculture), text: 'Find'),
            Tab(icon: Icon(Icons.assignment), text: 'My Bookings'),
            Tab(icon: Icon(Icons.emergency_share), text: 'Emergency'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindTab(),
          _buildBookingsTab(),
          _buildEmergencyTab(),
        ],
      ),
    );
  }

  Widget _buildFindTab() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        children: [
          _buildFilters(),
          const SizedBox(height: 8),
          if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No harvesters match your filters.')),
            ),
          ..._filtered.map(
            (h) => HarvesterCard(
              harvester: h,
              onTap: () => _openDetails(h),
              onCall: () => _call(h.phoneNumber),
              onBook: () => _openBooking(h),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search harvesters, services, crops, city…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              _query = v;
              _applyFilters();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _serviceFilter.isEmpty ? null : _serviceFilter,
                  decoration: const InputDecoration(
                    labelText: 'Service',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'harvesting', child: Text('Harvesting')),
                    DropdownMenuItem(
                        value: 'threshing', child: Text('Threshing')),
                    DropdownMenuItem(value: 'reaping', child: Text('Reaping')),
                    DropdownMenuItem(
                        value: 'transport', child: Text('Transport')),
                  ],
                  onChanged: (v) {
                    _serviceFilter = v ?? '';
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _cropFilter.isEmpty ? null : _cropFilter,
                  decoration: const InputDecoration(
                    labelText: 'Crop',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'wheat', child: Text('Wheat')),
                    DropdownMenuItem(value: 'rice', child: Text('Rice')),
                    DropdownMenuItem(value: 'corn', child: Text('Corn')),
                    DropdownMenuItem(value: 'mustard', child: Text('Mustard')),
                    DropdownMenuItem(value: 'paddy', child: Text('Paddy')),
                    DropdownMenuItem(
                        value: 'sugarcane', child: Text('Sugarcane')),
                  ],
                  onChanged: (v) {
                    _cropFilter = v ?? '';
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: _availableOnly,
                      onChanged: (v) {
                        setState(() => _availableOnly = v);
                        _applyFilters();
                      },
                    ),
                    const Text('Available now'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: _emergencyOnly,
                      onChanged: (v) {
                        setState(() => _emergencyOnly = v);
                        _applyFilters();
                      },
                    ),
                    const Text('Emergency only'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Min rating:'),
              Expanded(
                child: Slider(
                  value: _minRating,
                  onChanged: (v) {
                    setState(() => _minRating = v);
                  },
                  onChangeEnd: (_) => _applyFilters(),
                  divisions: 8,
                  min: 0,
                  max: 4,
                  label: (_minRating + 1).toStringAsFixed(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    return FutureBuilder<List<HarvestBooking>>(
      future: _service.getBookings(
          farmerId: context.read<UserProvider>().user?.id.toString()),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final bookings = snap.data!;
        if (bookings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child:
                  Text('No bookings yet. Book a harvester from the Find tab.'),
            ),
          );
        }
        return ListView.separated(
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final b = bookings[i];
            final h = _all.firstWhere(
              (x) => x.id == b.harvesterId,
              orElse: () => _all.isNotEmpty ? _all.first : _dummyHarvester(),
            );
            return ListTile(
              leading: const Icon(Icons.assignment),
              title:
                  Text('${h.businessName} • ${b.cropType} (${b.farmSize} ac)'),
              subtitle: Text(
                  'Preferred: ${_fmtDate(b.preferredDate)} • Status: ${b.status} • Est: ₹${b.estimatedCost.toStringAsFixed(0)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openDetails(h),
            );
          },
        );
      },
    );
  }

  Widget _buildEmergencyTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Harvesting',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
              'If your crop urgently needs harvesting due to weather or other issues, you can place an emergency request. A 25% surcharge may apply.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _startEmergencyRequest,
            icon: const Icon(Icons.emergency_share),
            label: const Text('Place Emergency Request'),
          ),
          const SizedBox(height: 24),
          const Text('Providers offering emergency service:'),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Harvester>>(
              future: _service.search(emergencyOnly: true, availableOnly: true),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data!;
                if (list.isEmpty) {
                  return const Center(
                      child: Text('No emergency providers right now.'));
                }
                return ListView(
                  children: list
                      .map(
                        (h) => HarvesterCard(
                          harvester: h,
                          onTap: () => _openDetails(h),
                          onCall: () => _call(h.phoneNumber),
                          onBook: () => _openBooking(h, emergency: true),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openDetails(Harvester h) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HarvesterDetailsScreen(harvester: h)),
    );
  }

  void _openBooking(Harvester h, {bool emergency = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            HarvestBookingScreen(harvester: h, emergency: emergency),
      ),
    );
  }

  void _call(String phone) {
    // Optionally integrate url_launcher for tel: links later.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Call $phone')),
    );
  }

  void _startEmergencyRequest() {
    setState(() => _tabController.index = 2);
  }

  String _fmtDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Harvester _dummyHarvester() => const Harvester(
        id: 'dummy',
        name: 'Unknown',
        businessName: 'Unknown',
        ownerName: 'Unknown',
        phoneNumber: '-',
        email: '-',
        address: '-',
        city: '-',
        state: '-',
        pincode: '-',
        services: [],
        crops: [],
        equipment: [],
        rating: 0,
        reviewCount: 0,
        isVerified: false,
        isAvailable: false,
        imageUrl: null,
        businessHours: {},
        pricePerAcre: 0,
        priceUnit: 'per_acre',
        serviceRadius: 0,
        established: '-',
        description: '-',
        totalJobsCompleted: 0,
        certifications: [],
        emergencyService: false,
        preferredSeason: '-',
      );
}
