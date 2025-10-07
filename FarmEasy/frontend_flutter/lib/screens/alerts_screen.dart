import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/crop_provider.dart';
import '../utils/constants.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final cropProvider = Provider.of<CropProvider>(context);
    final alerts = <String>[];
    if (weatherProvider.error != null) {
      alerts.add('Weather error: ${weatherProvider.error}');
    }
    if (cropProvider.error != null) {
      alerts.add('Crop error: ${cropProvider.error}');
    }
    // Add more alert logic as needed
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: AppConstants.primaryGreen,
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.warning, color: Colors.red),
          title: Text(alerts[index]),
        ),
      ),
    );
  }
}
