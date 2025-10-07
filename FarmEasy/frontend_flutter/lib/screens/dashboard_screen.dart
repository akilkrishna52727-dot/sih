import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/user_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/crop_provider.dart';
import '../utils/constants.dart';
// Removed old WeatherCard usage in favor of an interactive header card
import '../services/notification_service.dart';
import '../services/weather_service.dart';
import 'crop_recommendation_screen.dart';
import 'marketplace_screen.dart';
import 'yield_comparison_screen.dart';
import 'soil_condition_rotation_screen.dart';
import 'harvest_done_screen.dart';
import 'login_screen.dart';
import 'subsidy_screen.dart';
import 'virtual_farm_setup_screen.dart';
import 'virtual_farm_list_screen.dart';
import 'sms_alerts_screen.dart';
import 'farmer_community_chat_screen.dart';
import 'suppliers_screen.dart';
import 'harvesters_screen.dart';
import '../providers/virtual_farm_provider.dart';
import '../services/subsidy_notification_service.dart';
import '../providers/soil_condition_provider.dart';
import '../providers/theme_provider.dart';
import 'theme_selection_screen.dart';
import '../widgets/voice_assistant_widget.dart';
import 'disease_detection_screen.dart';
import '../widgets/floating_chatbox.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentLocation = 'Delhi';
  Map<String, dynamic>? _weatherData;
  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  void _initializeDashboard() async {
    // Initialize notifications
    await NotificationService().initialize();

    // Check and notify about subsidy updates (non-blocking UX)
    await SubsidyNotificationService.checkNewSchemes();

    // Load saved location and cached weather
    await _loadSavedLocationAndWeather();

    // Load crops data
    if (!mounted) return;
    final cropProvider = Provider.of<CropProvider>(context, listen: false);
    await cropProvider.loadAllCrops();
  }

  Future<void> _loadSavedLocationAndWeather() async {
    final savedLocation = await WeatherService.getSavedLocation();
    final cachedWeather = await WeatherService.getCachedWeatherData();
    setState(() {
      _currentLocation = savedLocation;
      if (cachedWeather != null && cachedWeather['location'] == savedLocation) {
        _weatherData = cachedWeather;
      }
    });
    if (_weatherData == null || _isWeatherDataOld()) {
      await _loadWeatherData();
    }
  }

  bool _isWeatherDataOld() {
    if (_weatherData == null || _weatherData!['lastUpdated'] == null) {
      return true;
    }
    final lastUpdated =
        DateTime.tryParse(_weatherData!['lastUpdated'].toString());
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated).inHours > 1;
  }

  Future<void> _loadWeatherData({String? city}) async {
    final weatherProvider =
        Provider.of<WeatherProvider>(context, listen: false);

    try {
      // Get current location
      if (city != null && city.isNotEmpty) {
        await weatherProvider.getCurrentWeather(city: city);
      } else {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission != LocationPermission.denied) {
            Position position = await Geolocator.getCurrentPosition();
            await weatherProvider.getCurrentWeather(
              lat: position.latitude,
              lon: position.longitude,
            );
          } else {
            // Fallback to default city
            await weatherProvider.getCurrentWeather(city: _currentLocation);
          }
        } else {
          await weatherProvider.getCurrentWeather(city: _currentLocation);
        }
      }
    } catch (e) {
      // Fallback to default city if location fails
      await weatherProvider.getCurrentWeather(city: _currentLocation);
    }

    // Map provider weather into local interactive card state
    final w = weatherProvider.currentWeather;
    if (w != null && mounted) {
      setState(() {
        _currentLocation =
            w.location.isNotEmpty ? w.location : _currentLocation;
        _weatherData = {
          'temp': w.temperature.toStringAsFixed(0),
          'humidity': w.humidity.toStringAsFixed(0),
          'wind': w.windSpeed.toStringAsFixed(0),
          'pressure': w.pressure.toStringAsFixed(0),
          'location': _currentLocation,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      });
      await WeatherService.cacheWeatherData(_weatherData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'DASHBOARD',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: AppConstants.primaryGreen,
        elevation: 0,
        actions: [
          // Notification/Alert Icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 24),
                onPressed: _showNotifications,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: _buildNotificationBadge(),
              ),
            ],
          ),
          // Voice Assistant Widget (NEW)
          const VoiceAssistantWidget(),
          const SizedBox(width: 8),
          if (userProvider.isGuest)
            TextButton(
              onPressed: _navigateToLogin,
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            )
          else
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (user?.username.isNotEmpty == true ? user!.username[0] : 'U')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppConstants.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout();
                } else if (value == 'profile') {
                  _showProfile();
                } else if (value == 'sms_alerts') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SmsAlertsScreen(),
                    ),
                  );
                } else if (value == 'theme') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ThemeSelectionScreen()),
                  );
                } else if (value == 'voice_help') {
                  _showVoiceHelp();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sms_alerts',
                  child: Row(
                    children: [
                      Icon(Icons.sms, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('SMS Alerts'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'theme',
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) => Row(
                      children: [
                        Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        const Text('Dark Mode'),
                      ],
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: 'voice_help',
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Voice Help'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await _loadWeatherData(city: _currentLocation);
            },
            child: _buildMainContent(),
          ),
          const FloatingChatbox(),
        ],
      ),
    );
  }

  void _showVoiceHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic, color: Colors.green),
            SizedBox(width: 8),
            Text('Voice Assistant Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You can ask me about:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('🌤️ Weather Information:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('-  "What\'s the weather?"'),
              Text('-  "Will it rain today?"'),
              SizedBox(height: 8),
              Text('🌾 Crop Advice:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('-  "Recommend crops for my land"'),
              Text('-  "How to grow wheat?"'),
              SizedBox(height: 8),
              Text('💰 Market Prices:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('-  "What are wheat prices?"'),
              Text('-  "Show market rates"'),
              SizedBox(height: 8),
              Text('🚜 Find Services:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('-  "Find harvesters near me"'),
              Text('-  "Show suppliers"'),
              SizedBox(height: 8),
              Text('📱 App Navigation:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('-  "Open marketplace"'),
              Text('-  "Go to community"'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // New dashboard layout based on requested structure
  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),

          const SizedBox(height: 24),

          // Weather Card
          _buildWeatherCard(),

          const SizedBox(height: 24),

          // Features Grid
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFeaturesGrid(),

          const SizedBox(height: 32),

          // Recent Activity Section (moved above soil summary)
          _buildRecentActivitySection(),

          const SizedBox(height: 24),

          // Soil & Rotation Summary (moved below recent activity)
          _buildSoilRotationSummary(),

          const SizedBox(height: 32),

          // Additional sections
          _buildFarmingTips(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<UserProvider>(
      builder: (context, up, child) {
        final u = up.user;
        final isGuest = up.isGuest || u == null;
        final first = isGuest ? 'Guest' : (u.username.trim().split(' ').first);
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final List<Color> gradientColors = isDark
            ? <Color>[scheme.primary, scheme.secondary]
            : <Color>[scheme.primary, AppConstants.accentGreen];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome${isGuest ? '' : ' back'}, $first!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your smart farming companion',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Wrapper to reuse interactive weather UI
  Widget _buildWeatherCard() => _buildInteractiveWeatherCard();

  Widget _buildFeaturesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          'Virtual Farm Twin',
          'Simulate your farm operations',
          Icons.eco,
          _navigateToVirtualFarm,
        ),
        _buildActionCard(
          'AI Disease Detection',
          'Scan leaves for diseases',
          Icons.biotech,
          () => _navigateTo('disease_detection'),
        ),
        _buildActionCard(
          'Farmer Community',
          'Chat with farmers & officials',
          Icons.forum,
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const FarmerCommunityChatScreen()),
          ),
        ),
        _buildActionCard(
          'Crop Recommendation',
          'AI-powered crop suggestions',
          Icons.agriculture,
          () => _navigateTo('crop_recommendation'),
        ),
        _buildActionCard(
          'Marketplace',
          'Buy and sell crops',
          Icons.store,
          () => _navigateTo('marketplace'),
        ),
        _buildActionCard(
          'Harvesters',
          'Book harvesters & emergency',
          Icons.agriculture_outlined,
          () => _navigateTo('harvesters'),
        ),
        _buildActionCard(
          'Suppliers',
          'Find seeds, fertilizers, equipment',
          Icons.business,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SuppliersScreen()),
          ),
        ),
        _buildActionCard(
          'Yield Comparison',
          'Track your performance',
          Icons.analytics,
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const YieldComparisonScreen()),
          ),
        ),
        _buildActionCard(
          'Government Subsidies',
          'Latest 2025 schemes',
          Icons.account_balance,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubsidyScreen()),
          ),
        ),
        _buildActionCard(
          'Soil & Rotation',
          'Save soil and plan rotation',
          Icons.loop,
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SoilConditionRotationScreen()),
          ),
        ),
        _buildActionCard(
          'Log Harvest',
          'Update soil after harvest',
          Icons.check_circle,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HarvestDoneScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Get Started Card
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppConstants.primaryGreen.withValues(alpha: 0.1),
              child: const Icon(Icons.play_arrow,
                  color: AppConstants.primaryGreen),
            ),
            title: const Text('Get Started',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                const Text('Take a soil test to get crop recommendations'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateTo('crop_recommendation'),
          ),
        ),

        const SizedBox(height: 8),

        // Recent Marketplace Activity
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.withValues(alpha: 0.1),
              child: const Icon(Icons.store, color: Colors.indigo),
            ),
            title: const Text('Marketplace Activity',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Check your recent listings and orders'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateTo('marketplace'),
          ),
        ),

        const SizedBox(height: 8),

        // Recent Harvester Bookings
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.cyan.withValues(alpha: 0.1),
              child: const Icon(Icons.agriculture, color: Colors.cyan),
            ),
            title: const Text('Harvester Bookings',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('View your upcoming harvest appointments'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateTo('harvesters'),
          ),
        ),
      ],
    );
  }

  Widget _buildSoilRotationSummary() {
    return Consumer<SoilConditionProvider>(
      builder: (context, soilProvider, child) {
        final soilCondition = soilProvider.soilCondition;
        if (soilCondition == null) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Soil & Rotation Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppConstants.primaryGreen.withValues(alpha: 0.1),
                      child: const Icon(Icons.nature,
                          color: AppConstants.primaryGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildNutrientTag('N',
                                  soilCondition.nitrogen.toStringAsFixed(0)),
                              const SizedBox(width: 8),
                              _buildNutrientTag('P',
                                  soilCondition.phosphorus.toStringAsFixed(0)),
                              const SizedBox(width: 8),
                              _buildNutrientTag('K',
                                  soilCondition.potassium.toStringAsFixed(0)),
                              const SizedBox(width: 8),
                              _buildNutrientTag('pH',
                                  soilCondition.phLevel.toStringAsFixed(1)),
                              const SizedBox(width: 8),
                              _buildNutrientTag(
                                  'OC',
                                  soilCondition.organicCarbon
                                      .toStringAsFixed(1)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Rotation: Pulses (Legume) → Wheat → Mustard',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNutrientTag(String label, String value) {
    Color tagColor;
    switch (label) {
      case 'N':
        tagColor = Colors.blue;
        break;
      case 'P':
        tagColor = Colors.orange;
        break;
      case 'K':
        tagColor = Colors.purple;
        break;
      case 'pH':
        tagColor = Colors.green;
        break;
      case 'OC':
        tagColor = Colors.brown;
        break;
      default:
        tagColor = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: tagColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label:$value',
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: tagColor),
      ),
    );
  }

  Widget _buildFarmingTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Farming Tips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          color: Colors.amber.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seasonal Tip',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'September is ideal for preparing Rabi crops. Start soil preparation and select quality seeds.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateTo(String key) {
    switch (key) {
      case 'crop_recommendation':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CropRecommendationScreen()),
        );
        break;
      case 'marketplace':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
        );
        break;
      case 'harvesters':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HarvestersScreen()),
        );
        break;
      case 'disease_detection':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const DiseaseDetectionScreen()),
        );
        break;
    }
  }

  Future<void> _navigateToVirtualFarm() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final provider = Provider.of<VirtualFarmProvider>(context, listen: false);
      await provider.loadUserFarms();
      if (!mounted) return;
      Navigator.pop(context);
      if (provider.farms.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VirtualFarmListScreen(farms: provider.farms),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VirtualFarmSetupScreen(),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VirtualFarmSetupScreen(),
        ),
      );
    }
  }

  Widget _buildNotificationBadge() {
    // In a real app, derive this from provider/state. Using local service for now.
    try {
      final count = NotificationService.getUnreadCount();
      if (count <= 0) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(4),
        decoration:
            const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        child: Text(
          count.toString(),
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  void _showNotifications() {
    final notifications = NotificationService.getNotifications();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: AppConstants.primaryGreen),
            const SizedBox(width: 8),
            const Text('Notifications'),
            const Spacer(),
            if (notifications.any((n) => !n.isRead))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '${notifications.where((n) => !n.isRead).length} new',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: notifications.isEmpty
              ? const Center(child: Text('No notifications'))
              : ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markAllAsRead();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen),
            child: const Text('Mark All Read',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final timeAgo = _getTimeAgo(notification.time);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: notification.isRead ? null : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notification.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(notification.icon, color: notification.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(notification.message,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(timeAgo,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _markAllAsRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final userProvider = context.read<UserProvider>();
              await userProvider.logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProfile() {
    final u = context.read<UserProvider>().user;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${u?.username ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Email: ${u?.email ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Phone: ${u?.phone ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveWeatherCard() {
    final temp =
        _weatherData?['temp']?.toString() ?? _getRandomTemp().toString();
    final humidity = _weatherData?['humidity']?.toString() ??
        _getRandomHumidity().toString();
    final wind =
        _weatherData?['wind']?.toString() ?? _getRandomWind().toString();
    final pressure = _weatherData?['pressure']?.toString() ??
        _getRandomPressure().toString();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: () {
            final theme = Theme.of(context);
            final scheme = theme.colorScheme;
            final isDark = theme.brightness == Brightness.dark;
            final List<Color> colors = isDark
                ? <Color>[scheme.primary, scheme.secondary]
                : <Color>[scheme.primary, AppConstants.accentGreen];
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            );
          }(),
        ),
        child: InkWell(
          onTap: _showLocationPicker,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          _currentLocation,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Change',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: _showDetailedWeather,
                          borderRadius: BorderRadius.circular(20),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.white70, size: 16),
                              SizedBox(width: 4),
                              Text('Details',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildWeatherTile(
                          'Temperature', '$temp°C', Icons.thermostat),
                    ),
                    Expanded(
                      child: _buildWeatherTile(
                          'Humidity', '$humidity%', Icons.water_drop),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildWeatherTile('Wind', '$wind km/h', Icons.air),
                    ),
                    Expanded(
                      child: _buildWeatherTile(
                          'Pressure', '$pressure hPa', Icons.compress),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Tap to change location or view detailed forecast',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select your location for accurate weather data:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _currentLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              items: const [
                'Delhi',
                'Mumbai',
                'Bangalore',
                'Chennai',
                'Kolkata',
                'Hyderabad',
                'Pune',
                'Ahmedabad',
                'Jaipur',
                'Lucknow',
                'Kochi',
                'Coimbatore',
                'Nashik',
                'Surat',
                'Indore'
              ]
                  .map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentLocation = value;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await WeatherService.saveLocation(_currentLocation);
              await _loadWeatherData(city: _currentLocation);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Location changed to $_currentLocation')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDetailedWeather() {
    final temp = _weatherData?['temp'] ?? _getRandomTemp();
    final humidity = _weatherData?['humidity'] ?? _getRandomHumidity();
    final wind = _weatherData?['wind'] ?? _getRandomWind();
    final pressure = _weatherData?['pressure'] ?? _getRandomPressure();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Weather Details - $_currentLocation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Temperature: $temp°C'),
              Text(
                  'Feels like: ${int.tryParse(temp.toString()) != null ? (int.parse(temp.toString()) + 2) : temp}°C'),
              const SizedBox(height: 8),
              Text('Humidity: $humidity%'),
              Text('Wind Speed: $wind km/h'),
              Text('Atmospheric Pressure: $pressure hPa'),
              const SizedBox(height: 8),
              const Text('Forecast: Partly cloudy with chances of light rain'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  int _getRandomTemp() => 20 + (DateTime.now().millisecond % 20);
  int _getRandomHumidity() => 40 + (DateTime.now().millisecond % 40);
  int _getRandomWind() => 5 + (DateTime.now().millisecond % 20);
  int _getRandomPressure() => 1000 + (DateTime.now().millisecond % 50);

  Widget _buildActionCard(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.lightGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppConstants.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppConstants.greyColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
