import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/data_persistence_service.dart';
import '../widgets/custom_button.dart';
import '../models/marketplace_models.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data, now strongly typed
  final List<MarketplaceItem> _availableProducts = [
    MarketplaceItem(
      id: '1',
      cropName: 'Rice',
      sellerName: 'Rajesh Kumar',
      quantityKg: 500,
      pricePerKg: 30,
      location: 'Punjab',
      quality: 'Grade A',
      harvestDate: DateTime(2025, 1, 15),
    ),
    MarketplaceItem(
      id: '2',
      cropName: 'Wheat',
      sellerName: 'Suresh Patel',
      quantityKg: 800,
      pricePerKg: 25,
      location: 'Haryana',
      quality: 'Grade A+',
      harvestDate: DateTime(2025, 2, 1),
    ),
    MarketplaceItem(
      id: '3',
      cropName: 'Cotton',
      sellerName: 'Mahesh Singh',
      quantityKg: 200,
      pricePerKg: 45,
      location: 'Gujarat',
      quality: 'Premium',
      harvestDate: DateTime(2025, 1, 20),
    ),
  ];

  // My Listings (owned by current user)
  final List<MarketplaceItem> _myListings = [];

  // Orders history
  final List<OrderItem> _orders = [];

  // Simple form state for creating a listing
  String? _sellCrop;
  String? _sellQuality;
  final TextEditingController _qtyCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final _sellFormKey = GlobalKey<FormState>();
  DateTime? _sellHarvestDate;
  String _sellLocation = 'Punjab';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPersisted();
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPersisted() async {
    try {
      final listings = await DataPersistenceService.loadMarketplaceListings();
      final orders = await DataPersistenceService.loadMarketplaceOrders();
      if (!mounted) return;
      setState(() {
        _myListings
          ..clear()
          ..addAll(listings);
        _orders
          ..clear()
          ..addAll(orders);
      });
    } catch (e) {
      // non-fatal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Marketplace', style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Buy Crops', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'My Listings', icon: Icon(Icons.store)),
            Tab(text: 'My Orders', icon: Icon(Icons.receipt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuyCropsTab(),
          _buildMyListingsTab(),
          _buildMyOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildBuyCropsTab() {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search crops...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppConstants.primaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppConstants.greyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppConstants.primaryGreen, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_list,
                    color: AppConstants.primaryGreen),
                style: IconButton.styleFrom(
                  backgroundColor:
                      AppConstants.lightGreen.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),

        // Products List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _availableProducts.length,
            itemBuilder: (context, index) {
              final product = _availableProducts[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(MarketplaceItem product) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.cropName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textDark,
                      ),
                    ),
                    Text(
                      'by ${product.sellerName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.greyColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.accentGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.quality,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Product Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.scale,
                    'Quantity',
                    '${product.quantityKg} kg',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.currency_rupee,
                    'Price',
                    '₹${product.pricePerKg}/kg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.location_on,
                    'Location',
                    product.location,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.calendar_today,
                    'Harvest',
                    _fmtDate(product.harvestDate),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Total Price and Buy Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Value',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.greyColor,
                      ),
                    ),
                    Text(
                      '₹${(product.totalValue).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  text: 'Buy Now',
                  onPressed: () => _showBuyDialog(product),
                  icon: Icons.shopping_cart,
                  width: 120,
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppConstants.primaryGreen),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.greyColor,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppConstants.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyListingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [AppConstants.primaryGreen, AppConstants.accentGreen],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.store, size: 50, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'My Listings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage your crops listed for sale',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Create Listing Form
          _buildCreateListingForm(),

          const SizedBox(height: 24),

          if (_myListings.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No listings yet. Create your first listing above.',
                  style: TextStyle(color: AppConstants.greyColor),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _myListings.length,
              itemBuilder: (context, index) {
                final item = _myListings[index];
                return _buildMyListingCard(item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCreateListingForm() {
    return Form(
      key: _sellFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Listing',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textDark,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _sellCrop,
            decoration: InputDecoration(
              labelText: 'Select Crop',
              prefixIcon: const Icon(Icons.agriculture,
                  color: AppConstants.primaryGreen),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const ['Rice', 'Wheat', 'Cotton', 'Sugarcane', 'Maize']
                .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                .toList(),
            onChanged: (v) => setState(() => _sellCrop = v),
            validator: (v) =>
                v == null || v.isEmpty ? 'Please select crop' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity (kg)',
              prefixIcon:
                  const Icon(Icons.scale, color: AppConstants.primaryGreen),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n <= 0) return 'Enter valid quantity';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Price per kg (₹)',
              prefixIcon: const Icon(Icons.currency_rupee,
                  color: AppConstants.primaryGreen),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n <= 0) return 'Enter valid price';
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _sellQuality,
            decoration: InputDecoration(
              labelText: 'Quality Grade',
              prefixIcon:
                  const Icon(Icons.star, color: AppConstants.primaryGreen),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const ['Grade A+', 'Grade A', 'Grade B', 'Premium']
                .map((grade) =>
                    DropdownMenuItem(value: grade, child: Text(grade)))
                .toList(),
            onChanged: (v) => setState(() => _sellQuality = v),
            validator: (v) => v == null || v.isEmpty ? 'Select quality' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sellLocation,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    prefixIcon: const Icon(Icons.location_on,
                        color: AppConstants.primaryGreen),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const ['Punjab', 'Haryana', 'Gujarat', 'Maharashtra']
                      .map((loc) =>
                          DropdownMenuItem(value: loc, child: Text(loc)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _sellLocation = v ?? _sellLocation),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _sellHarvestDate ?? now,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 2),
                    );
                    if (picked != null) {
                      setState(() => _sellHarvestDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Harvest Date',
                      prefixIcon: const Icon(Icons.calendar_month,
                          color: AppConstants.primaryGreen),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _sellHarvestDate == null
                          ? 'Select date'
                          : _fmtDate(_sellHarvestDate!),
                      style: const TextStyle(color: AppConstants.textDark),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'List for Sale',
              onPressed: _createListing,
              icon: Icons.add_business,
              width: 160,
              height: 44,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyListingCard(MarketplaceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.cropName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Qty: ${item.quantityKg} kg • ₹${item.pricePerKg}/kg',
                        style: const TextStyle(color: AppConstants.greyColor)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.isActive
                        ? Colors.green.shade100
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(item.isActive ? 'Active' : 'Closed',
                      style: TextStyle(
                          color: item.isActive
                              ? Colors.green.shade900
                              : Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _buildDetailItem(
                        Icons.location_on, 'Location', item.location)),
                Expanded(
                    child: _buildDetailItem(Icons.calendar_today, 'Harvest',
                        _fmtDate(item.harvestDate))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ₹${item.totalValue.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryGreen)),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Mark as Sold',
                      onPressed:
                          item.isActive ? () => _markListingSold(item) : null,
                      icon: const Icon(Icons.check_circle,
                          color: AppConstants.primaryGreen),
                    ),
                    IconButton(
                      tooltip: 'Delete Listing',
                      onPressed: () => _deleteListing(item),
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyOrdersTab() {
    if (_orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: AppConstants.greyColor),
            SizedBox(height: 16),
            Text('No Orders Yet',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark)),
            SizedBox(height: 8),
            Text('Your purchase and sale history will appear here',
                style: TextStyle(fontSize: 16, color: AppConstants.greyColor),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final o = _orders[i];
        final isPurchase = o.type == OrderType.purchase;
        final color = isPurchase ? Colors.blue : AppConstants.primaryGreen;
        final icon = isPurchase ? Icons.shopping_bag : Icons.sell;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color)),
            title: Text('${o.cropName} • ₹${o.pricePerKg}/kg'),
            subtitle: Text(
                '${isPurchase ? 'From' : 'To'}: ${o.counterpartyName} • Qty: ${o.quantityKg} kg\n${_fmtDate(o.date)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(isPurchase ? 'Purchase' : 'Sale',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                Text('₹${o.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Crop Type'),
              items: ['All', 'Rice', 'Wheat', 'Cotton', 'Sugarcane']
                  .map((crop) =>
                      DropdownMenuItem(value: crop, child: Text(crop)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Location'),
              items: ['All', 'Punjab', 'Haryana', 'Gujarat', 'Maharashtra']
                  .map((location) =>
                      DropdownMenuItem(value: location, child: Text(location)))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog(MarketplaceItem product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buy ${product.cropName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farmer: ${product.sellerName}'),
            Text('Quantity: ${product.quantityKg} kg'),
            Text('Price: ₹${product.pricePerKg}/kg'),
            Text('Total: ₹${(product.totalValue).toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            const Text(
              'This transaction will be recorded on blockchain for transparency.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchase(product);
            },
            child: const Text('Confirm Purchase'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(MarketplaceItem product) {
    // Add a purchase order locally and persist
    final order = OrderItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: OrderType.purchase,
      cropName: product.cropName,
      counterpartyName: product.sellerName,
      quantityKg: product.quantityKg,
      pricePerKg: product.pricePerKg,
      date: DateTime.now(),
    );
    setState(() {
      _orders.add(order);
    });
    DataPersistenceService.saveMarketplaceOrders(_orders);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Purchase successful! Transaction recorded on blockchain 🔐'),
        backgroundColor: AppConstants.primaryGreen,
      ),
    );
  }

  void _createListing() {
    if (!_sellFormKey.currentState!.validate() || _sellHarvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the listing form')),
      );
      return;
    }
    final qty = double.parse(_qtyCtrl.text);
    final price = double.parse(_priceCtrl.text);
    final newItem = MarketplaceItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cropName: _sellCrop!,
      sellerName: 'You',
      quantityKg: qty,
      pricePerKg: price,
      location: _sellLocation,
      quality: _sellQuality!,
      harvestDate: _sellHarvestDate!,
      isActive: true,
    );
    setState(() {
      _myListings.add(newItem);
      _availableProducts.add(newItem);
      _sellCrop = null;
      _sellQuality = null;
      _qtyCtrl.clear();
      _priceCtrl.clear();
      _sellHarvestDate = null;
    });
    DataPersistenceService.saveMarketplaceListings(_myListings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Listing created! 📈'),
          backgroundColor: AppConstants.primaryGreen),
    );
  }

  void _markListingSold(MarketplaceItem item) {
    setState(() {
      final idx = _myListings.indexWhere((e) => e.id == item.id);
      if (idx != -1) {
        final closed = _myListings[idx].copyWith(isActive: false);
        _myListings[idx] = closed;
        _orders.add(
          OrderItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            type: OrderType.sale,
            cropName: closed.cropName,
            counterpartyName: 'Buyer XYZ',
            quantityKg: closed.quantityKg,
            pricePerKg: closed.pricePerKg,
            date: DateTime.now(),
          ),
        );
      }
    });
    DataPersistenceService.saveMarketplaceListings(_myListings);
    DataPersistenceService.saveMarketplaceOrders(_orders);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Marked as sold ✅'),
          backgroundColor: AppConstants.primaryGreen),
    );
  }

  void _deleteListing(MarketplaceItem item) {
    setState(() {
      _myListings.removeWhere((e) => e.id == item.id);
    });
    DataPersistenceService.saveMarketplaceListings(_myListings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Listing deleted'), backgroundColor: Colors.redAccent),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
