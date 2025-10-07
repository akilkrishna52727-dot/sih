import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sms_service.dart';
import '../utils/constants.dart';

class SmsAlertsScreen extends StatefulWidget {
  const SmsAlertsScreen({super.key});

  @override
  State<SmsAlertsScreen> createState() => _SmsAlertsScreenState();
}

class _SmsAlertsScreenState extends State<SmsAlertsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  bool _weatherAlerts = true;
  bool _cropAlerts = true;
  bool _marketAlerts = false;
  bool _subsidyAlerts = true;
  bool _harvestAlerts = true;

  bool _isLoading = false;
  bool _isPhoneVerified = false;
  String? _verificationCode;
  bool _isDemoMode = false;
  final List<Map<String, dynamic>> _recentDemoAlerts = [];

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final smsService = SmsService();
    final savedPhone = await smsService.getSavedPhoneNumber();
    final alertSettings = await smsService.getAlertSettings();

    if (savedPhone != null) {
      setState(() {
        _phoneController.text = savedPhone.replaceFirst('+91', '');
        _isPhoneVerified = true;
        _weatherAlerts = alertSettings['weather'] ?? true;
        _cropAlerts = alertSettings['crop'] ?? true;
        _marketAlerts = alertSettings['market'] ?? false;
        _subsidyAlerts = alertSettings['subsidy'] ?? true;
        _harvestAlerts = alertSettings['harvest'] ?? true;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Alerts'),
        backgroundColor: AppConstants.primaryGreen,
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _isDemoMode = !_isDemoMode),
            icon: Icon(_isDemoMode ? Icons.stop : Icons.play_arrow,
                color: Colors.white),
            label: Text(_isDemoMode ? 'Stop Demo' : 'Demo Mode',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isDemoMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.red.shade400]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.live_tv, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'HACKATHON DEMO MODE ACTIVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _startDemoAlerts,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        child: Text('Start Demo',
                            style: TextStyle(color: Colors.orange.shade600)),
                      ),
                    ],
                  ),
                ),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.sms, color: Colors.blue.shade700, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stay Updated with SMS Alerts',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Get important farming updates directly on your mobile phone',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Demo Section for Hackathon
              if (_isDemoMode)
                Card(
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.rocket_launch,
                                color: Colors.purple.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Hackathon Demo Features',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildDemoButton('Weather Alert', Icons.cloud_queue,
                                Colors.blue, () => _sendDemoWeatherAlert()),
                            _buildDemoButton('Pest Alert', Icons.bug_report,
                                Colors.red, () => _sendDemoPestAlert()),
                            _buildDemoButton('Market Update', Icons.trending_up,
                                Colors.green, () => _sendDemoMarketAlert()),
                            _buildDemoButton(
                                'Subsidy Info',
                                Icons.account_balance,
                                Colors.indigo,
                                () => _sendDemoSubsidyAlert()),
                            _buildDemoButton('Harvest Ready', Icons.agriculture,
                                Colors.orange, () => _sendDemoHarvestAlert()),
                            _buildDemoButton('Soil Health', Icons.eco,
                                Colors.brown, () => _sendDemoSoilAlert()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _sendRandomAlert,
                                icon: const Icon(Icons.shuffle),
                                label: const Text('Send Random Alert'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _sendSequentialAlerts,
                                icon: const Icon(Icons.play_circle),
                                label: const Text('Demo Sequence'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const Text(
                'Mobile Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.length != 10) {
                          return 'Enter valid 10-digit mobile number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        prefixText: '+91 ',
                        prefixIcon: const Icon(Icons.phone,
                            color: AppConstants.primaryGreen),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        suffixIcon: _isPhoneVerified
                            ? const Icon(Icons.verified, color: Colors.green)
                            : null,
                      ),
                      enabled: !_isPhoneVerified,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!_isPhoneVerified)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verifyPhoneNumber,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Verify',
                              style: TextStyle(color: Colors.white)),
                    )
                  else
                    ElevatedButton(
                      onPressed: _changePhoneNumber,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      child: const Text('Change',
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
              if (_verificationCode != null && !_isPhoneVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            'Verification SMS sent! Your code is: $_verificationCode',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _confirmVerification,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text('I Received the SMS',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              const Text(
                'Alert Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildAlertToggle(
                        'Weather Alerts',
                        'Get notified about weather changes, rainfall, and extreme conditions',
                        Icons.cloud,
                        Colors.blue,
                        _weatherAlerts,
                        (value) => setState(() => _weatherAlerts = value),
                      ),
                      const Divider(),
                      _buildAlertToggle(
                        'Crop Health Alerts',
                        'Receive updates about pest attacks, diseases, and crop care tips',
                        Icons.eco,
                        Colors.green,
                        _cropAlerts,
                        (value) => setState(() => _cropAlerts = value),
                      ),
                      const Divider(),
                      _buildAlertToggle(
                        'Market Price Alerts',
                        'Stay updated with crop price changes and market trends',
                        Icons.trending_up,
                        Colors.purple,
                        _marketAlerts,
                        (value) => setState(() => _marketAlerts = value),
                      ),
                      const Divider(),
                      _buildAlertToggle(
                        'Government Subsidy Alerts',
                        'Get notified about new schemes, subsidies, and application deadlines',
                        Icons.account_balance,
                        Colors.indigo,
                        _subsidyAlerts,
                        (value) => setState(() => _subsidyAlerts = value),
                      ),
                      const Divider(),
                      _buildAlertToggle(
                        'Harvest Reminders',
                        'Receive reminders about optimal harvest times and post-harvest care',
                        Icons.agriculture,
                        Colors.orange,
                        _harvestAlerts,
                        (value) => setState(() => _harvestAlerts = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPhoneVerified ? _saveAlertSettings : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Save Alert Settings',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isPhoneVerified)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _sendTestSMS,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Test SMS'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              if (_isDemoMode && _recentDemoAlerts.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Recent Demo Alerts Sent',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            TextButton(
                                onPressed: () =>
                                    setState(() => _recentDemoAlerts.clear()),
                                child: const Text('Clear')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._recentDemoAlerts
                            .map((alert) => _buildAlertLogItem(alert)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Card(
                color: Colors.grey.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 8),
                          Text('Important Information',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('-  SMS alerts are sent only for critical updates'),
                      Text('-  You can change your preferences anytime'),
                      Text('-  Standard SMS charges may apply'),
                      Text('-  We never share your number with third parties'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertToggle(
    String title,
    String description,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(description, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: _isPhoneVerified ? onChanged : null,
        activeThumbColor: AppConstants.primaryGreen,
      ),
    );
  }

  // ===== Hackathon Demo Helpers =====
  Widget _buildDemoButton(
      String title, IconData icon, Color color, VoidCallback onPressed) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertLogItem(Map<String, dynamic> alert) {
    final time = alert['time'] as DateTime;
    final type = alert['type'] as String;
    final message = alert['message'] as String;

    Color badgeColor(String type) {
      switch (type) {
        case 'Weather':
          return Colors.blue;
        case 'Pest':
          return Colors.red;
        case 'Market':
          return Colors.green;
        case 'Subsidy':
          return Colors.indigo;
        case 'Harvest':
          return Colors.orange;
        case 'Soil':
          return Colors.brown;
        default:
          return Colors.grey;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: badgeColor(type),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  type,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Future<void> _startDemoAlerts() async {
    final phoneNumber = '+91${_phoneController.text}';
    if (phoneNumber.length < 13) {
      _showPhoneRequiredDialog();
      return;
    }

    const welcomeMessage =
        '🎉 FARMEASY DEMO STARTED\nWelcome to our hackathon demonstration!\n\nYou\'ll receive various types of farming alerts. All alerts are simulated for demo purposes.\n\nThank you for watching our presentation! 🚀';
    await _sendDemoSMS('Demo', welcomeMessage);
    _startAutomatedDemo();
  }

  void _startAutomatedDemo() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isDemoMode) {
        timer.cancel();
        return;
      }
      _sendRandomAlert();
      if (timer.tick >= 5) {
        timer.cancel();
        setState(() => _isDemoMode = false);
      }
    });
  }

  Future<void> _sendRandomAlert() async {
    final alerts = [
      _sendDemoWeatherAlert,
      _sendDemoPestAlert,
      _sendDemoMarketAlert,
      _sendDemoSubsidyAlert,
      _sendDemoHarvestAlert,
      _sendDemoSoilAlert,
    ];
    final idx = Random().nextInt(alerts.length);
    await alerts[idx]();
  }

  Future<void> _sendSequentialAlerts() async {
    final phoneNumber = '+91${_phoneController.text}';
    if (phoneNumber.length < 13) {
      _showPhoneRequiredDialog();
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sending demo alerts sequence...'),
            Text('This will take about 30 seconds',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
    try {
      await _sendDemoWeatherAlert();
      await Future.delayed(const Duration(seconds: 5));
      await _sendDemoPestAlert();
      await Future.delayed(const Duration(seconds: 5));
      await _sendDemoMarketAlert();
      await Future.delayed(const Duration(seconds: 5));
      await _sendDemoHarvestAlert();
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Demo sequence completed!'),
          backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error in demo sequence: $e')));
    }
  }

  Future<void> _sendDemoWeatherAlert() async {
    const msg =
        '🌦️ WEATHER ALERT - FarmEasy\nHeavy rainfall expected in your area within next 6 hours!\n\nRainfall: 50-80mm\nWind Speed: 25-30 km/h\nDuration: 4-6 hours\n\nIMMEDIATE ACTIONS:\n• Move livestock to shelter\n• Cover stored grains\n• Check drainage systems\n• Avoid field operations\n\nStay Safe! 🌾';
    await _sendDemoSMS('Weather', msg);
  }

  Future<void> _sendDemoPestAlert() async {
    const msg =
        '🐛 PEST ALERT - FarmEasy\nBrown Plant Hopper outbreak detected nearby!\n\nRisk Level: HIGH\nAffected Crops: Rice, Wheat\nSpread Radius: 5km\n\nIMMEDIATE ACTIONS:\n• Inspect crops daily\n• Apply neem-based pesticides\n• Remove infected plants\n• Contact agri-expert: 1800-123-456\n\nEarly detection saves crops! 🌱';
    await _sendDemoSMS('Pest', msg);
  }

  Future<void> _sendDemoMarketAlert() async {
    const msg =
        '📈 MARKET ALERT - FarmEasy\nRice prices SURGE by 12% today!\n\nCurrent Rate: ₹2,840/quintal\nYesterday: ₹2,540/quintal\nWeekly High: ₹2,850/quintal\n\nINSIGHTS:\n• Export demand increased\n• Monsoon delays in other regions\n\nBest selling time: Next 7 days\n\nMaximize your profits! 💰';
    await _sendDemoSMS('Market', msg);
  }

  Future<void> _sendDemoSubsidyAlert() async {
    const msg =
        '🏛️ SUBSIDY ALERT - FarmEasy\nNEW: PM-KISAN Solar Pump Scheme launched!\n\nBenefits:\n• 90% subsidy on solar pumps\n• No electricity bills\n• 25-year warranty\n• Easy EMI options\n\nEligibility: Small & marginal farmers\nLast Date: 15th Oct 2025\nApply: pmkisan.gov.in\nHelpline: 1800-115-526\n\nDon\'t miss out! 🌞';
    await _sendDemoSMS('Subsidy', msg);
  }

  Future<void> _sendDemoHarvestAlert() async {
    const msg =
        '🌾 HARVEST ALERT - FarmEasy\nYour Rice crop is ready for harvest!\n\nCrop Age: 118 days\nMoisture: 22% (Optimal: 20-25%)\nWeather: Clear for next 5 days\n\nCHECKLIST:\n• Book harvester in advance\n• Arrange storage\n• Check market rates\n• Plan transportation\n\nExpected Yield: 4.2 tons/hectare\nGood luck! 🚜';
    await _sendDemoSMS('Harvest', msg);
  }

  Future<void> _sendDemoSoilAlert() async {
    const msg =
        '🌱 SOIL HEALTH ALERT - FarmEasy\nYour soil analysis results are ready!\n\nNitrogen: LOW\nPhosphorus: GOOD\nPotassium: MODERATE\npH: 6.2\n\nRECOMMENDATIONS:\n• Apply 50kg Urea/acre\n• Add organic compost\n• Test again in 30 days\n• Avoid over-watering\n\nHealthy soil = Better yield! 📊';
    await _sendDemoSMS('Soil', msg);
  }

  Future<void> _sendDemoSMS(String type, String message) async {
    final phoneNumber = '+91${_phoneController.text}';
    if (phoneNumber.length < 13) {
      _showPhoneRequiredDialog();
      return;
    }
    final smsService = SmsService();

    setState(() {
      _recentDemoAlerts.insert(
          0, {'type': type, 'message': message, 'time': DateTime.now()});
      if (_recentDemoAlerts.length > 10) {
        _recentDemoAlerts.removeRange(10, _recentDemoAlerts.length);
      }
    });

    final ok = await smsService.sendCustomAlert(phoneNumber, message,
        forceSimulate: true);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('$type alert sent successfully! 📱'),
            backgroundColor: _getAlertTypeColor(type)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(smsService.lastError ?? 'Failed to send $type alert'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showPhoneRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone number required'),
        content: const Text(
            'Please enter your 10-digit mobile number to receive demo alerts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Color _getAlertTypeColor(String type) {
    switch (type) {
      case 'Weather':
        return Colors.blue;
      case 'Pest':
        return Colors.red;
      case 'Market':
        return Colors.green;
      case 'Subsidy':
        return Colors.indigo;
      case 'Harvest':
        return Colors.orange;
      case 'Soil':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Future<void> _verifyPhoneNumber() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final smsService = SmsService();
        final phoneNumber = '+91${_phoneController.text}';
        final verificationCode =
            await smsService.sendVerificationSMS(phoneNumber);
        if (verificationCode != null) {
          setState(() {
            _verificationCode = verificationCode;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Verification SMS sent! Check your phone.'),
                backgroundColor: Colors.green),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(smsService.lastError ??
                    'Failed to send verification SMS. Please try again.'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmVerification() {
    setState(() {
      _isPhoneVerified = true;
      _verificationCode = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Phone number verified successfully!'),
          backgroundColor: Colors.green),
    );
  }

  void _changePhoneNumber() {
    setState(() {
      _isPhoneVerified = false;
      _phoneController.clear();
    });
  }

  Future<void> _saveAlertSettings() async {
    try {
      final smsService = SmsService();
      final phoneNumber = '+91${_phoneController.text}';
      final settings = {
        'weather': _weatherAlerts,
        'crop': _cropAlerts,
        'market': _marketAlerts,
        'subsidy': _subsidyAlerts,
        'harvest': _harvestAlerts,
      };
      await smsService.savePhoneNumber(phoneNumber);
      await smsService.saveAlertSettings(settings);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('SMS alert settings saved successfully!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _sendTestSMS() async {
    try {
      final smsService = SmsService();
      final phoneNumber = '+91${_phoneController.text}';
      final ok = await smsService.sendTestSMS(phoneNumber);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Test SMS sent successfully!'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(smsService.lastError ?? 'Failed to send SMS'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error sending test SMS: $e'),
            backgroundColor: Colors.red),
      );
    }
  }
}
