// Model classes for chat features

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType; // 'farmer', 'official', 'expert'
  final String message;
  final DateTime timestamp;
  final String? imageUrl;
  final List<String> likes;
  final List<ChatReply> replies;
  final String?
      category; // 'crop', 'weather', 'market', 'subsidy', 'pest', 'general'

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.timestamp,
    this.imageUrl,
    List<String>? likes,
    List<ChatReply>? replies,
    this.category,
  })  : likes = likes ?? [],
        replies = replies ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_type': senderType,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      'likes': likes,
      'replies': replies.map((r) => r.toJson()).toList(),
      'category': category,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderType: json['sender_type'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['image_url'],
      likes: List<String>.from(json['likes'] ?? []),
      replies: (json['replies'] as List? ?? [])
          .map((r) => ChatReply.fromJson(r))
          .toList(),
      category: json['category'],
    );
  }
}

class ChatReply {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType;
  final String message;
  final DateTime timestamp;

  ChatReply({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_type': senderType,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    return ChatReply(
      id: json['id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderType: json['sender_type'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class GovernmentOfficial {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String location;
  final String contactNumber;
  final String email;
  final bool isAvailable;
  final List<String> specializations;

  GovernmentOfficial({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.location,
    required this.contactNumber,
    required this.email,
    required this.isAvailable,
    required this.specializations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'designation': designation,
      'department': department,
      'location': location,
      'contact_number': contactNumber,
      'email': email,
      'is_available': isAvailable,
      'specializations': specializations,
    };
  }

  factory GovernmentOfficial.fromJson(Map<String, dynamic> json) {
    return GovernmentOfficial(
      id: json['id'],
      name: json['name'],
      designation: json['designation'],
      department: json['department'],
      location: json['location'],
      contactNumber: json['contact_number'],
      email: json['email'],
      isAvailable: json['is_available'],
      specializations: List<String>.from(json['specializations']),
    );
  }
}
