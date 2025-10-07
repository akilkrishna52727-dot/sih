import 'dart:io';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class PlatformService {
  static const platform = MethodChannel('com.farmeasy.app/permissions');

  // Check if running on physical device
  static Future<bool> isPhysicalDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice;
    }
    return false;
  }

  // Get device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'Android',
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'version': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
        'isPhysical': androidInfo.isPhysicalDevice,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'platform': 'iOS',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'version': iosInfo.systemVersion,
        'isPhysical': iosInfo.isPhysicalDevice,
      };
    }
    return {'platform': 'Unknown'};
  }

  // Request all necessary permissions
  static Future<bool> requestAllPermissions() async {
    try {
      final permissions = [
        ph.Permission.camera,
        ph.Permission.microphone,
        ph.Permission.photos,
        ph.Permission.storage,
        ph.Permission.location,
      ];
      final statuses = await permissions.request();
      return statuses.values.every((status) =>
          status == ph.PermissionStatus.granted ||
          status == ph.PermissionStatus.limited);
    } catch (e) {
      // ignore: avoid_print
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // Check if all permissions are granted
  static Future<Map<ph.Permission, ph.PermissionStatus>>
      checkAllPermissions() async {
    final permissions = [
      ph.Permission.camera,
      ph.Permission.microphone,
      ph.Permission.photos,
      ph.Permission.storage,
      ph.Permission.location,
    ];
    final Map<ph.Permission, ph.PermissionStatus> statuses = {};
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }
    return statuses;
  }

  // Show permission settings
  static Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }
}
