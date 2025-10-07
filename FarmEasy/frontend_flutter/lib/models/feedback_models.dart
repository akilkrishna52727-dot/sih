class UserFeedback {
  final String id;
  final String userId;
  final String userName;
  final FeedbackType type;
  final String subject;
  final String message;
  final int rating; // 1-5 stars
  final String category; // 'bug', 'feature', 'improvement', 'general'
  final Priority priority;
  final DateTime timestamp;
  final String? screenshotPath;
  final Map<String, dynamic> deviceInfo;
  final Map<String, dynamic> usageData;
  final FeedbackStatus status;
  final String? response;
  final DateTime? responseDate;

  UserFeedback({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.subject,
    required this.message,
    required this.rating,
    required this.category,
    required this.priority,
    required this.timestamp,
    this.screenshotPath,
    required this.deviceInfo,
    required this.usageData,
    required this.status,
    this.response,
    this.responseDate,
  });

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      type: FeedbackType.values.firstWhere((e) => e.name == json['type']),
      subject: json['subject'] as String,
      message: json['message'] as String,
      rating: json['rating'] as int,
      category: json['category'] as String,
      priority: Priority.values.firstWhere((e) => e.name == json['priority']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      screenshotPath: json['screenshot_path'] as String?,
      deviceInfo: Map<String, dynamic>.from(json['device_info'] ?? {}),
      usageData: Map<String, dynamic>.from(json['usage_data'] ?? {}),
      status: FeedbackStatus.values.firstWhere((e) => e.name == json['status']),
      response: json['response'] as String?,
      responseDate: json['response_date'] != null
          ? DateTime.parse(json['response_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'type': type.name,
      'subject': subject,
      'message': message,
      'rating': rating,
      'category': category,
      'priority': priority.name,
      'timestamp': timestamp.toIso8601String(),
      'screenshot_path': screenshotPath,
      'device_info': deviceInfo,
      'usage_data': usageData,
      'status': status.name,
      'response': response,
      'response_date': responseDate?.toIso8601String(),
    };
  }
}

enum FeedbackType {
  bug,
  feature,
  improvement,
  compliment,
  complaint,
  question,
  general
}

enum Priority { low, medium, high, critical }

enum FeedbackStatus { pending, reviewed, inProgress, resolved, rejected }

class UsageAnalytics {
  final String sessionId;
  final String userId;
  final DateTime sessionStart;
  final DateTime? sessionEnd;
  final Duration sessionDuration;
  final List<ScreenVisit> screenVisits;
  final List<FeatureUsage> featuresUsed;
  final List<UserAction> actions;
  final Map<String, dynamic> deviceMetrics;
  final List<ErrorLog> errors;

  UsageAnalytics({
    required this.sessionId,
    required this.userId,
    required this.sessionStart,
    this.sessionEnd,
    required this.sessionDuration,
    required this.screenVisits,
    required this.featuresUsed,
    required this.actions,
    required this.deviceMetrics,
    required this.errors,
  });
}

class ScreenVisit {
  final String screenName;
  final DateTime entryTime;
  final DateTime? exitTime;
  final Duration timeSpent;

  ScreenVisit({
    required this.screenName,
    required this.entryTime,
    this.exitTime,
    required this.timeSpent,
  });
}

class FeatureUsage {
  final String featureName;
  final int usageCount;
  final Duration totalTimeSpent;
  final bool completedSuccessfully;
  final String? errorMessage;

  FeatureUsage({
    required this.featureName,
    required this.usageCount,
    required this.totalTimeSpent,
    required this.completedSuccessfully,
    this.errorMessage,
  });
}

class UserAction {
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  UserAction({
    required this.action,
    required this.timestamp,
    required this.context,
  });
}

class ErrorLog {
  final String error;
  final String stackTrace;
  final DateTime timestamp;
  final String context;

  ErrorLog({
    required this.error,
    required this.stackTrace,
    required this.timestamp,
    required this.context,
  });
}

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    required this.type,
    this.metadata,
  });
}

enum MessageType { text, feedback, rating, screenshot, quickReply, system }
