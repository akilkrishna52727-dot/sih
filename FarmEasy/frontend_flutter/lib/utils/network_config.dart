import 'dart:io';

class NetworkConfig {
  static String getApiBaseUrl() {
    if (Platform.isAndroid) {
      // Detect emulator vs real device
      // Emulator uses 10.0.2.2, real device uses laptop IP from env
      final laptopIp = Platform.environment['LAPTOP_IP'];
      if (laptopIp != null && laptopIp.isNotEmpty) {
        return 'http://$laptopIp:5000/api';
      }
      return 'http://10.0.2.2:5000/api';
    }
    // For other platforms, use localhost for dev
    return 'http://localhost:5000/api';
  }

  static String getProdApiBaseUrl() {
    return 'https://api.farmeasy.com/api';
  }

  static Duration get timeout => const Duration(seconds: 10);
  static int get maxRetries => 3;
}
