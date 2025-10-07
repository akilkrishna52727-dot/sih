import 'package:flutter/material.dart';
import '../models/supplier_models.dart';
import '../utils/constants.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onFavorite;

  const SupplierCard({
    super.key,
    required this.supplier,
    required this.onTap,
    required this.onCall,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        AppConstants.primaryGreen.withValues(alpha: 0.1),
                    radius: 30,
                    child: supplier.imageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              supplier.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.store,
                            color: AppConstants.primaryGreen, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                supplier.businessName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (supplier.isVerified)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'VERIFIED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contact: ${supplier.contactPerson}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          '${supplier.city}, ${supplier.state}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (supplier.isOnline)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        supplier.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 8,
                          color: supplier.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < supplier.rating.floor()
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${supplier.rating.toStringAsFixed(1)} (${supplier.reviewCount} reviews)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: supplier.categories.take(4).map((category) {
                  final color = _getCategoryColor(category);
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (supplier.homeDelivery) ...[
                    const Icon(Icons.local_shipping,
                        size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text('Delivery',
                        style: TextStyle(fontSize: 11, color: Colors.green)),
                    const SizedBox(width: 12),
                  ],
                  if (supplier.isOnline) ...[
                    const Icon(Icons.shopping_cart,
                        size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    const Text('Online Store',
                        style: TextStyle(fontSize: 11, color: Colors.blue)),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    'Est. ${supplier.established}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const Icon(Icons.call, size: 16),
                      label: const Text('Call', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side:
                            const BorderSide(color: AppConstants.primaryGreen),
                        foregroundColor: AppConstants.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility,
                          size: 16, color: Colors.white),
                      label: const Text('View Details',
                          style: TextStyle(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onFavorite,
                    icon: const Icon(Icons.favorite_border, size: 20),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'seeds':
        return Colors.green;
      case 'fertilizers':
        return Colors.orange;
      case 'pesticides':
        return Colors.red;
      case 'equipment':
        return Colors.blue;
      case 'organic':
        return Colors.teal;
      case 'irrigation':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
