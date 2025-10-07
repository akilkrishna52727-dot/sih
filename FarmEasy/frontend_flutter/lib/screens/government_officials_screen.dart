import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../utils/constants.dart';

class GovernmentOfficialsScreen extends StatelessWidget {
  const GovernmentOfficialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final officials = _getSampleOfficials();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Officials'),
        backgroundColor: AppConstants.primaryGreen,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: officials.length,
        itemBuilder: (context, index) {
          final official = officials[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Text(official.name.substring(0, 1)),
              ),
              title: Text(official.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${official.designation} - ${official.department}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(official.location),
                  Text(
                    'Specializations: ${official.specializations.join(', ')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Column(
                children: [
                  Icon(
                    official.isAvailable ? Icons.circle : Icons.circle_outlined,
                    color: official.isAvailable ? Colors.green : Colors.grey,
                    size: 12,
                  ),
                  Text(
                    official.isAvailable ? 'Available' : 'Busy',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
              onTap: () => _showOfficialDetails(context, official),
            ),
          );
        },
      ),
    );
  }

  List<GovernmentOfficial> _getSampleOfficials() {
    return [
      GovernmentOfficial(
        id: '1',
        name: 'Mr. Rajesh Kumar',
        designation: 'District Collector',
        department: 'Revenue Department',
        location: 'Delhi',
        contactNumber: '+91-9876543210',
        email: 'collector.delhi@gov.in',
        isAvailable: true,
        specializations: ['Land Records', 'Revenue', 'Subsidies'],
      ),
      GovernmentOfficial(
        id: '2',
        name: 'Dr. Priya Sharma',
        designation: 'Agriculture Officer',
        department: 'Agriculture Department',
        location: 'Punjab',
        contactNumber: '+91-9876543211',
        email: 'agri.punjab@gov.in',
        isAvailable: true,
        specializations: ['Crop Planning', 'Pest Control', 'Fertilizers'],
      ),
    ];
  }

  void _showOfficialDetails(BuildContext context, GovernmentOfficial official) {
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
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo,
                    radius: 30,
                    child: Text(
                      official.name.substring(0, 1),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          official.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(official.designation),
                        Text(official.department),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow('Location', official.location),
              _buildInfoRow('Phone', official.contactNumber),
              _buildInfoRow('Email', official.email),
              const SizedBox(height: 16),
              const Text('Specializations:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: official.specializations
                    .map((spec) => Chip(
                        label:
                            Text(spec, style: const TextStyle(fontSize: 12))))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _contactOfficial(context, official, 'call'),
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _contactOfficial(context, official, 'email'),
                      icon: const Icon(Icons.email),
                      label: const Text('Email'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _contactOfficial(
      BuildContext context, GovernmentOfficial official, String method) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contacting ${official.name} via $method...')),
    );
  }
}
