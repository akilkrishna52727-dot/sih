import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/harvester_models.dart';
import '../services/harvester_service.dart';
import '../providers/user_provider.dart';

class HarvestBookingScreen extends StatefulWidget {
  final Harvester harvester;
  final bool emergency;
  const HarvestBookingScreen(
      {super.key, required this.harvester, this.emergency = false});

  @override
  State<HarvestBookingScreen> createState() => _HarvestBookingScreenState();
}

class _HarvestBookingScreenState extends State<HarvestBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = HarvesterService();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  final _cropTypes = const [
    'wheat',
    'rice',
    'corn',
    'mustard',
    'paddy',
    'sugarcane'
  ];
  String _crop = 'wheat';
  double _farmSize = 1.0;
  late TextEditingController _locationCtrl;
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 2));
  late TextEditingController _notesCtrl;

  double _estimated = 0;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameCtrl = TextEditingController(text: user?.username ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _locationCtrl = TextEditingController(text: 'My Farm');
    _notesCtrl = TextEditingController();
    _recalc();
  }

  void _recalc() {
    final base = widget.harvester.pricePerAcre * _farmSize;
    _estimated = widget.emergency ? base * 1.25 : base;
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Harvester')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Your name', border: OutlineInputBorder()),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                  labelText: 'Phone number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.trim().length < 8
                  ? 'Valid phone required'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _crop,
              decoration: const InputDecoration(
                  labelText: 'Crop type', border: OutlineInputBorder()),
              items: _cropTypes
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _crop = v ?? _crop),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Farm size (acres)', border: OutlineInputBorder()),
              child: Column(
                children: [
                  Slider(
                    value: _farmSize,
                    min: 0.5,
                    max: 20,
                    divisions: 39,
                    label: _farmSize.toStringAsFixed(1),
                    onChanged: (v) {
                      setState(() => _farmSize = v);
                      _recalc();
                    },
                  ),
                  Text('${_farmSize.toStringAsFixed(1)} acres'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                  labelText: 'Farm location/address',
                  border: OutlineInputBorder()),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Location required' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Preferred date'),
              subtitle: Text(_fmtDate(_preferredDate)),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                  labelText: 'Special requirements (optional)',
                  border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _estimateCard(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirm Booking'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Icon(Icons.agriculture, size: 28, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.harvester.businessName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${widget.harvester.city}, ${widget.harvester.state}'),
            ],
          ),
        ),
        if (widget.emergency)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Icon(Icons.emergency, color: Colors.red.shade800, size: 16),
              const SizedBox(width: 4),
              Text('Emergency', style: TextStyle(color: Colors.red.shade800)),
            ]),
          ),
      ],
    );
  }

  Widget _estimateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimated Cost',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
                'Base: ₹${(widget.harvester.pricePerAcre * _farmSize).toStringAsFixed(0)}'),
            if (widget.emergency)
              Text(
                  'Emergency surcharge (25%): ₹${(widget.harvester.pricePerAcre * _farmSize * 0.25).toStringAsFixed(0)}'),
            const Divider(),
            Text('Total: ₹${_estimated.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: _preferredDate,
    );
    if (d != null) {
      setState(() => _preferredDate = d);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final u = context.read<UserProvider>().user;
    final booking = await _service.createBooking(
      harvester: widget.harvester,
      farmerId: u?.id.toString() ?? 'guest',
      farmerName: _nameCtrl.text.trim(),
      farmerPhone: _phoneCtrl.text.trim(),
      cropType: _crop,
      farmSize: _farmSize,
      farmLocation: _locationCtrl.text.trim(),
      preferredDate: _preferredDate,
      specialRequirements:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      emergency: widget.emergency,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Booking Created'),
        content: Text(
            'Your booking with ${widget.harvester.businessName} is ${booking.status.replaceAll('_', ' ')}. Estimated cost: ₹${booking.estimatedCost.toStringAsFixed(0)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)
              ..pop()
              ..pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
