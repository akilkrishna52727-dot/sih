import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastWords = '';

  // Getters
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;

  // Initialize voice service
  Future<bool> initialize() async {
    try {
      // Request microphone permission
      final microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus != PermissionStatus.granted) {
        return false;
      }

      // Initialize speech to text
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );

      // Initialize text to speech
      await _configureTts();

      return _speechEnabled;
    } catch (e) {
      debugPrint('Error initializing voice service: $e');
      return false;
    }
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('en-IN'); // Indian English
    await _flutterTts
        .setSpeechRate(0.5); // Slower speech for better understanding
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Set completion handler
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });
  }

  // Start listening for voice input
  Future<void> startListening({required Function(String) onResult}) async {
    if (!_speechEnabled) return;

    _isListening = true;
    _lastWords = '';

    await _speechToText.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        if (result.finalResult) {
          _isListening = false;
          onResult(_lastWords);
          _processVoiceCommand(_lastWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'en_IN', // Indian English
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  // Stop listening
  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
  }

  // Speak text aloud
  Future<void> speak(String text, {String? language}) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    _isSpeaking = true;

    if (language != null) {
      await _flutterTts.setLanguage(language);
    }

    await _flutterTts.speak(text);
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  // Process voice commands using NLP
  Future<void> _processVoiceCommand(String command) async {
    final processedCommand = await _analyzeCommand(command);
    await _executeCommand(processedCommand);
  }

  // NLP Command Analysis
  Future<Map<String, dynamic>> _analyzeCommand(String command) async {
    final lowercaseCommand = command.toLowerCase();

    // Local NLP processing for farming-specific commands
    Map<String, dynamic> result = {
      'intent': 'unknown',
      'entities': <String, dynamic>{},
      'confidence': 0.0,
    };

    // Weather queries
    if (_containsAny(lowercaseCommand,
        ['weather', 'temperature', 'rain', 'climate', 'forecast'])) {
      result['intent'] = 'weather_query';
      result['confidence'] = 0.9;
    }

    // Crop recommendations
    else if (_containsAny(lowercaseCommand,
        ['crop', 'plant', 'grow', 'recommend', 'suggestion', 'farming'])) {
      result['intent'] = 'crop_recommendation';
      result['confidence'] = 0.85;

      // Extract crop names
      final crops = [
        'wheat',
        'rice',
        'corn',
        'cotton',
        'sugarcane',
        'tomato',
        'potato'
      ];
      for (final crop in crops) {
        if (lowercaseCommand.contains(crop)) {
          result['entities']['crop'] = crop;
          break;
        }
      }
    }

    // Market prices
    else if (_containsAny(
        lowercaseCommand, ['price', 'market', 'sell', 'buy', 'rate', 'cost'])) {
      result['intent'] = 'market_query';
      result['confidence'] = 0.8;
    }

    // Harvest related
    else if (_containsAny(
        lowercaseCommand, ['harvest', 'harvester', 'cutting', 'reaping'])) {
      result['intent'] = 'harvest_service';
      result['confidence'] = 0.85;
    }

    // Suppliers
    else if (_containsAny(lowercaseCommand,
        ['supplier', 'seeds', 'fertilizer', 'pesticide', 'equipment'])) {
      result['intent'] = 'supplier_search';
      result['confidence'] = 0.8;
    }

    // Navigation commands
    else if (_containsAny(
        lowercaseCommand, ['open', 'go to', 'show', 'navigate'])) {
      result['intent'] = 'navigation';
      result['confidence'] = 0.7;

      if (lowercaseCommand.contains('marketplace')) {
        result['entities']['screen'] = 'marketplace';
      } else if (lowercaseCommand.contains('community')) {
        result['entities']['screen'] = 'farmer_community';
      }
    }

    // Help queries
    else if (_containsAny(
        lowercaseCommand, ['help', 'how to', 'what is', 'explain', 'guide'])) {
      result['intent'] = 'help_query';
      result['confidence'] = 0.75;
    }

    return result;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  // Execute processed commands
  Future<void> _executeCommand(Map<String, dynamic> command) async {
    final intent = command['intent'];
    final entities = command['entities'] as Map<String, dynamic>;

    switch (intent) {
      case 'weather_query':
        await speak(
            'Current weather is 28 degrees Celsius with partly cloudy skies. Humidity is 65% and there is a chance of light rain in the evening. Good conditions for most crops.');
        break;

      case 'crop_recommendation':
        final crop = entities['crop'];
        if (crop != null) {
          await speak(
              'For $crop cultivation, I recommend checking soil nitrogen levels first. Current season is suitable for $crop planting. Would you like detailed recommendations?');
        } else {
          await speak(
              'To provide crop recommendations, I need information about your soil condition and location. Please use the Crop Recommendation feature for detailed analysis.');
        }
        break;

      case 'market_query':
        await speak(
            'Current market prices: Wheat is 2840 rupees per quintal, Rice is 3200 rupees per quintal. Prices have increased by 12% this week. Good time to sell if you have stock ready.');
        break;

      case 'harvest_service':
        await speak(
            'I found 5 harvesters available in your area. Singh Harvesting Services has the highest rating at 4.8 stars. Average cost is 1200 rupees per acre. Would you like me to show harvester options?');
        break;

      case 'supplier_search':
        await speak(
            'I found verified suppliers for seeds, fertilizers, and equipment. AgriBegri Seeds has quality hybrid seeds available. Patel Fertilizers offers competitive rates for NPK fertilizers. Would you like contact details?');
        break;

      case 'help_query':
        await speak(
            'I can help you with weather information, crop recommendations, market prices, finding suppliers, booking harvest services, and navigating the app. What would you like to know about farming?');
        break;

      default:
        await speak(
            'I understand you said: $_lastWords. I can help with weather, crops, market prices, suppliers, and harvesters. What specific farming information do you need?');
    }
  }

  // Get available languages for TTS
  Future<List<String>> getAvailableLanguages() async {
    final languages = await _flutterTts.getLanguages;
    return languages
        .where((lang) =>
            lang.contains('en') ||
            lang.contains('hi') ||
            lang.contains('ta') ||
            lang.contains('te') ||
            lang.contains('bn') ||
            lang.contains('gu'))
        .toList();
  }

  // Set language for voice
  Future<void> setLanguage(String languageCode) async {
    String ttsLanguage;
    switch (languageCode) {
      case 'hi':
        ttsLanguage = 'hi-IN';
        break;
      case 'ta':
        ttsLanguage = 'ta-IN';
        break;
      case 'te':
        ttsLanguage = 'te-IN';
        break;
      case 'bn':
        ttsLanguage = 'bn-IN';
        break;
      case 'gu':
        ttsLanguage = 'gu-IN';
        break;
      default:
        ttsLanguage = 'en-IN';
    }

    await _flutterTts.setLanguage(ttsLanguage);
  }

  // Dispose resources
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
}
