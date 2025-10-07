import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/soil_condition.dart';
import '../providers/soil_condition_provider.dart';
import '../utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SoilConditionRotationScreen extends StatefulWidget {
  const SoilConditionRotationScreen({super.key});

  @override
  State<SoilConditionRotationScreen> createState() =>
      _SoilConditionRotationScreenState();
}

class _SoilConditionRotationScreenState
    extends State<SoilConditionRotationScreen> {
  late TextEditingController _nController;
  late TextEditingController _pController;
  late TextEditingController _kController;
  late TextEditingController _phController;
  late TextEditingController _ocController;
  String _season = 'Kharif';

  @override
  void initState() {
    super.initState();
    final sc = context.read<SoilConditionProvider>().soilCondition;
    _nController =
        TextEditingController(text: sc?.nitrogen.toStringAsFixed(1) ?? '0');
    _pController =
        TextEditingController(text: sc?.phosphorus.toStringAsFixed(1) ?? '0');
    _kController =
        TextEditingController(text: sc?.potassium.toStringAsFixed(1) ?? '0');
    _phController =
        TextEditingController(text: sc?.phLevel.toStringAsFixed(1) ?? '7.0');
    _ocController = TextEditingController(
        text: sc?.organicCarbon.toStringAsFixed(2) ?? '0.5');
  }

  @override
  void dispose() {
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _phController.dispose();
    _ocController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SoilConditionProvider>();
    final sc = provider.soilCondition;
    final rotation = provider.rotation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil & Rotation Planner'),
        backgroundColor: AppConstants.primaryGreen,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'export_clipboard':
                  await _exportJsonClipboard(provider);
                  break;
                case 'export_file':
                  await _exportJsonFile(provider);
                  break;
                case 'share_file':
                  await _shareJsonFile(provider);
                  break;
                case 'import_clipboard':
                  await _importJsonClipboard(provider);
                  break;
                case 'import_file':
                  await _importJsonFile(provider);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: 'export_file', child: Text('Export to file')),
              PopupMenuItem(
                  value: 'share_file', child: Text('Share backup file')),
              PopupMenuItem(
                  value: 'export_clipboard',
                  child: Text('Copy JSON to clipboard')),
              PopupMenuDivider(),
              PopupMenuItem(
                  value: 'import_file', child: Text('Import from file')),
              PopupMenuItem(
                  value: 'import_clipboard',
                  child: Text('Paste JSON from clipboard')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSoilCard(sc),
            const SizedBox(height: 16),
            _buildEditSoilForm(provider),
            const SizedBox(height: 24),
            _buildRotationCard(rotation),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _computeAndSaveRotation,
        backgroundColor: AppConstants.primaryGreen,
        icon: const Icon(Icons.autorenew, color: Colors.white),
        label: const Text('Compute Rotation',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSoilCard(SoilCondition? sc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.grass, color: AppConstants.primaryGreen),
                SizedBox(width: 8),
                Text('Current Soil Condition',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (sc == null)
              const Text(
                  'No soil condition saved yet. Enter values below and save.',
                  style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('N', sc.nitrogen.toStringAsFixed(1)),
                  _chip('P', sc.phosphorus.toStringAsFixed(1)),
                  _chip('K', sc.potassium.toStringAsFixed(1)),
                  _chip('pH', sc.phLevel.toStringAsFixed(1)),
                  _chip('OC %', sc.organicCarbon.toStringAsFixed(2)),
                  Text(
                      'Updated: ${sc.lastUpdated.toLocal().toString().split('.').first}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditSoilForm(SoilConditionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit, color: AppConstants.primaryGreen),
                SizedBox(width: 8),
                Text('Edit / Save Soil',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _numField('Nitrogen (N)', _nController)),
              const SizedBox(width: 12),
              Expanded(child: _numField('Phosphorus (P)', _pController)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _numField('Potassium (K)', _kController)),
              const SizedBox(width: 12),
              Expanded(child: _numField('pH level', _phController)),
            ]),
            const SizedBox(height: 12),
            _numField('Organic Carbon %', _ocController),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _season,
              decoration: const InputDecoration(
                labelText: 'Starting Season',
                border: OutlineInputBorder(),
              ),
              items: const ['Kharif', 'Rabi', 'Zaid']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _season = v ?? 'Kharif'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final sc = SoilCondition(
                    nitrogen: double.tryParse(_nController.text) ?? 0,
                    phosphorus: double.tryParse(_pController.text) ?? 0,
                    potassium: double.tryParse(_kController.text) ?? 0,
                    phLevel: double.tryParse(_phController.text) ?? 7.0,
                    organicCarbon: double.tryParse(_ocController.text) ?? 0.5,
                  );
                  await provider.saveSoilCondition(sc);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Soil condition saved')),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen),
                child: const Text('Save Soil',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationCard(CropRotation? rotation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.loop, color: AppConstants.primaryGreen),
                SizedBox(width: 8),
                Text('Crop Rotation Plan',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (rotation == null)
              const Text(
                  'No rotation plan saved. Tap "Compute Rotation" to generate one.')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: rotation.crops
                        .asMap()
                        .entries
                        .map((e) => Chip(
                              label: Text('${e.key + 1}. ${e.value}'),
                              backgroundColor: Colors.green.shade50,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Text('Starting Season: ${rotation.startingSeason}'),
                  Text('Duration: ${rotation.durationMonths} months'),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _numField(String label, TextEditingController c) => TextFormField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      );

  Widget _chip(String label, String value) => Chip(
        label: Text('$label: $value'),
        backgroundColor: Colors.green.shade50,
      );

  Future<void> _computeAndSaveRotation() async {
    final provider = context.read<SoilConditionProvider>();
    final sc = provider.soilCondition ??
        SoilCondition(
          nitrogen: double.tryParse(_nController.text) ?? 0,
          phosphorus: double.tryParse(_pController.text) ?? 0,
          potassium: double.tryParse(_kController.text) ?? 0,
          phLevel: double.tryParse(_phController.text) ?? 7.0,
          organicCarbon: double.tryParse(_ocController.text) ?? 0.5,
        );

    // Simple heuristic rotation: include legume to replenish N, then cereal, then oilseed/vegetable
    final List<String> crops = [];
    if (sc.nitrogen < 50) {
      crops.add('Pulses (Legume)');
    } else {
      crops.add('Rice');
    }
    crops.add('Wheat');
    if (sc.phLevel < 6.5) {
      crops.add('Mustard');
    } else {
      crops.add('Maize');
    }

    final rotation = CropRotation(
      crops: crops,
      startingSeason: _season,
      durationMonths: 12,
    );
    await provider.saveRotation(rotation);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rotation plan saved')),
    );
    setState(() {});
  }

  Map<String, dynamic> _makeBackupPayload(SoilConditionProvider provider) {
    final sc = provider.soilCondition;
    final rot = provider.rotation;
    final hist = provider.harvestHistory;
    return <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      if (sc != null) 'soilCondition': sc.toJson(),
      if (rot != null) 'cropRotation': rot.toJson(),
      if (hist.isNotEmpty)
        'harvestHistory': hist.map((e) => e.toJson()).toList(),
    };
  }

  Future<void> _exportJsonClipboard(SoilConditionProvider provider) async {
    final jsonStr = const JsonEncoder.withIndent('  ')
        .convert(_makeBackupPayload(provider));
    await Clipboard.setData(ClipboardData(text: jsonStr));
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exported to Clipboard'),
        content: SingleChildScrollView(child: Text(jsonStr)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Future<File> _writeBackupFile(String contents) async {
    // Try Downloads if available; otherwise fallback to Documents or temp dir
    Directory dir;
    try {
      dir = Directory('/storage/emulated/0/Download'); // Common Android path
      if (!await dir.exists()) {
        dir = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      dir = await getApplicationDocumentsDirectory();
    }
    final file = File(
        '${dir.path}/farmeasy_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    return file.writeAsString(contents);
  }

  Future<void> _exportJsonFile(SoilConditionProvider provider) async {
    final jsonStr = const JsonEncoder.withIndent('  ')
        .convert(_makeBackupPayload(provider));
    try {
      final file = await _writeBackupFile(jsonStr);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup saved: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save file: $e')),
      );
    }
  }

  Future<void> _shareJsonFile(SoilConditionProvider provider) async {
    final jsonStr = const JsonEncoder.withIndent('  ')
        .convert(_makeBackupPayload(provider));
    try {
      final file = await _writeBackupFile(jsonStr);
      await Share.shareXFiles([XFile(file.path)], text: 'FarmEasy backup');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share file: $e')),
      );
    }
  }

  Future<void> _importJsonClipboard(SoilConditionProvider provider) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import JSON'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: '{ "soilCondition": { ... }, "cropRotation": { ... } }',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final raw = controller.text.trim();
              await _applyBackupJson(provider, raw);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importJsonFile(SoilConditionProvider provider) async {
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;
      final raw = await File(path).readAsString();
      await _applyBackupJson(provider, raw);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import: $e')),
      );
    }
  }

  Future<void> _applyBackupJson(
      SoilConditionProvider provider, String raw) async {
    try {
      final map = raw.isEmpty
          ? <String, dynamic>{}
          : (jsonDecode(raw) as Map<String, dynamic>);
      if (map.containsKey('soilCondition')) {
        final sc = SoilCondition.fromJson(
            map['soilCondition'] as Map<String, dynamic>);
        await provider.saveSoilCondition(sc);
      }
      if (map.containsKey('cropRotation')) {
        final rot =
            CropRotation.fromJson(map['cropRotation'] as Map<String, dynamic>);
        await provider.saveRotation(rot);
      }
      if (map.containsKey('harvestHistory')) {
        final list = map['harvestHistory'] as List<dynamic>;
        final entries = list
            .map((e) => HarvestEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        await provider.setHarvestHistory(entries);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import completed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid JSON: $e')),
      );
    }
  }
}
