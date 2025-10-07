import 'package:flutter/material.dart';
import '../utils/constants.dart';

class VoiceCommandsScreen extends StatelessWidget {
  const VoiceCommandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Commands'),
        backgroundColor: AppConstants.primaryGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Introduction Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic, color: Colors.blue.shade700, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Voice Assistant for Farmers',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Designed for low-literate users. Simply speak in your natural language and get instant farming information and assistance.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Command Categories
          _buildCommandCategory(
            'Weather Information',
            Icons.cloud,
            Colors.blue,
            [
              "What's the weather today?",
              'Will it rain?',
              'Show me temperature',
              'Weather forecast please',
            ],
          ),

          _buildCommandCategory(
            'Crop Recommendations',
            Icons.eco,
            Colors.green,
            [
              'What crop should I plant?',
              'Recommend crops for wheat season',
              'Good crops for my soil',
              'Help me choose crops',
            ],
          ),

          _buildCommandCategory(
            'Market Prices',
            Icons.trending_up,
            Colors.purple,
            [
              'What are wheat prices?',
              'Show market rates',
              'Rice price today',
              'Best selling prices',
            ],
          ),

          _buildCommandCategory(
            'Find Services',
            Icons.search,
            Colors.orange,
            [
              'Find harvesters near me',
              'Show suppliers',
              'Book harvesting service',
              'Need fertilizer suppliers',
            ],
          ),

          _buildCommandCategory(
            'App Navigation',
            Icons.navigation,
            Colors.indigo,
            [
              'Open marketplace',
              'Go to community',
              'Show my bookings',
              'Take me to suppliers',
            ],
          ),

          _buildCommandCategory(
            'General Help',
            Icons.help,
            Colors.teal,
            [
              'Help me',
              'What can you do?',
              'How to use this app?',
              'Farming advice please',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCategory(
    String title,
    IconData icon,
    Color color,
    List<String> commands,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...commands.map(
              (command) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.mic_none, color: Colors.grey.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '"$command"',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
