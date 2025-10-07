class Transaction {
  final int? id;
  final int farmerId;
  final int? buyerId;
  final int cropId;
  final double quantity;
  final double price;
  final String status;
  final String? blockchainHash;
  final DateTime? createdAt;
  final String? cropName;
  final String? farmerName;
  final String? buyerName;

  Transaction({
    this.id,
    required this.farmerId,
    this.buyerId,
    required this.cropId,
    required this.quantity,
    required this.price,
    required this.status,
    this.blockchainHash,
    this.createdAt,
    this.cropName,
    this.farmerName,
    this.buyerName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      farmerId: json['farmer_id'],
      buyerId: json['buyer_id'],
      cropId: json['crop_id'],
      quantity: json['quantity']?.toDouble() ?? 0.0,
      price: json['price']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      blockchainHash: json['blockchain_hash'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      cropName: json['crop_name'],
      farmerName: json['farmer_name'],
      buyerName: json['buyer_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmer_id': farmerId,
      'buyer_id': buyerId,
      'crop_id': cropId,
      'quantity': quantity,
      'price': price,
      'status': status,
    };
  }

  double get totalAmount => quantity * price;
}
