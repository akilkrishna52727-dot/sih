import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_models.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onReply;
  final Function(String) onLike;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.onReply,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.user?.id.toString() ?? '';
    final isLikedByUser = message.likes.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getSenderTypeColor(message.senderType),
                  child: Text(
                    message.senderName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            message.senderName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          _buildSenderTypeBadge(message.senderType),
                        ],
                      ),
                      Text(
                        _formatTimestamp(message.timestamp),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (message.category != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getCategoryColor(message.category!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.category!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(message.category!),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Message Content
            Text(
              message.message,
              style: const TextStyle(fontSize: 15),
            ),

            // Image if exists
            if (message.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => onLike(message.id),
                  icon: Icon(
                    isLikedByUser ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 16,
                    color:
                        isLikedByUser ? AppConstants.primaryGreen : Colors.grey,
                  ),
                  label: Text(
                    '${message.likes.length}',
                    style: TextStyle(
                      color: isLikedByUser
                          ? AppConstants.primaryGreen
                          : Colors.grey,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onReply(message.id),
                  icon: const Icon(Icons.reply, size: 16, color: Colors.grey),
                  label: Text(
                    'Reply (${message.replies.length})',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showMessageOptions(context, message),
                  icon:
                      const Icon(Icons.more_vert, size: 16, color: Colors.grey),
                ),
              ],
            ),

            // Replies
            if (message.replies.isNotEmpty) ...[
              const Divider(),
              ...message.replies
                  .take(2)
                  .map((reply) => _buildReplyWidget(reply)),
              if (message.replies.length > 2)
                TextButton(
                  onPressed: () => _showAllReplies(context, message),
                  child: Text('View all ${message.replies.length} replies'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSenderTypeBadge(String senderType) {
    Color color;
    String label;

    switch (senderType) {
      case 'official':
        color = Colors.indigo;
        label = 'GOV';
        break;
      case 'expert':
        color = Colors.orange;
        label = 'EXP';
        break;
      default:
        color = AppConstants.primaryGreen;
        label = 'FAR';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReplyWidget(ChatReply reply) {
    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reply.senderName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(width: 8),
              _buildSenderTypeBadge(reply.senderType),
              const Spacer(),
              Text(
                _formatTimestamp(reply.timestamp),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reply.message,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _getSenderTypeColor(String senderType) {
    switch (senderType) {
      case 'official':
        return Colors.indigo;
      case 'expert':
        return Colors.orange;
      default:
        return AppConstants.primaryGreen;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'crop':
        return Colors.green;
      case 'weather':
        return Colors.blue;
      case 'market':
        return Colors.purple;
      case 'subsidy':
        return Colors.indigo;
      case 'pest':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  void _showMessageOptions(BuildContext context, ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Message'),
            onTap: () {
              Navigator.pop(context);
              // Implement share functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Report Message'),
            onTap: () {
              Navigator.pop(context);
              // Implement report functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Text'),
            onTap: () {
              Navigator.pop(context);
              // Implement copy functionality
            },
          ),
        ],
      ),
    );
  }

  void _showAllReplies(BuildContext context, ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Replies to ${message.senderName}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: message.replies.length,
                  itemBuilder: (context, index) =>
                      _buildReplyWidget(message.replies[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
