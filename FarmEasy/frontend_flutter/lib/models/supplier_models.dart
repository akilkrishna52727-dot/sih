// Models for Suppliers feature

class Supplier {
  final String id;
  final String name;
  final String businessName;
  final String contactPerson;
  final String phoneNumber;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final List<String> categories;
  final List<String> products;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isOnline;
  final String? imageUrl;
  final Map<String, String> businessHours;
  final List<String> certifications;
  final bool homeDelivery;
  final double deliveryRadius; // in km
  final String established;
  final String description;

  const Supplier({
    required this.id,
    required this.name,
    required this.businessName,
    required this.contactPerson,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.categories,
    required this.products,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isOnline,
    this.imageUrl,
    required this.businessHours,
    required this.certifications,
    required this.homeDelivery,
    required this.deliveryRadius,
    required this.established,
    required this.description,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      businessName: json['business_name'] as String,
      contactPerson: json['contact_person'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      categories: List<String>.from(json['categories'] as List<dynamic>),
      products: List<String>.from(json['products'] as List<dynamic>),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      isVerified: json['is_verified'] as bool,
      isOnline: json['is_online'] as bool,
      imageUrl: json['image_url'] as String?,
      businessHours: Map<String, String>.from(
          (json['business_hours'] as Map).map((k, v) => MapEntry('$k', '$v'))),
      certifications:
          List<String>.from(json['certifications'] as List<dynamic>),
      homeDelivery: json['home_delivery'] as bool,
      deliveryRadius: (json['delivery_radius'] as num).toDouble(),
      established: json['established'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_name': businessName,
      'contact_person': contactPerson,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'categories': categories,
      'products': products,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_online': isOnline,
      'image_url': imageUrl,
      'business_hours': businessHours,
      'certifications': certifications,
      'home_delivery': homeDelivery,
      'delivery_radius': deliveryRadius,
      'established': established,
      'description': description,
    };
  }
}

class SupplierProduct {
  final String id;
  final String supplierId;
  final String name;
  final String category;
  final String brand;
  final double price;
  final String unit;
  final String description;
  final List<String> imageUrls;
  final bool inStock;
  final int stockQuantity;
  final double minOrderQuantity;
  final String? specifications;
  final DateTime? expiryDate;
  final double discount;

  const SupplierProduct({
    required this.id,
    required this.supplierId,
    required this.name,
    required this.category,
    required this.brand,
    required this.price,
    required this.unit,
    required this.description,
    required this.imageUrls,
    required this.inStock,
    required this.stockQuantity,
    required this.minOrderQuantity,
    this.specifications,
    this.expiryDate,
    required this.discount,
  });

  factory SupplierProduct.fromJson(Map<String, dynamic> json) {
    return SupplierProduct(
      id: json['id'] as String,
      supplierId: json['supplier_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      description: json['description'] as String,
      imageUrls: List<String>.from(json['image_urls'] as List<dynamic>),
      inStock: json['in_stock'] as bool,
      stockQuantity: json['stock_quantity'] as int,
      minOrderQuantity: (json['min_order_quantity'] as num).toDouble(),
      specifications: json['specifications'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      discount: (json['discount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'name': name,
      'category': category,
      'brand': brand,
      'price': price,
      'unit': unit,
      'description': description,
      'image_urls': imageUrls,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'min_order_quantity': minOrderQuantity,
      'specifications': specifications,
      'expiry_date': expiryDate?.toIso8601String(),
      'discount': discount,
    };
  }
}

class SupplierReview {
  final String id;
  final String supplierId;
  final String userId;
  final String userName;
  final double rating;
  final String review;
  final DateTime createdAt;
  final List<String> pros;
  final List<String> cons;

  const SupplierReview({
    required this.id,
    required this.supplierId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.review,
    required this.createdAt,
    required this.pros,
    required this.cons,
  });

  factory SupplierReview.fromJson(Map<String, dynamic> json) {
    return SupplierReview(
      id: json['id'] as String,
      supplierId: json['supplier_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      pros: List<String>.from(json['pros'] as List<dynamic>),
      cons: List<String>.from(json['cons'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
      'pros': pros,
      'cons': cons,
    };
  }
}
