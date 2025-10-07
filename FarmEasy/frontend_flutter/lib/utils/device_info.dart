import 'dart:io';

class DeviceInfo {
  static String get deviceType {
    if (Platform.isAndroid) {
      // Emulator detection
      if (Platform.environment['ANDROID_EMULATOR'] == 'true') {
        return 'Android Emulator';
      }
      return 'Android Device';
    }
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'MacOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  static String get laptopIp => Platform.environment['LAPTOP_IP'] ?? 'Unknown';
}
