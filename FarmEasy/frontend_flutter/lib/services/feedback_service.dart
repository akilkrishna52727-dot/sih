import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/feedback_models.dart';
import 'platform_service.dart';

class FeedbackService extends ChangeNotifier {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final List<UserFeedback> _feedbacks = [];
  final List<ChatMessage> _chatHistory = [];
  UsageAnalytics? _currentSession;
  DateTime? _sessionStart;
  final Map<String, int> _featureUsage = {};
  final List<ScreenVisit> _screenVisits = [];

  List<UserFeedback> get feedbacks => List.unmodifiable(_feedbacks);
  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);

  Future<void> startAnalyticsSession(String userId) async {
    _sessionStart = DateTime.now();
    final deviceInfo = await PlatformService.getDeviceInfo();
    _currentSession = UsageAnalytics(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      sessionStart: _sessionStart!,
      sessionDuration: Duration.zero,
      screenVisits: [],
      featuresUsed: [],
      actions: [],
      deviceMetrics: deviceInfo,
      errors: [],
    );
    notifyListeners();
  }

  void trackScreenVisit(String screenName) {
    if (_currentSession == null) return;
    final visit = ScreenVisit(
      screenName: screenName,
      entryTime: DateTime.now(),
      timeSpent: Duration.zero,
    );
    _screenVisits.add(visit);
    _logUserAction('screen_visit', {'screen': screenName});
  }

  void trackFeatureUsage(String featureName,
      {bool success = true, String? error}) {
    _featureUsage[featureName] = (_featureUsage[featureName] ?? 0) + 1;
    _logUserAction('feature_use', {
      'feature': featureName,
      'success': success,
      'error': error,
      'usage_count': _featureUsage[featureName],
    });
  }

  void _logUserAction(String action, Map<String, dynamic> context) {
    if (_currentSession == null) return;
    // ignore: avoid_print
    print('User Action: $action - ${jsonEncode(context)}');
  }

  Future<String> submitFeedback({
    required String userId,
    required String userName,
    required FeedbackType type,
    required String subject,
    required String message,
    required int rating,
    required String category,
    File? screenshot,
  }) async {
    try {
      final deviceInfo = await PlatformService.getDeviceInfo();
      final feedbackId = 'feedback_${DateTime.now().millisecondsSinceEpoch}';
      String? screenshotPath;
      if (screenshot != null) {
        screenshotPath = await _saveScreenshot(screenshot, feedbackId);
      }
      final Priority priority = _determinePriority(type, rating);
      final feedback = UserFeedback(
        id: feedbackId,
        userId: userId,
        userName: userName,
        type: type,
        subject: subject,
        message: message,
        rating: rating,
        category: category,
        priority: priority,
        timestamp: DateTime.now(),
        screenshotPath: screenshotPath,
        deviceInfo: deviceInfo,
        usageData: _collectUsageData(),
        status: FeedbackStatus.pending,
      );
      _feedbacks.add(feedback);
      await _saveFeedbackLocally(feedback);
      await _sendFeedbackToServer(feedback);
      _addChatMessage(
        "Thank you for your feedback! We've received your ${type.name} report and will review it soon.",
        isUser: false,
        type: MessageType.system,
      );
      trackFeatureUsage('feedback_submit', success: true);
      notifyListeners();
      return feedbackId;
    } catch (e) {
      trackFeatureUsage('feedback_submit', success: false, error: e.toString());
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Priority _determinePriority(FeedbackType type, int rating) {
    if (type == FeedbackType.bug && rating <= 2) return Priority.critical;
    if (type == FeedbackType.bug && rating <= 3) return Priority.high;
    if (type == FeedbackType.feature) return Priority.medium;
    if (rating <= 2) return Priority.high;
    return Priority.medium;
  }

  Future<String> _saveScreenshot(File screenshot, String feedbackId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final feedbackDir = Directory('${directory.path}/feedback_screenshots');
      if (!await feedbackDir.exists()) {
        await feedbackDir.create(recursive: true);
      }
      final fileName = 'screenshot_$feedbackId.png';
      final savedPath = '${feedbackDir.path}/$fileName';
      await screenshot.copy(savedPath);
      return savedPath;
    } catch (e) {
      // ignore: avoid_print
      print('Error saving screenshot: $e');
      return '';
    }
  }

  Map<String, dynamic> _collectUsageData() {
    return {
      'session_duration': _sessionStart != null
          ? DateTime.now().difference(_sessionStart!).inMinutes
          : 0,
      'features_used': _featureUsage,
      'screens_visited': _screenVisits.map((v) => v.screenName).toList(),
      'total_screen_visits': _screenVisits.length,
    };
  }

  Future<void> _saveFeedbackLocally(UserFeedback feedback) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbackList = prefs.getStringList('user_feedbacks') ?? [];
      feedbackList.add(jsonEncode(feedback.toJson()));
      await prefs.setStringList('user_feedbacks', feedbackList);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving feedback locally: $e');
    }
  }

  Future<void> _sendFeedbackToServer(UserFeedback feedback) async {
    await Future.delayed(const Duration(seconds: 1));
    // ignore: avoid_print
    print('Feedback sent to server: ${feedback.id}');
  }

  void addUserMessage(String message, {MessageType type = MessageType.text}) {
    _addChatMessage(message, isUser: true, type: type);
    _processUserMessage(message, type);
  }

  void _addChatMessage(
    String message, {
    required bool isUser,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) {
    final chatMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      isUser: isUser,
      timestamp: DateTime.now(),
      type: type,
      metadata: metadata,
    );
    _chatHistory.add(chatMessage);
    notifyListeners();
  }

  void _processUserMessage(String message, MessageType type) {
    Future.delayed(const Duration(milliseconds: 800), () {
      final response = _generateResponse(message, type);
      _addChatMessage(response, isUser: false, type: MessageType.text);
    });
  }

  String _generateResponse(String message, MessageType type) {
    final lower = message.toLowerCase();
    if (type == MessageType.rating) {
      return 'Thank you for the rating! Would you like to share more details about your experience?';
    }
    if (lower.contains('bug') ||
        lower.contains('error') ||
        lower.contains('problem')) {
      return "I'm sorry you are experiencing issues. Could you describe the problem? A screenshot would help.";
    }
    if (lower.contains('feature') ||
        lower.contains('suggestion') ||
        lower.contains('improvement')) {
      return 'Great suggestion! Please tell me more about what you would like to see.';
    }
    if (lower.contains('slow') || lower.contains('performance')) {
      return 'Which features are running slowly? Also, what device are you using?';
    }
    if (lower.contains('crash') || lower.contains('freeze')) {
      return 'When does this happen? What were you doing when it crashed?';
    }
    if (lower.contains('help') || lower.contains('how')) {
      return "I'm here to help! You can report bugs, suggest features, share feedback, or ask questions.";
    }
    if (lower.contains('thank') ||
        lower.contains('good') ||
        lower.contains('great')) {
      return 'Thank you for the kind words! Your feedback motivates us!';
    }
    const responses = [
      'Thanks! Could you provide more details?',
      'I understand. Can you tell me more about your experience?',
      "That's valuable feedback. What specific aspects should we improve?",
      'We appreciate you taking the time. How can we make your experience better?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  Map<String, dynamic> getFeedbackStats() {
    final now = DateTime.now();
    final last30 = now.subtract(const Duration(days: 30));
    final recent =
        _feedbacks.where((f) => f.timestamp.isAfter(last30)).toList();
    return {
      'total_feedbacks': _feedbacks.length,
      'recent_feedbacks': recent.length,
      'average_rating': _feedbacks.isNotEmpty
          ? _feedbacks.map((f) => f.rating).reduce((a, b) => a + b) /
              _feedbacks.length
          : 0.0,
      'bug_reports': _feedbacks.where((f) => f.type == FeedbackType.bug).length,
      'feature_requests':
          _feedbacks.where((f) => f.type == FeedbackType.feature).length,
      'response_rate': _feedbacks.isEmpty
          ? 0
          : _feedbacks.where((f) => f.response != null).length /
              _feedbacks.length *
              100,
    };
  }

  void clearChatHistory() {
    _chatHistory.clear();
    notifyListeners();
  }

  List<String> getQuickReplies() {
    return const [
      'Report a bug',
      'Suggest a feature',
      'App is slow',
      'Love the app!',
      'Need help',
      'Other feedback',
    ];
  }
}
