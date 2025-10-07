import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime time;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.time,
    required this.isRead,
    required this.type,
  });
}

enum NotificationType { weather, cropHealth, market, subsidy, general }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> showWeatherAlert(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'weather_alerts',
      'Weather Alerts',
      channelDescription: 'Notifications for weather-related farming alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      title,
      body,
      details,
      payload: 'weather_alert',
    );
  }

  Future<void> showCropRecommendation(
      String cropName, double confidence) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'crop_recommendations',
      'Crop Recommendations',
      channelDescription: 'Notifications for crop recommendations',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      2,
      'Crop Recommendation Ready! 🌾',
      'We recommend ${cropName.toUpperCase()} with ${(confidence * 100).toStringAsFixed(1)}% confidence',
      details,
      payload: 'crop_recommendation',
    );
  }

  Future<void> showMarketplaceNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'marketplace',
      'Marketplace Updates',
      channelDescription: 'Notifications for marketplace activities',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      3,
      title,
      body,
      details,
      payload: 'marketplace',
    );
  }

  Future<void> showSubsidyUpdate(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'subsidy_updates',
      'Subsidy Updates',
      channelDescription: 'Notifications for government subsidy updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      4,
      title,
      body,
      details,
      payload: 'subsidy_update',
    );
  }

  // Simple in-app helpers for demo/UX
  static List<NotificationItem> getNotifications() {
    return [
      NotificationItem(
        id: '1',
        title: 'Weather Alert',
        message:
            'Heavy rainfall expected in your area today. Protect your crops and ensure proper drainage.',
        icon: Icons.cloud,
        color: Colors.blue,
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        type: NotificationType.weather,
      ),
      NotificationItem(
        id: '2',
        title: 'Crop Health Reminder',
        message:
            'Ideal time for pest monitoring in your registered crops. Check for early signs of damage.',
        icon: Icons.pest_control,
        color: Colors.orange,
        time: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
        type: NotificationType.cropHealth,
      ),
      NotificationItem(
        id: '3',
        title: 'Market Update',
        message:
            'Rice prices have increased by 5% in your region. Consider selling if you have stock.',
        icon: Icons.trending_up,
        color: Colors.green,
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        type: NotificationType.market,
      ),
      NotificationItem(
        id: '4',
        title: 'Subsidy Alert',
        message:
            'New government scheme available for organic farming. Apply before deadline.',
        icon: Icons.account_balance,
        color: Colors.purple,
        time: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        type: NotificationType.subsidy,
      ),
    ];
  }

  static int getUnreadCount() {
    return getNotifications().where((n) => !n.isRead).length;
  }
}
