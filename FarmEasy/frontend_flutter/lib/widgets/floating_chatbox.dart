import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/feedback_service.dart';
import '../providers/user_provider.dart';
import '../models/feedback_models.dart';
import '../utils/constants.dart';
import 'feedback_options_sheet.dart';
import 'rating_dialog.dart';

class FloatingChatbox extends StatefulWidget {
  const FloatingChatbox({super.key});

  @override
  State<FloatingChatbox> createState() => _FloatingChatboxState();
}

class _FloatingChatboxState extends State<FloatingChatbox>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isMinimized = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _bounceController;
  late AnimationController _expandController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    final userProvider = context.read<UserProvider>();
    if (userProvider.user != null) {
      FeedbackService()
          .startAnalyticsSession((userProvider.user!.id ?? 0).toString());
    }
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _expandController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));
    // We rely on AnimatedContainer for size; _expandController used to sync state changes.
    _startPeriodicBounce();
  }

  void _startPeriodicBounce() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!_isExpanded && mounted) {
        _bounceController.forward().then((_) {
          _bounceController.reverse();
          _startPeriodicBounce();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Consumer<FeedbackService>(
        builder: (context, feedbackService, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isExpanded ? 320 : 60,
            height: _isExpanded ? 500 : 60,
            child: _isMinimized
                ? _buildMinimizedButton()
                : _isExpanded
                    ? _buildExpandedChatbox(feedbackService)
                    : _buildFloatingButton(),
          );
        },
      ),
    );
  }

  Widget _buildFloatingButton() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppConstants.primaryGreen, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppConstants.primaryGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _toggleChat,
                child: const Center(
                    child: Icon(Icons.chat_bubble_outline,
                        color: Colors.white, size: 28)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimizedButton() {
    return Container(
      width: 60,
      height: 30,
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => setState(() {
            _isMinimized = false;
            _isExpanded = true;
            _expandController.forward();
          }),
          child: const Center(
              child:
                  Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20)),
        ),
      ),
    );
  }

  Widget _buildExpandedChatbox(FeedbackService feedbackService) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          _buildChatHeader(),
          _buildChatBody(feedbackService),
          _buildQuickReplies(feedbackService),
          _buildMessageInput(feedbackService),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppConstants.primaryGreen, Colors.green.shade600]),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Row(children: [
        const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 16,
            child: Icon(Icons.support_agent,
                color: AppConstants.primaryGreen, size: 20)),
        const SizedBox(width: 12),
        const Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('FarmEasy Support',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            Text("We're here to help!",
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        IconButton(
            icon: const Icon(Icons.minimize, color: Colors.white),
            onPressed: () => setState(() {
                  _isMinimized = true;
                  _isExpanded = false;
                  _expandController.reverse();
                })),
        IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _toggleChat),
      ]),
    );
  }

  Widget _buildChatBody(FeedbackService feedbackService) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: feedbackService.chatHistory.isEmpty
            ? _buildWelcomeMessage()
            : ListView.builder(
                controller: _scrollController,
                itemCount: feedbackService.chatHistory.length,
                itemBuilder: (context, index) {
                  final m = feedbackService.chatHistory[index];
                  return _buildMessageBubble(m);
                },
              ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppConstants.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.waving_hand,
                  color: AppConstants.primaryGreen, size: 40)),
          const SizedBox(height: 16),
          const Text('Welcome to FarmEasy Support!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
              'How can we help you today? Share your feedback, report issues, or ask questions.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
                backgroundColor: AppConstants.primaryGreen.withOpacity(0.1),
                radius: 12,
                child: const Icon(Icons.support_agent,
                    color: AppConstants.primaryGreen, size: 12)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppConstants.primaryGreen
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.message,
                        style: TextStyle(
                            color:
                                message.isUser ? Colors.white : Colors.black87,
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(_formatTime(message.timestamp),
                        style: TextStyle(
                            color: message.isUser
                                ? Colors.white70
                                : Colors.grey.shade600,
                            fontSize: 10)),
                  ]),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
                backgroundColor: AppConstants.primaryGreen.withOpacity(0.1),
                radius: 12,
                child: const Icon(Icons.person,
                    color: AppConstants.primaryGreen, size: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickReplies(FeedbackService feedbackService) {
    if (feedbackService.chatHistory.isNotEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: feedbackService
            .getQuickReplies()
            .map((reply) => GestureDetector(
                  onTap: () => _handleQuickReply(reply, feedbackService),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppConstants.primaryGreen),
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(reply,
                        style: const TextStyle(
                            color: AppConstants.primaryGreen, fontSize: 11)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMessageInput(FeedbackService feedbackService) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300))),
      child: Row(children: [
        IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.grey),
            onPressed: () => _showFeedbackOptions(feedbackService)),
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Type your message...',
              hintStyle: const TextStyle(fontSize: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _sendMessage(feedbackService),
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: AppConstants.primaryGreen, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20)),
        ),
      ]),
    );
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
        _bounceController.stop();
        _bounceController.reset();
      } else {
        _expandController.reverse();
        _startPeriodicBounce();
      }
    });
  }

  void _sendMessage(FeedbackService feedbackService) {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    feedbackService.addUserMessage(message);
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuickReply(String reply, FeedbackService feedbackService) {
    feedbackService.addUserMessage(reply, type: MessageType.quickReply);
    if (reply == 'Report a bug') {
      Future.delayed(const Duration(milliseconds: 1500),
          () => _showFeedbackOptions(feedbackService));
    } else if (reply == 'Love the app!') {
      Future.delayed(const Duration(milliseconds: 1500),
          () => _showRatingDialog(feedbackService));
    }
  }

  void _showFeedbackOptions(FeedbackService feedbackService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => FeedbackOptionsSheet(onFeedbackSubmitted: (id) {
        feedbackService.addUserMessage(
            'Feedback submitted successfully! ID: $id',
            type: MessageType.system);
      }),
    );
  }

  void _showRatingDialog(FeedbackService feedbackService) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(onRatingSubmitted: (rating, comment) {
        feedbackService.addUserMessage(
            'Rated $rating stars${comment.isNotEmpty ? ': $comment' : ''}',
            type: MessageType.rating);
      }),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _expandController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
