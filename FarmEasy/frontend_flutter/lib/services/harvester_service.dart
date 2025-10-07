import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/harvester_models.dart';

class HarvesterService {
  static const _harvestersKey = 'harvesters_data_v1';
  static const _bookingsKey = 'harvest_bookings_v1';

  Future<List<Harvester>> getHarvesters() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_harvestersKey);
    if (raw == null) {
      final seeded = _seedSampleHarvesters();
      await prefs.setString(
        _harvestersKey,
        jsonEncode(seeded.map((h) => h.toJson()).toList()),
      );
      return seeded;
    }
    final List decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => Harvester.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertHarvesters(List<Harvester> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _harvestersKey,
      jsonEncode(list.map((h) => h.toJson()).toList()),
    );
  }

  Future<List<HarvestBooking>> getBookings({String? farmerId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bookingsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw) as List;
    final bookings = decoded
        .map((e) => HarvestBooking.fromJson(e as Map<String, dynamic>))
        .toList();
    if (farmerId != null) {
      return bookings.where((b) => b.farmerId == farmerId).toList();
    }
    return bookings;
  }

  Future<void> saveBookings(List<HarvestBooking> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _bookingsKey,
      jsonEncode(list.map((b) => b.toJson()).toList()),
    );
  }

  Future<HarvestBooking> createBooking({
    required Harvester harvester,
    required String farmerId,
    required String farmerName,
    required String farmerPhone,
    required String cropType,
    required double farmSize,
    required String farmLocation,
    required DateTime preferredDate,
    String? specialRequirements,
    bool emergency = false,
  }) async {
    final estimatedCost = _estimateCost(
      pricePerAcre: harvester.pricePerAcre,
      farmSize: farmSize,
      emergency: emergency,
    );

    final booking = HarvestBooking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      harvesterId: harvester.id,
      farmerId: farmerId,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      cropType: cropType,
      farmSize: farmSize,
      farmLocation: farmLocation,
      preferredDate: preferredDate,
      confirmedDate: null,
      status: emergency ? 'pending_emergency' : 'pending',
      estimatedCost: estimatedCost,
      finalCost: null,
      specialRequirements: specialRequirements,
      createdAt: DateTime.now(),
      completedAt: null,
      farmerRating: null,
      farmerReview: null,
    );

    final existing = await getBookings();
    final updated = [...existing, booking];
    await saveBookings(updated);
    return booking;
  }

  Future<HarvestBooking?> updateBookingStatus(
    String bookingId,
    String status, {
    DateTime? confirmedDate,
    double? finalCost,
  }) async {
    final bookings = await getBookings();
    final idx = bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return null;
    final current = bookings[idx];
    final updated = HarvestBooking(
      id: current.id,
      harvesterId: current.harvesterId,
      farmerId: current.farmerId,
      farmerName: current.farmerName,
      farmerPhone: current.farmerPhone,
      cropType: current.cropType,
      farmSize: current.farmSize,
      farmLocation: current.farmLocation,
      preferredDate: current.preferredDate,
      confirmedDate: confirmedDate ?? current.confirmedDate,
      status: status,
      estimatedCost: current.estimatedCost,
      finalCost: finalCost ?? current.finalCost,
      specialRequirements: current.specialRequirements,
      createdAt: current.createdAt,
      completedAt: status == 'completed' ? DateTime.now() : current.completedAt,
      farmerRating: current.farmerRating,
      farmerReview: current.farmerReview,
    );
    bookings[idx] = updated;
    await saveBookings(bookings);
    return updated;
  }

  Future<HarvestBooking?> rateBooking(
    String bookingId,
    double rating,
    String review,
  ) async {
    final bookings = await getBookings();
    final idx = bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return null;
    final current = bookings[idx];
    final updated = HarvestBooking(
      id: current.id,
      harvesterId: current.harvesterId,
      farmerId: current.farmerId,
      farmerName: current.farmerName,
      farmerPhone: current.farmerPhone,
      cropType: current.cropType,
      farmSize: current.farmSize,
      farmLocation: current.farmLocation,
      preferredDate: current.preferredDate,
      confirmedDate: current.confirmedDate,
      status: current.status,
      estimatedCost: current.estimatedCost,
      finalCost: current.finalCost,
      specialRequirements: current.specialRequirements,
      createdAt: current.createdAt,
      completedAt: current.completedAt,
      farmerRating: rating,
      farmerReview: review,
    );
    bookings[idx] = updated;
    await saveBookings(bookings);
    return updated;
  }

  // Helpers
  double _estimateCost({
    required double pricePerAcre,
    required double farmSize,
    required bool emergency,
  }) {
    double base = pricePerAcre * farmSize;
    if (emergency) base *= 1.25; // 25% surcharge for emergency
    return double.parse(base.toStringAsFixed(2));
  }

  List<Harvester> _seedSampleHarvesters() {
    return [
      Harvester(
        id: 'h1',
        name: 'Ravi Kumar',
        businessName: 'GreenField Harvesting Co.',
        ownerName: 'Ravi Kumar',
        phoneNumber: '+91 9876543210',
        email: 'contact@greenfield.example',
        address: 'NH 44, Near Market Yard',
        city: 'Karnal',
        state: 'Haryana',
        pincode: '132001',
        services: ['harvesting', 'threshing', 'transport'],
        crops: ['wheat', 'rice', 'corn', 'mustard'],
        equipment: [
          HarvesterEquipment(
            id: 'e1',
            name: 'John Deere Combine',
            type: 'combine_harvester',
            brand: 'John Deere',
            model: 'S450',
            yearOfManufacture: 2020,
            capacity: '25 acres/day',
            isWorking: true,
            lastMaintenance: DateTime.now().subtract(const Duration(days: 30)),
            suitableCrops: ['wheat', 'rice'],
          ),
        ],
        rating: 4.6,
        reviewCount: 128,
        isVerified: true,
        isAvailable: true,
        imageUrl:
            'https://images.unsplash.com/photo-1599058917212-d750089bc3eb?w=800',
        businessHours: const {
          'mon': '08:00-18:00',
          'tue': '08:00-18:00',
          'wed': '08:00-18:00',
          'thu': '08:00-18:00',
          'fri': '08:00-18:00',
          'sat': '08:00-14:00',
          'sun': 'closed',
        },
        pricePerAcre: 1800,
        priceUnit: 'per_acre',
        serviceRadius: 40,
        established: '2018',
        description:
            'Experienced team with modern combine harvesters providing efficient harvesting, threshing and transport.',
        totalJobsCompleted: 420,
        certifications: ['AgriSafe', 'ISO 9001'],
        emergencyService: true,
        preferredSeason: 'Rabi',
      ),
      Harvester(
        id: 'h2',
        name: 'Suman Yadav',
        businessName: 'Yadav Agro Services',
        ownerName: 'Suman Yadav',
        phoneNumber: '+91 9988776655',
        email: 'support@yadavagro.example',
        address: 'Village Post Rampur',
        city: 'Varanasi',
        state: 'Uttar Pradesh',
        pincode: '221001',
        services: ['harvesting', 'reaping'],
        crops: ['rice', 'sugarcane', 'paddy'],
        equipment: [
          HarvesterEquipment(
            id: 'e2',
            name: 'Mahindra Reaper',
            type: 'reaper',
            brand: 'Mahindra',
            model: 'Arjun 605',
            yearOfManufacture: 2019,
            capacity: '18 acres/day',
            isWorking: true,
            lastMaintenance: DateTime.now().subtract(const Duration(days: 45)),
            suitableCrops: ['rice', 'paddy'],
          ),
        ],
        rating: 4.3,
        reviewCount: 76,
        isVerified: false,
        isAvailable: true,
        imageUrl:
            'https://images.unsplash.com/photo-1596040033229-9f3a5b75a5d3?w=800',
        businessHours: const {
          'mon': '09:00-17:00',
          'tue': '09:00-17:00',
          'wed': '09:00-17:00',
          'thu': '09:00-17:00',
          'fri': '09:00-17:00',
          'sat': '10:00-14:00',
          'sun': 'closed',
        },
        pricePerAcre: 1500,
        priceUnit: 'per_acre',
        serviceRadius: 25,
        established: '2016',
        description:
            'Reliable reaping services specializing in paddy and rice fields with trained operators.',
        totalJobsCompleted: 260,
        certifications: ['FarmerFirst'],
        emergencyService: false,
        preferredSeason: 'Kharif',
      ),
    ];
  }

  // Query utilities
  Future<List<Harvester>> search({
    String? query,
    String? city,
    String? state,
    String? service,
    String? crop,
    bool? emergencyOnly,
    bool? availableOnly,
    double? minRating,
  }) async {
    final list = await getHarvesters();
    return list.where((h) {
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final hit = h.name.toLowerCase().contains(q) ||
            h.businessName.toLowerCase().contains(q) ||
            h.ownerName.toLowerCase().contains(q) ||
            h.city.toLowerCase().contains(q) ||
            h.state.toLowerCase().contains(q) ||
            h.services.any((s) => s.toLowerCase().contains(q)) ||
            h.crops.any((c) => c.toLowerCase().contains(q));
        if (!hit) return false;
      }
      if (city != null &&
          city.isNotEmpty &&
          h.city.toLowerCase() != city.toLowerCase()) {
        return false;
      }
      if (state != null &&
          state.isNotEmpty &&
          h.state.toLowerCase() != state.toLowerCase()) {
        return false;
      }
      if (service != null &&
          service.isNotEmpty &&
          !h.services.contains(service)) {
        return false;
      }
      if (crop != null && crop.isNotEmpty && !h.crops.contains(crop)) {
        return false;
      }
      if (emergencyOnly == true && !h.emergencyService) return false;
      if (availableOnly == true && !h.isAvailable) return false;
      if (minRating != null && h.rating < minRating) return false;
      return true;
    }).toList();
  }
}
