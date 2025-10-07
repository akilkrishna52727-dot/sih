import 'package:flutter/material.dart';
import '../models/supplier_models.dart';
import '../utils/constants.dart';

class SupplierDetailsScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailsScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier.businessName),
        backgroundColor: AppConstants.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareSupplier,
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSupplierHeader(),
          TabBar(
            controller: _tabController,
            labelColor: AppConstants.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppConstants.primaryGreen,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Products'),
              Tab(text: 'Reviews'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildProductsTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildSupplierHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    AppConstants.primaryGreen.withValues(alpha: 0.1),
                radius: 40,
                child: widget.supplier.imageUrl != null
                    ? ClipOval(
                        child: Image.network(widget.supplier.imageUrl!,
                            fit: BoxFit.cover),
                      )
                    : const Icon(Icons.store,
                        color: AppConstants.primaryGreen, size: 40),
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
                            widget.supplier.businessName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (widget.supplier.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'VERIFIED',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    Text('Contact: ${widget.supplier.contactPerson}'),
                    Text('${widget.supplier.city}, ${widget.supplier.state}'),
                    Text('Est. ${widget.supplier.established}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < widget.supplier.rating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                  '${widget.supplier.rating.toStringAsFixed(1)} (${widget.supplier.reviewCount} reviews)'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.supplier.isOnline ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.supplier.isOnline ? 'ONLINE' : 'OFFLINE',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.supplier.description),
          const SizedBox(height: 20),
          const Text('Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.supplier.categories
                .map((category) => Chip(
                      label: Text(category.toUpperCase()),
                      backgroundColor:
                          _getCategoryColor(category).withValues(alpha: 0.1),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text('Services',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildServiceTile(
                  Icons.local_shipping,
                  'Home Delivery',
                  widget.supplier.homeDelivery
                      ? 'Available (${widget.supplier.deliveryRadius}km)'
                      : 'Not Available'),
              _buildServiceTile(Icons.shopping_cart, 'Online Store',
                  widget.supplier.isOnline ? 'Available' : 'Not Available'),
              _buildServiceTile(Icons.verified, 'Verified Supplier',
                  widget.supplier.isVerified ? 'Yes' : 'No'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Contact Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildContactTile(
              Icons.person, 'Contact Person', widget.supplier.contactPerson),
          _buildContactTile(Icons.phone, 'Phone', widget.supplier.phoneNumber),
          _buildContactTile(Icons.email, 'Email', widget.supplier.email),
          _buildContactTile(Icons.location_on, 'Address',
              '${widget.supplier.address}, ${widget.supplier.city}'),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.supplier.products.length,
      itemBuilder: (context, index) {
        final product = widget.supplier.products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppConstants.primaryGreen.withValues(alpha: 0.1),
              child:
                  const Icon(Icons.inventory, color: AppConstants.primaryGreen),
            ),
            title: Text(product),
            subtitle:
                const Text('Contact supplier for pricing and availability'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _inquireProduct(product),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    final sampleReviews = [
      {
        'name': 'Farmer John',
        'rating': 5,
        'review': 'Excellent quality seeds and fast delivery!',
        'date': '2 days ago'
      },
      {
        'name': 'Priya S.',
        'rating': 4,
        'review': 'Good products but delivery was delayed.',
        'date': '1 week ago'
      },
      {
        'name': 'Rajesh K.',
        'rating': 5,
        'review': 'Very reliable supplier. Highly recommended.',
        'date': '2 weeks ago'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sampleReviews.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Write a Review',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _writeReview,
                    child: const Text('Add Review'),
                  ),
                ],
              ),
            ),
          );
        }

        final review = sampleReviews[index - 1];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(review['date'] as String,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < (review['rating'] as int)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(review['review'] as String),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        if (title.contains('Phone')) _callSupplier();
        if (title.contains('Email')) _emailSupplier();
      },
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _callSupplier,
              icon: const Icon(Icons.call),
              label: const Text('Call'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryGreen),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _getQuote,
              icon: const Icon(Icons.request_quote, color: Colors.white),
              label: const Text('Get Quote',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGreen),
            ),
          ),
        ],
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

  void _shareSupplier() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${widget.supplier.businessName}...')),
    );
  }

  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to favorites')),
    );
  }

  void _callSupplier() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${widget.supplier.phoneNumber}...')),
    );
  }

  void _emailSupplier() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening email to ${widget.supplier.email}...')),
    );
  }

  void _getQuote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote request sent!')),
    );
  }

  void _inquireProduct(String product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inquiring about $product...')),
    );
  }

  void _writeReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review form opening...')),
    );
  }
}
