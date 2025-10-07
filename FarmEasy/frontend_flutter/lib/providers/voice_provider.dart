import 'package:flutter/material.dart';
import '../services/voice_service.dart';

class VoiceProvider extends ChangeNotifier {
  final VoiceService _voiceService = VoiceService();

  bool _isEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'en-IN';

  bool get isEnabled => _isEnabled;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get currentLanguage => _currentLanguage;

  VoiceProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isEnabled = await _voiceService.initialize();
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_isEnabled) return;

    _isListening = true;
    notifyListeners();

    await _voiceService.startListening(onResult: (text) {
      _isListening = false;
      notifyListeners();
    });
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (!_isEnabled) return;

    _isSpeaking = true;
    notifyListeners();

    await _voiceService.speak(text, language: _currentLanguage);

    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _voiceService.setLanguage(languageCode);
    notifyListeners();
  }

  // Pre-defined voice responses for common farming queries
  Future<void> speakWeatherInfo() async {
    await speak(
        'Current weather is 28 degrees with partly cloudy skies. Good conditions for farming activities. No rain expected in next 6 hours.');
  }

  Future<void> speakCropAdvice(String cropType) async {
    await speak(
        'For $cropType farming, ensure proper soil preparation. Current season is suitable for planting. Monitor soil moisture and apply fertilizers as needed.');
  }

  Future<void> speakMarketPrices() async {
    await speak(
        'Current market rates: Wheat 2840 rupees per quintal, Rice 3200 rupees per quintal. Prices have increased this week. Good time to sell.');
  }

  Future<void> speakNavigationHelp() async {
    await speak(
        'You can say: Show weather, Find suppliers, Book harvester, Check market prices, or Get crop recommendations. How can I help you today?');
  }
}
