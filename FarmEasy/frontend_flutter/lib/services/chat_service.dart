import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_models.dart';

class ChatService {
  static const String _messagesKey = 'chat_messages';

  Future<List<ChatMessage>> getMessages([String category = 'all']) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString(_messagesKey);

      List<ChatMessage> messages = [];

      if (messagesString != null) {
        final List<dynamic> messagesJson = jsonDecode(messagesString);
        messages =
            messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        // Load sample messages for demo
        messages = _generateSampleMessages();
        await _saveMessages(messages);
      }

      // Filter by category if specified
      if (category != 'all') {
        messages = messages.where((m) => m.category == category).toList();
      }

      // Sort by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return messages;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading messages: $e');
      return _generateSampleMessages();
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String message,
    String category = 'general',
    String? imageUrl,
  }) async {
    try {
      final allMessages = await getMessages('all');

      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        senderName: senderName,
        senderType: 'farmer',
        message: message,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
        category: category,
      );

      allMessages.insert(0, newMessage);
      await _saveMessages(allMessages);

      // Simulate expert/official responses
      _simulateResponses(newMessage, allMessages);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> replyToMessage({
    required String messageId,
    required String senderId,
    required String senderName,
    required String reply,
  }) async {
    try {
      final allMessages = await getMessages('all');

      final messageIndex = allMessages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        final newReply = ChatReply(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: senderId,
          senderName: senderName,
          senderType: 'farmer',
          message: reply,
          timestamp: DateTime.now(),
        );

        allMessages[messageIndex].replies.add(newReply);
        await _saveMessages(allMessages);
      }
    } catch (e) {
      throw Exception('Failed to reply: $e');
    }
  }

  Future<void> toggleLike(String messageId, String userId) async {
    try {
      final allMessages = await getMessages('all');

      final messageIndex = allMessages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        final message = allMessages[messageIndex];

        if (message.likes.contains(userId)) {
          message.likes.remove(userId);
        } else {
          message.likes.add(userId);
        }

        await _saveMessages(allMessages);
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  Future<void> _saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = messages.map((m) => m.toJson()).toList();
    await prefs.setString(_messagesKey, jsonEncode(messagesJson));
  }

  void _simulateResponses(
      ChatMessage originalMessage, List<ChatMessage> allMessages) {
    // Simulate expert/official responses after a delay
    Future.delayed(const Duration(seconds: 5), () async {
      final responses = _generateResponse(originalMessage);

      for (var response in responses) {
        allMessages.insert(0, response);
      }

      await _saveMessages(allMessages);
    });
  }

  List<ChatMessage> _generateResponse(ChatMessage originalMessage) {
    final random = Random();
    final responses = <ChatMessage>[];

    // Simulate expert response based on category
    if (originalMessage.category == 'pest') {
      responses.add(ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch + 1}',
        senderId: 'expert_1',
        senderName: 'Dr. Rajesh Kumar',
        senderType: 'expert',
        message:
            'For pest control, I recommend using neem-based organic pesticides. Apply early morning or late evening for best results. Also check soil moisture levels.',
        timestamp: DateTime.now().add(const Duration(seconds: 5)),
        category: 'pest',
      ));
    } else if (originalMessage.category == 'subsidy') {
      responses.add(ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch + 2}',
        senderId: 'official_1',
        senderName: 'Agriculture Officer',
        senderType: 'official',
        message:
            'You can apply for the PM-KISAN scheme online at pmkisan.gov.in. Make sure to have your Aadhaar card and bank details ready. The application deadline is next month.',
        timestamp: DateTime.now().add(const Duration(seconds: 8)),
        category: 'subsidy',
      ));
    } else if (random.nextBool()) {
      // Random farmer response
      final farmerNames = [
        'Ramesh Singh',
        'Priya Sharma',
        'Kiran Patel',
        'Suresh Yadav'
      ];
      responses.add(ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch + 3}',
        senderId: 'farmer_${random.nextInt(100)}',
        senderName: farmerNames[random.nextInt(farmerNames.length)],
        senderType: 'farmer',
        message:
            'I faced a similar issue last season. Try consulting with your local agriculture extension officer. They provide good guidance.',
        timestamp: DateTime.now().add(const Duration(seconds: 10)),
        category: originalMessage.category,
      ));
    }

    return responses;
  }

  List<ChatMessage> _generateSampleMessages() {
    return [
      ChatMessage(
        id: '1',
        senderId: 'farmer_1',
        senderName: 'Rajesh Farmer',
        senderType: 'farmer',
        message:
            'What is the best fertilizer for wheat crop in winter season? My soil test shows low nitrogen content.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'crop',
        likes: ['user_1', 'user_2'],
        replies: [
          ChatReply(
            id: 'r1',
            senderId: 'expert_1',
            senderName: 'Dr. Agricultural Expert',
            senderType: 'expert',
            message:
                'For low nitrogen soil, use DAP fertilizer at 100kg per hectare during sowing. Follow up with urea after 3 weeks.',
            timestamp:
                DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          ),
        ],
      ),
      ChatMessage(
        id: '2',
        senderId: 'farmer_2',
        senderName: 'Priya Singh',
        senderType: 'farmer',
        message:
            'Heavy rains are predicted next week. Should I harvest my rice crop now or wait? The grains are 80% mature.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        category: 'weather',
        likes: ['user_3'],
      ),
      ChatMessage(
        id: '3',
        senderId: 'official_1',
        senderName: 'District Collector',
        senderType: 'official',
        message:
            'New PM-KISAN installment of ₹2,000 has been released. Farmers who haven\'t received it should contact the nearest Common Service Center.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        category: 'subsidy',
        likes: ['user_1', 'user_4', 'user_5'],
      ),
    ];
  }
}
