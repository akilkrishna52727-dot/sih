import 'package:flutter/material.dart';

/// Marketplace item listed by a user for sale
class MarketplaceItem {
  final String id;
  final String cropName;
  final String sellerName;
  final double quantityKg; // quantity in kilograms
  final double pricePerKg; // price in INR per kg
  final String location;
  final String quality;
  final DateTime harvestDate;
  final bool isActive; // false if sold or withdrawn

  const MarketplaceItem({
    required this.id,
    required this.cropName,
    required this.sellerName,
    required this.quantityKg,
    required this.pricePerKg,
    required this.location,
    required this.quality,
    required this.harvestDate,
    this.isActive = true,
  });

  double get totalValue => quantityKg * pricePerKg;

  MarketplaceItem copyWith({
    String? id,
    String? cropName,
    String? sellerName,
    double? quantityKg,
    double? pricePerKg,
    String? location,
    String? quality,
    DateTime? harvestDate,
    bool? isActive,
  }) {
    return MarketplaceItem(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      sellerName: sellerName ?? this.sellerName,
      quantityKg: quantityKg ?? this.quantityKg,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      location: location ?? this.location,
      quality: quality ?? this.quality,
      harvestDate: harvestDate ?? this.harvestDate,
      isActive: isActive ?? this.isActive,
    );
  }

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      cropName: json['crop_name'] as String? ??
          json['cropName'] as String? ??
          'Unknown',
      sellerName: json['farmer_name'] as String? ??
          json['seller_name'] as String? ??
          'Unknown',
      quantityKg: (json['quantity'] as num?)?.toDouble() ??
          (json['quantityKg'] as num?)?.toDouble() ??
          0,
      pricePerKg: (json['price'] as num?)?.toDouble() ??
          (json['pricePerKg'] as num?)?.toDouble() ??
          0,
      location: json['location'] as String? ?? 'Unknown',
      quality: json['quality'] as String? ?? 'N/A',
      harvestDate: _parseDate(json['harvest_date'] ?? json['harvestDate']),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_name': cropName,
      'farmer_name': sellerName,
      'quantity': quantityKg,
      'price': pricePerKg,
      'location': location,
      'quality': quality,
      'harvest_date': harvestDate.toIso8601String().substring(0, 10),
      'is_active': isActive,
    };
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }
}

/// Order direction
enum OrderType { purchase, sale }

/// An order record representing either a purchase (you bought) or sale (you sold)
class OrderItem {
  final String id;
  final OrderType type;
  final String cropName;
  final String counterpartyName; // seller if purchase, buyer if sale
  final double quantityKg;
  final double pricePerKg;
  final DateTime date;

  const OrderItem({
    required this.id,
    required this.type,
    required this.cropName,
    required this.counterpartyName,
    required this.quantityKg,
    required this.pricePerKg,
    required this.date,
  });

  double get total => quantityKg * pricePerKg;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final t = (json['type'] ?? json['order_type'] ?? 'purchase').toString();
    return OrderItem(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      type: t.toLowerCase().contains('sale')
          ? OrderType.sale
          : OrderType.purchase,
      cropName: json['crop_name'] as String? ??
          json['cropName'] as String? ??
          'Unknown',
      counterpartyName: json['counterparty_name'] as String? ??
          json['buyer_name'] as String? ??
          json['seller_name'] as String? ??
          'Unknown',
      quantityKg: (json['quantity'] as num?)?.toDouble() ??
          (json['quantityKg'] as num?)?.toDouble() ??
          0,
      pricePerKg: (json['price'] as num?)?.toDouble() ??
          (json['pricePerKg'] as num?)?.toDouble() ??
          0,
      date: MarketplaceItem._parseDate(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'crop_name': cropName,
      'counterparty_name': counterpartyName,
      'quantity': quantityKg,
      'price': pricePerKg,
      'date': date.toIso8601String(),
    };
  }
}
