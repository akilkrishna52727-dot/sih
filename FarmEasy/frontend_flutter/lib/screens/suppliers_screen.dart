import 'package:flutter/material.dart';
import '../models/supplier_models.dart';
import '../services/supplier_service.dart';
import '../utils/constants.dart';
import '../widgets/supplier_card.dart';
import 'supplier_details_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  List<Supplier> _allSuppliers = [];
  List<Supplier> _filteredSuppliers = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  bool _onlineOnly = false;
  bool _verifiedOnly = false;
  bool _deliveryOnly = false;

  final List<String> _categories = [
    'all',
    'seeds',
    'fertilizers',
    'pesticides',
    'equipment',
    'organic',
    'irrigation'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSuppliers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      final supplierService = SupplierService();
      final suppliers = await supplierService.getAllSuppliers();

      setState(() {
        _allSuppliers = suppliers;
        _filteredSuppliers = suppliers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading suppliers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agricultural Suppliers'),
        backgroundColor: AppConstants.primaryGreen,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.store), text: 'All Suppliers'),
            Tab(icon: Icon(Icons.eco), text: 'Seeds'),
            Tab(icon: Icon(Icons.science), text: 'Fertilizers'),
            Tab(icon: Icon(Icons.build), text: 'Equipment'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSuppliersTab('all'),
                _buildSuppliersTab('seeds'),
                _buildSuppliersTab('fertilizers'),
                _buildSuppliersTab('equipment'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSupplierDialog,
        backgroundColor: AppConstants.primaryGreen,
        icon: const Icon(Icons.add_business, color: Colors.white),
        label:
            const Text('Add Supplier', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _filterSuppliers,
            decoration: InputDecoration(
              hintText: 'Search suppliers, products, location...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSuppliers('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickFilterChip('Verified Only', _verifiedOnly, (value) {
                  setState(() => _verifiedOnly = value);
                  _applyFilters();
                }),
                const SizedBox(width: 8),
                _buildQuickFilterChip('Home Delivery', _deliveryOnly, (value) {
                  setState(() => _deliveryOnly = value);
                  _applyFilters();
                }),
                const SizedBox(width: 8),
                _buildQuickFilterChip('Online Store', _onlineOnly, (value) {
                  setState(() => _onlineOnly = value);
                  _applyFilters();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(
      String label, bool isSelected, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onChanged,
      selectedColor: AppConstants.primaryGreen.withValues(alpha: 0.2),
      checkmarkColor: AppConstants.primaryGreen,
    );
  }

  Widget _buildSuppliersTab(String category) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final suppliers = category == 'all'
        ? _filteredSuppliers
        : _filteredSuppliers
            .where((s) => s.categories.contains(category))
            .toList();

    if (suppliers.isEmpty) {
      return _buildEmptyState(category);
    }

    return RefreshIndicator(
      onRefresh: _loadSuppliers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          return SupplierCard(
            supplier: suppliers[index],
            onTap: () => _navigateToSupplierDetails(suppliers[index]),
            onCall: () => _callSupplier(suppliers[index]),
            onFavorite: () => _toggleFavorite(suppliers[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No ${category == 'all' ? 'suppliers' : '$category suppliers'} found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria or add a new supplier',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddSupplierDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Supplier'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'seeds':
        return Icons.eco;
      case 'fertilizers':
        return Icons.science;
      case 'pesticides':
        return Icons.bug_report;
      case 'equipment':
        return Icons.build;
      case 'organic':
        return Icons.nature;
      case 'irrigation':
        return Icons.water;
      default:
        return Icons.store;
    }
  }

  void _filterSuppliers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuppliers = List.from(_allSuppliers);
      } else {
        _filteredSuppliers = _allSuppliers.where((supplier) {
          final searchLower = query.toLowerCase();
          return supplier.name.toLowerCase().contains(searchLower) ||
              supplier.businessName.toLowerCase().contains(searchLower) ||
              supplier.city.toLowerCase().contains(searchLower) ||
              supplier.products.any(
                  (product) => product.toLowerCase().contains(searchLower));
        }).toList();
      }
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      var filtered = List<Supplier>.from(_filteredSuppliers);

      if (_verifiedOnly) {
        filtered = filtered.where((s) => s.isVerified).toList();
      }

      if (_deliveryOnly) {
        filtered = filtered.where((s) => s.homeDelivery).toList();
      }

      if (_onlineOnly) {
        filtered = filtered.where((s) => s.isOnline).toList();
      }

      _filteredSuppliers = filtered;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Suppliers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Category:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _categories
                    .map((category) => FilterChip(
                          label: Text(_getCategoryDisplayName(category)),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Minimum Rating:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'all';
                          _verifiedOnly = false;
                          _deliveryOnly = false;
                          _onlineOnly = false;
                        });
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'All Categories';
      case 'seeds':
        return 'Seeds';
      case 'fertilizers':
        return 'Fertilizers';
      case 'pesticides':
        return 'Pesticides';
      case 'equipment':
        return 'Equipment';
      case 'organic':
        return 'Organic Products';
      case 'irrigation':
        return 'Irrigation';
      default:
        return category;
    }
  }

  void _navigateToSupplierDetails(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierDetailsScreen(supplier: supplier),
      ),
    );
  }

  void _callSupplier(Supplier supplier) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${supplier.name}...')),
    );
  }

  void _toggleFavorite(Supplier supplier) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to favorites')),
    );
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Supplier'),
        content: const Text(
            'Would you like to register your business as a supplier or recommend a supplier?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSupplierRegistrationForm();
            },
            child: const Text('Register Business'),
          ),
        ],
      ),
    );
  }

  void _showSupplierRegistrationForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Supplier registration form coming soon!')),
    );
  }
}
