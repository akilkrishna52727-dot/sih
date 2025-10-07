import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_models.dart';
import '../providers/user_provider.dart';
import '../services/chat_service.dart';
import '../utils/constants.dart';
import '../widgets/chat_message_widget.dart';
import 'government_officials_screen.dart';

class FarmerCommunityChatScreen extends StatefulWidget {
  const FarmerCommunityChatScreen({super.key});

  @override
  State<FarmerCommunityChatScreen> createState() =>
      _FarmerCommunityChatScreenState();
}

class _FarmerCommunityChatScreenState extends State<FarmerCommunityChatScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late TabController _tabController;

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'crop',
    'weather',
    'market',
    'subsidy',
    'pest',
    'general'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final chatService = ChatService();
      final messages = await chatService.getMessages(_selectedCategory);

      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Community'),
        backgroundColor: AppConstants.primaryGreen,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.forum), text: 'Community'),
            Tab(icon: Icon(Icons.contact_support), text: 'Ask Expert'),
            Tab(icon: Icon(Icons.account_balance), text: 'Officials'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommunityTab(),
          _buildAskExpertTab(),
          _buildOfficialsTab(),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;

              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getCategoryDisplayName(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                    _loadMessages();
                  },
                  selectedColor: AppConstants.primaryGreen.withOpacity(0.2),
                  checkmarkColor: AppConstants.primaryGreen,
                ),
              );
            },
          ),
        ),

        // Messages List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return ChatMessageWidget(
                          message: _messages[index],
                          onReply: (messageId) =>
                              _showReplyDialog(_messages[index]),
                          onLike: (messageId) => _toggleLike(messageId),
                        );
                      },
                    ),
        ),

        // Message Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.category,
                      color: AppConstants.primaryGreen),
                  onPressed: _showCategorySelector,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask your question or share experience...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon:
                      const Icon(Icons.send, color: AppConstants.primaryGreen),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAskExpertTab() {
    return Column(
      children: [
        // Expert Categories
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Get Expert Advice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildExpertCard(
                      'Crop Specialist', Icons.eco, Colors.green, 'Online'),
                  _buildExpertCard('Pest Control Expert', Icons.bug_report,
                      Colors.red, 'Available'),
                  _buildExpertCard(
                      'Soil Scientist', Icons.terrain, Colors.brown, 'Busy'),
                  _buildExpertCard(
                      'Weather Expert', Icons.cloud, Colors.blue, 'Online'),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.support_agent,
                    size: 60, color: Colors.blue.shade600),
                const SizedBox(height: 16),
                const Text(
                  'Expert Consultation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get professional advice from agricultural experts. Select an expert category above to start a consultation.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _requestExpertConsultation,
                  icon: const Icon(Icons.video_call),
                  label: const Text('Schedule Video Call'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfficialsTab() {
    return Column(
      children: [
        // Quick Contact Section
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Government Officials',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Contact government officials for subsidies, schemes, and policy information',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const GovernmentOfficialsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.contacts),
                      label: const Text('View All Officials'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showEmergencyContacts,
                      icon: const Icon(Icons.emergency),
                      label: const Text('Emergency Help'),
                      style:
                          OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Recent Official Communications
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5, // Sample official communications
            itemBuilder: (context, index) => _buildOfficialMessageCard(index),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No messages in ${_getCategoryDisplayName(_selectedCategory)} yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation by asking a question or sharing your farming experience',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _messageController.text = _getSampleQuestion(_selectedCategory);
              },
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Get Sample Question'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCard(
      String title, IconData icon, Color color, String status) {
    final isOnline = status == 'Online' || status == 'Available';

    return Card(
      child: InkWell(
        onTap: () => _contactExpert(title),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isOnline ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    color: isOnline
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficialMessageCard(int index) {
    final sampleData = [
      {
        'title': 'PM-KISAN Scheme Update',
        'official': 'District Collector',
        'message':
            'New installment of ₹2,000 has been released. Check your account.',
        'time': '2 hours ago',
        'priority': 'high'
      },
      {
        'title': 'Subsidy Application Status',
        'official': 'Agriculture Officer',
        'message': 'Your solar pump subsidy application is under review.',
        'time': '1 day ago',
        'priority': 'normal'
      },
      {
        'title': 'Weather Advisory',
        'official': 'Meteorological Dept.',
        'message': 'Heavy rainfall expected. Take necessary precautions.',
        'time': '3 days ago',
        'priority': 'urgent'
      },
    ];

    if (index >= sampleData.length) return const SizedBox.shrink();

    final data = sampleData[index];
    final priorityColor = data['priority'] == 'urgent'
        ? Colors.red
        : data['priority'] == 'high'
            ? Colors.orange
            : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor.withOpacity(0.1),
          child: Icon(Icons.account_balance, color: priorityColor),
        ),
        title: Text(
          data['title']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: ${data['official']}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(data['message']!),
            const SizedBox(height: 4),
            Text(
              data['time']!,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey.shade400),
        onTap: () => _viewOfficialMessage(data),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'All Topics';
      case 'crop':
        return 'Crops';
      case 'weather':
        return 'Weather';
      case 'market':
        return 'Market';
      case 'subsidy':
        return 'Subsidies';
      case 'pest':
        return 'Pest Control';
      case 'general':
        return 'General';
      default:
        return category;
    }
  }

  String _getSampleQuestion(String category) {
    switch (category) {
      case 'crop':
        return 'What is the best time to sow rice in my region?';
      case 'weather':
        return 'How to protect crops from unexpected rainfall?';
      case 'market':
        return 'What are the current market prices for wheat?';
      case 'subsidy':
        return 'How to apply for PM-KISAN scheme?';
      case 'pest':
        return 'My crops are affected by white flies. Any solutions?';
      default:
        return 'I need advice on improving my crop yield. Any suggestions?';
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userProvider = context.read<UserProvider>();
    if (userProvider.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to post messages')),
      );
      return;
    }

    try {
      final chatService = ChatService();
      final user = userProvider.user!;

      await chatService.sendMessage(
        senderId: user.id.toString(),
        senderName: user.username,
        message: _messageController.text.trim(),
        category: _selectedCategory == 'all' ? 'general' : _selectedCategory,
      );

      _messageController.clear();
      _loadMessages();

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories
                  .skip(1)
                  .map(
                    (category) => FilterChip(
                      label: Text(_getCategoryDisplayName(category)),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                        Navigator.pop(context);
                        _loadMessages();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(ChatMessage message) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to ${message.senderName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.message,
                style: const TextStyle(fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Type your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (replyController.text.trim().isNotEmpty) {
                await _sendReply(message.id, replyController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendReply(String messageId, String replyText) async {
    try {
      final chatService = ChatService();
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user!;

      await chatService.replyToMessage(
        messageId: messageId,
        senderId: user.id.toString(),
        senderName: user.username,
        reply: replyText,
      );

      _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending reply: $e')),
      );
    }
  }

  Future<void> _toggleLike(String messageId) async {
    try {
      final chatService = ChatService();
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user!;

      await chatService.toggleLike(messageId, user.id.toString());
      _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like: $e')),
      );
    }
  }

  void _contactExpert(String expertType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact $expertType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Would you like to schedule a consultation with our $expertType?'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _startChatWithExpert(expertType);
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _scheduleVideoCall(expertType);
                    },
                    icon: const Icon(Icons.video_call),
                    label: const Text('Video Call'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startChatWithExpert(String expertType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting chat with $expertType...')),
    );
  }

  void _scheduleVideoCall(String expertType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scheduling video call with $expertType...')),
    );
  }

  void _requestExpertConsultation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expert consultation request sent!')),
    );
  }

  void _showEmergencyContacts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contacts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.red),
              title: Text('Agricultural Emergency'),
              subtitle: Text('1800-180-1551'),
            ),
            ListTile(
              leading: Icon(Icons.support_agent, color: Colors.blue),
              title: Text('Kisan Call Center'),
              subtitle: Text('1800-180-1551'),
            ),
            ListTile(
              leading: Icon(Icons.wb_sunny, color: Colors.orange),
              title: Text('Weather Helpline'),
              subtitle: Text('1800-266-0111'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewOfficialMessage(Map<String, String> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['title']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${data['official']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(data['message']!),
            const SizedBox(height: 8),
            Text('Time: ${data['time']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Reply to official
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }
}
