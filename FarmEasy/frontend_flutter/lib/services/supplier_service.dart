import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/supplier_models.dart';

class SupplierService {
  static const String _suppliersKey = 'suppliers_data';

  Future<List<Supplier>> getAllSuppliers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final suppliersString = prefs.getString(_suppliersKey);

      if (suppliersString != null) {
        final List<dynamic> suppliersJson = jsonDecode(suppliersString);
        return suppliersJson
            .map((json) => Supplier.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Load sample data for demo
        final sampleSuppliers = _generateSampleSuppliers();
        await _saveSuppliers(sampleSuppliers);
        return sampleSuppliers;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading suppliers: $e');
      return _generateSampleSuppliers();
    }
  }

  Future<void> _saveSuppliers(List<Supplier> suppliers) async {
    final prefs = await SharedPreferences.getInstance();
    final suppliersJson = suppliers.map((s) => s.toJson()).toList();
    await prefs.setString(_suppliersKey, jsonEncode(suppliersJson));
  }

  List<Supplier> _generateSampleSuppliers() {
    return [
      const Supplier(
        id: '1',
        name: 'Rajesh Kumar',
        businessName: 'AgriBegri Seeds & Fertilizers',
        contactPerson: 'Rajesh Kumar',
        phoneNumber: '+91-9876543210',
        email: 'rajesh@agribegri.com',
        address: 'Shop 15, Mandi Complex',
        city: 'Delhi',
        state: 'Delhi',
        pincode: '110001',
        categories: ['seeds', 'fertilizers', 'pesticides'],
        products: ['Hybrid Rice Seeds', 'DAP Fertilizer', 'Urea', 'Neem Oil'],
        rating: 4.5,
        reviewCount: 128,
        isVerified: true,
        isOnline: true,
        imageUrl: null,
        businessHours: {
          'monday': '9:00 AM - 7:00 PM',
          'tuesday': '9:00 AM - 7:00 PM',
          'sunday': 'Closed'
        },
        certifications: ['Fertilizer License', 'Seed Certification'],
        homeDelivery: true,
        deliveryRadius: 25.0,
        established: '2015',
        description:
            'Leading supplier of quality seeds, fertilizers and crop protection products in Delhi region.',
      ),
      const Supplier(
        id: '2',
        name: 'Priya Singh',
        businessName: 'Green Valley Agro Center',
        contactPerson: 'Priya Singh',
        phoneNumber: '+91-9876543211',
        email: 'priya@greenvalley.com',
        address: 'Main Road, Agricultural Market',
        city: 'Ludhiana',
        state: 'Punjab',
        pincode: '141001',
        categories: ['seeds', 'equipment', 'organic'],
        products: [
          'Wheat Seeds',
          'Tractor Parts',
          'Organic Manure',
          'Spray Pumps'
        ],
        rating: 4.8,
        reviewCount: 95,
        isVerified: true,
        isOnline: false,
        imageUrl: null,
        businessHours: {
          'monday': '8:00 AM - 8:00 PM',
          'sunday': '10:00 AM - 2:00 PM'
        },
        certifications: ['Organic Certification', 'ISO 9001'],
        homeDelivery: true,
        deliveryRadius: 50.0,
        established: '2010',
        description:
            'Specialized in organic farming inputs and modern agricultural equipment.',
      ),
      const Supplier(
        id: '3',
        name: 'Mukesh Patel',
        businessName: 'Patel Fertilizers & Chemicals',
        contactPerson: 'Mukesh Patel',
        phoneNumber: '+91-9876543212',
        email: 'mukesh@patel-agro.com',
        address: 'Industrial Area, Plot 45',
        city: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '380001',
        categories: ['fertilizers', 'pesticides', 'irrigation'],
        products: [
          'NPK Fertilizer',
          'Fungicides',
          'Drip Irrigation',
          'Micronutrients'
        ],
        rating: 4.2,
        reviewCount: 203,
        isVerified: true,
        isOnline: true,
        imageUrl: null,
        businessHours: {
          'monday': '9:00 AM - 6:00 PM',
          'saturday': '9:00 AM - 1:00 PM'
        },
        certifications: ['Pesticide License', 'Water Management Cert'],
        homeDelivery: true,
        deliveryRadius: 100.0,
        established: '2008',
        description:
            'Manufacturer and distributor of fertilizers, pesticides and irrigation systems.',
      ),
      const Supplier(
        id: '4',
        name: 'Suresh Yadav',
        businessName: 'Modern Agri Equipment',
        contactPerson: 'Suresh Yadav',
        phoneNumber: '+91-9876543213',
        email: 'suresh@modern-agri.com',
        address: 'Highway Road, Equipment Market',
        city: 'Indore',
        state: 'Madhya Pradesh',
        pincode: '452001',
        categories: ['equipment', 'irrigation'],
        products: ['Tractors', 'Harvesters', 'Tillers', 'Solar Pumps'],
        rating: 4.6,
        reviewCount: 67,
        isVerified: false,
        isOnline: false,
        imageUrl: null,
        businessHours: {'monday': '10:00 AM - 7:00 PM', 'sunday': 'Closed'},
        certifications: ['Equipment Dealer License'],
        homeDelivery: false,
        deliveryRadius: 0.0,
        established: '2018',
        description:
            'Authorized dealer of tractors, harvesters and modern farming equipment.',
      ),
      const Supplier(
        id: '5',
        name: 'Dr. Anita Sharma',
        businessName: 'Organic Farm Solutions',
        contactPerson: 'Dr. Anita Sharma',
        phoneNumber: '+91-9876543214',
        email: 'anita@organic-solutions.com',
        address: 'University Road, Research Center',
        city: 'Bangalore',
        state: 'Karnataka',
        pincode: '560001',
        categories: ['organic', 'seeds'],
        products: [
          'Organic Fertilizers',
          'Bio-pesticides',
          'Heirloom Seeds',
          'Compost'
        ],
        rating: 4.9,
        reviewCount: 156,
        isVerified: true,
        isOnline: true,
        imageUrl: null,
        businessHours: {
          'monday': '9:00 AM - 5:00 PM',
          'saturday': '9:00 AM - 2:00 PM'
        },
        certifications: ['Organic India Certification', 'FSSAI License'],
        homeDelivery: true,
        deliveryRadius: 30.0,
        established: '2012',
        description:
            'Premium organic farming solutions backed by scientific research and quality assurance.',
      ),
    ];
  }

  Future<List<Supplier>> searchSuppliers(String query,
      [String? category]) async {
    final allSuppliers = await getAllSuppliers();

    return allSuppliers.where((supplier) {
      final q = query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          supplier.name.toLowerCase().contains(q) ||
          supplier.businessName.toLowerCase().contains(q) ||
          supplier.city.toLowerCase().contains(q) ||
          supplier.products.any((product) => product.toLowerCase().contains(q));

      final matchesCategory = category == null ||
          category == 'all' ||
          supplier.categories.contains(category);

      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<List<Supplier>> getSuppliersByLocation(String city,
      [double? radius]) async {
    final allSuppliers = await getAllSuppliers();

    // Simple city matching - in real app, you'd use geolocation
    return allSuppliers
        .where((supplier) =>
            supplier.city.toLowerCase() == city.toLowerCase() ||
            (supplier.homeDelivery && supplier.deliveryRadius >= (radius ?? 0)))
        .toList();
  }
}
