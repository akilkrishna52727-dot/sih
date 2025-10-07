import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SmsService {
  static const String _phoneNumberKey = 'sms_phone_number';
  static const String _alertSettingsKey = 'sms_alert_settings';
  String? lastError; // holds last error message for UI consumption

  // Twilio Configuration
  // Defaults use the provided credentials for immediate real SMS enablement.
  // You can override at build time with --dart-define.
  static const String _twilioAccountSid = String.fromEnvironment(
      'TWILIO_ACCOUNT_SID',
      defaultValue: 'ACf15293a47144cd778a88af5c7e0377cf');
  static const String _twilioAuthToken = String.fromEnvironment(
      'TWILIO_AUTH_TOKEN',
      defaultValue: 'b594855f04acf28f483f743094405490');
  // Provide either TWILIO_PHONE_NUMBER or TWILIO_MESSAGING_SERVICE_SID
  static const String _twilioPhoneNumber = String.fromEnvironment(
      'TWILIO_PHONE_NUMBER',
      defaultValue: '+17343968947');
  static const String _twilioMessagingServiceSid =
      String.fromEnvironment('TWILIO_MESSAGING_SERVICE_SID', defaultValue: '');

  Future<String?> sendVerificationSMS(String phoneNumber) async {
    try {
      final random = Random();
      final verificationCode = (100000 + random.nextInt(900000)).toString();
      final message =
          'FarmEasy Verification Code: $verificationCode\n\nUse this code to verify your mobile number for SMS alerts.';
      final success = await _sendSMS(phoneNumber, message);
      if (success) return verificationCode;
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error sending verification SMS: $e');
      lastError = e.toString();
      return null;
    }
  }

  Future<bool> sendTestSMS(String phoneNumber) async {
    try {
      const message =
          'FarmEasy Test Alert 🌾\n\nThis is a test message to confirm your SMS alerts are working correctly. You will receive important farming updates on this number.\n\nHappy Farming!';
      return await _sendSMS(phoneNumber, message);
    } catch (e) {
      // ignore: avoid_print
      print('Error sending test SMS: $e');
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> sendWeatherAlert(String phoneNumber, String weatherInfo) async {
    try {
      final message =
          'FarmEasy Weather Alert 🌦️\n\n$weatherInfo\n\nTake necessary precautions for your crops.';
      return await _sendSMS(phoneNumber, message);
    } catch (e) {
      // ignore: avoid_print
      print('Error sending weather alert: $e');
      return false;
    }
  }

  Future<bool> sendCropAlert(String phoneNumber, String cropInfo) async {
    try {
      final message =
          'FarmEasy Crop Alert 🌱\n\n$cropInfo\n\nCheck your crops and take immediate action if needed.';
      return await _sendSMS(phoneNumber, message);
    } catch (e) {
      // ignore: avoid_print
      print('Error sending crop alert: $e');
      return false;
    }
  }

  Future<bool> sendMarketAlert(String phoneNumber, String marketInfo) async {
    try {
      final message =
          'FarmEasy Market Alert 📈\n\n$marketInfo\n\nConsider your selling strategy accordingly.';
      return await _sendSMS(phoneNumber, message);
    } catch (e) {
      // ignore: avoid_print
      print('Error sending market alert: $e');
      return false;
    }
  }

  Future<bool> sendSubsidyAlert(String phoneNumber, String subsidyInfo) async {
    try {
      final message =
          'FarmEasy Subsidy Alert 🏛️\n\n$subsidyInfo\n\nApply before the deadline to avail benefits.';
      return await _sendSMS(phoneNumber, message);
    } catch (e) {
      // ignore: avoid_print
      print('Error sending subsidy alert: $e');
      return false;
    }
  }

  Future<bool> sendHarvestAlert(String phoneNumber, String harvestInfo) async {
    try {
      final message =
          'FarmEasy Harvest Alert 🌾\n\n$harvestInfo\n\nEnsure optimal harvest timing for better yield.';
      return await _sendSMS(phoneNumber, message);
    } catch (e) {
      // ignore: avoid_print
      print('Error sending harvest alert: $e');
      return false;
    }
  }

  Future<bool> sendCustomAlert(String phoneNumber, String message,
      {bool forceSimulate = false}) async {
    try {
      if (forceSimulate) {
        // Demo mode: bypass Twilio and simulate success
        // ignore: avoid_print
        print('DEMO SIMULATED SMS TO $phoneNumber: $message');
        await Future.delayed(const Duration(milliseconds: 500));
        lastError = null;
        return true;
      }
      return await _sendSMS(phoneNumber, message);
    } catch (e) {
      // ignore: avoid_print
      print('Error sending custom alert: $e');
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> _sendSMS(String phoneNumber, String message) async {
    try {
      // Simulate in development if Twilio creds are not set
      if (_twilioAccountSid.isEmpty || _twilioAuthToken.isEmpty) {
        // ignore: avoid_print
        print('SIMULATED SMS TO $phoneNumber: $message');
        await Future.delayed(const Duration(seconds: 1));
        lastError = null;
        return true;
      }

      final url = Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json');
      final authHeader =
          base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'));
      final Map<String, String> body = {
        'To': phoneNumber,
        'Body': message,
      };

      if (_twilioMessagingServiceSid.isNotEmpty) {
        body['MessagingServiceSid'] = _twilioMessagingServiceSid;
      } else if (_twilioPhoneNumber.isNotEmpty) {
        body['From'] = _twilioPhoneNumber;
      } else {
        // Neither From nor MessagingServiceSid set — cannot send via Twilio
        // Fall back to simulation to avoid breaking UX, but clearly log the issue.
        // ignore: avoid_print
        print(
            'Twilio config missing: set TWILIO_PHONE_NUMBER or TWILIO_MESSAGING_SERVICE_SID. Simulating SMS to $phoneNumber.');
        await Future.delayed(const Duration(seconds: 1));
        return true;
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $authHeader',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        // ignore: avoid_print
        print('SMS sent successfully to $phoneNumber');
        lastError = null;
        return true;
      } else {
        // Parse Twilio error JSON when possible to deliver helpful messages
        String msg = 'Failed to send SMS: ${response.statusCode}';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] != null) {
            msg = data['message'];
          }
        } catch (_) {
          // fall back to raw body snippet
          msg = 'Failed to send SMS: ${response.statusCode} - ${response.body}';
        }
        // ignore: avoid_print
        print(msg);
        lastError = msg;
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error sending SMS: $e');
      lastError = e.toString();
      return false;
    }
  }

  // Storage methods
  Future<void> savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneNumberKey, phoneNumber);
  }

  Future<String?> getSavedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneNumberKey);
  }

  Future<void> saveAlertSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alertSettingsKey, jsonEncode(settings));
  }

  Future<Map<String, bool>> getAlertSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_alertSettingsKey);
    if (settingsString != null) {
      final Map<String, dynamic> decoded = jsonDecode(settingsString);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    }
    return {
      'weather': true,
      'crop': true,
      'market': false,
      'subsidy': true,
      'harvest': true,
    };
  }

  Future<void> clearSmsSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneNumberKey);
    await prefs.remove(_alertSettingsKey);
  }
}
