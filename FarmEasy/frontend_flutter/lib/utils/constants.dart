import 'dart:io';
import 'package:flutter/material.dart';

class AppConstants {
  // Color Scheme
  static const Color primaryGreen = Color(0xFF4A8C2A);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color backgroundColor = Color(0xFFF1F8E9);
  static const Color textDark = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color greyColor = Color(0xFF9E9E9E);

  // API Configuration
  static String get baseUrl {
    // Optional overrides via --dart-define
    const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    const hostIp = String.fromEnvironment('HOST_IP', defaultValue: '');

    if (apiBase.isNotEmpty) return apiBase;

    if (Platform.isAndroid) {
      // On physical device, pass HOST_IP via --dart-define=HOST_IP=192.168.x.x
      if (hostIp.isNotEmpty) return 'http://$hostIp:5000/api';
      // Android emulator maps host machine localhost to 10.0.2.2
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  // App Strings
  static const String appName = 'FarmEasy';
  static const String welcomeMessage = 'Smart Farming Assistant';

  // Validation
  static const int minPasswordLength = 6;
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verify = '/auth/verify';
  static const String soilTest = '/soil/analyze';
  static const String soilAnalyzeEnhanced = '/soil/analyze-enhanced';
  static const String cropRecommend = '/crops/recommend';
  static const String weather = '/weather/current';
  static const String marketplace = '/marketplace/products';
  static const String alerts = '/alerts/user';
  static const String subsidies = '/subsidies/available';
}
