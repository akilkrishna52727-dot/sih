class Harvester {
  final String id;
  final String name;
  final String businessName;
  final String ownerName;
  final String phoneNumber;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final List<String> services; // 'harvesting', 'threshing', 'transport'
  final List<String> crops; // 'wheat', 'rice', 'corn', etc.
  final List<HarvesterEquipment> equipment;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isAvailable;
  final String? imageUrl;
  final Map<String, String> businessHours;
  final double pricePerAcre;
  final String priceUnit; // 'per_acre', 'per_hour', 'per_day'
  final double serviceRadius; // in km
  final String established;
  final String description;
  final int totalJobsCompleted;
  final List<String> certifications;
  final bool emergencyService;
  final String preferredSeason;

  const Harvester({
    required this.id,
    required this.name,
    required this.businessName,
    required this.ownerName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.services,
    required this.crops,
    required this.equipment,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isAvailable,
    this.imageUrl,
    required this.businessHours,
    required this.pricePerAcre,
    required this.priceUnit,
    required this.serviceRadius,
    required this.established,
    required this.description,
    required this.totalJobsCompleted,
    required this.certifications,
    required this.emergencyService,
    required this.preferredSeason,
  });

  factory Harvester.fromJson(Map<String, dynamic> json) {
    return Harvester(
      id: json['id'] as String,
      name: json['name'] as String,
      businessName: json['business_name'] as String,
      ownerName: json['owner_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      services: List<String>.from(json['services'] as List<dynamic>),
      crops: List<String>.from(json['crops'] as List<dynamic>),
      equipment: (json['equipment'] as List<dynamic>)
          .map((e) => HarvesterEquipment.fromJson(e as Map<String, dynamic>))
          .toList(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      isVerified: json['is_verified'] as bool,
      isAvailable: json['is_available'] as bool,
      imageUrl: json['image_url'] as String?,
      businessHours: Map<String, String>.from(
          (json['business_hours'] as Map).map((k, v) => MapEntry('$k', '$v'))),
      pricePerAcre: (json['price_per_acre'] as num).toDouble(),
      priceUnit: json['price_unit'] as String,
      serviceRadius: (json['service_radius'] as num).toDouble(),
      established: json['established'] as String,
      description: json['description'] as String,
      totalJobsCompleted: json['total_jobs_completed'] as int,
      certifications:
          List<String>.from(json['certifications'] as List<dynamic>),
      emergencyService: json['emergency_service'] as bool,
      preferredSeason: json['preferred_season'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_name': businessName,
      'owner_name': ownerName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'services': services,
      'crops': crops,
      'equipment': equipment.map((e) => e.toJson()).toList(),
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'image_url': imageUrl,
      'business_hours': businessHours,
      'price_per_acre': pricePerAcre,
      'price_unit': priceUnit,
      'service_radius': serviceRadius,
      'established': established,
      'description': description,
      'total_jobs_completed': totalJobsCompleted,
      'certifications': certifications,
      'emergency_service': emergencyService,
      'preferred_season': preferredSeason,
    };
  }
}

class HarvesterEquipment {
  final String id;
  final String name;
  final String type; // 'combine_harvester', 'reaper', 'thresher'
  final String brand;
  final String model;
  final int yearOfManufacture;
  final String capacity;
  final bool isWorking;
  final DateTime? lastMaintenance;
  final List<String> suitableCrops;

  const HarvesterEquipment({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.model,
    required this.yearOfManufacture,
    required this.capacity,
    required this.isWorking,
    this.lastMaintenance,
    required this.suitableCrops,
  });

  factory HarvesterEquipment.fromJson(Map<String, dynamic> json) {
    return HarvesterEquipment(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      yearOfManufacture: json['year_of_manufacture'] as int,
      capacity: json['capacity'] as String,
      isWorking: json['is_working'] as bool,
      lastMaintenance: json['last_maintenance'] != null
          ? DateTime.parse(json['last_maintenance'] as String)
          : null,
      suitableCrops: List<String>.from(json['suitable_crops'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'brand': brand,
      'model': model,
      'year_of_manufacture': yearOfManufacture,
      'capacity': capacity,
      'is_working': isWorking,
      'last_maintenance': lastMaintenance?.toIso8601String(),
      'suitable_crops': suitableCrops,
    };
  }
}

class HarvestBooking {
  final String id;
  final String harvesterId;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String cropType;
  final double farmSize;
  final String farmLocation;
  final DateTime preferredDate;
  final DateTime? confirmedDate;
  final String
      status; // 'pending', 'confirmed', 'in_progress', 'completed', 'cancelled'
  final double estimatedCost;
  final double? finalCost;
  final String? specialRequirements;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double? farmerRating;
  final String? farmerReview;

  const HarvestBooking({
    required this.id,
    required this.harvesterId,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.cropType,
    required this.farmSize,
    required this.farmLocation,
    required this.preferredDate,
    this.confirmedDate,
    required this.status,
    required this.estimatedCost,
    this.finalCost,
    this.specialRequirements,
    required this.createdAt,
    this.completedAt,
    this.farmerRating,
    this.farmerReview,
  });

  factory HarvestBooking.fromJson(Map<String, dynamic> json) {
    return HarvestBooking(
      id: json['id'] as String,
      harvesterId: json['harvester_id'] as String,
      farmerId: json['farmer_id'] as String,
      farmerName: json['farmer_name'] as String,
      farmerPhone: json['farmer_phone'] as String,
      cropType: json['crop_type'] as String,
      farmSize: (json['farm_size'] as num).toDouble(),
      farmLocation: json['farm_location'] as String,
      preferredDate: DateTime.parse(json['preferred_date'] as String),
      confirmedDate: json['confirmed_date'] != null
          ? DateTime.parse(json['confirmed_date'] as String)
          : null,
      status: json['status'] as String,
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      finalCost: (json['final_cost'] as num?)?.toDouble(),
      specialRequirements: json['special_requirements'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      farmerRating: (json['farmer_rating'] as num?)?.toDouble(),
      farmerReview: json['farmer_review'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'harvester_id': harvesterId,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'farmer_phone': farmerPhone,
      'crop_type': cropType,
      'farm_size': farmSize,
      'farm_location': farmLocation,
      'preferred_date': preferredDate.toIso8601String(),
      'confirmed_date': confirmedDate?.toIso8601String(),
      'status': status,
      'estimated_cost': estimatedCost,
      'final_cost': finalCost,
      'special_requirements': specialRequirements,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'farmer_rating': farmerRating,
      'farmer_review': farmerReview,
    };
  }
}
