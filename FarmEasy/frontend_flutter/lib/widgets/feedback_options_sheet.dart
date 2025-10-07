import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/feedback_models.dart';
import '../services/feedback_service.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';

class FeedbackOptionsSheet extends StatefulWidget {
  final Function(String) onFeedbackSubmitted;
  const FeedbackOptionsSheet({super.key, required this.onFeedbackSubmitted});

  @override
  State<FeedbackOptionsSheet> createState() => _FeedbackOptionsSheetState();
}

class _FeedbackOptionsSheetState extends State<FeedbackOptionsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  FeedbackType _selectedType = FeedbackType.general;
  String _selectedCategory = 'general';
  int _rating = 5;
  File? _screenshot;
  bool _isSubmitting = false;

  final List<String> _categories = const [
    'general',
    'bug',
    'feature',
    'improvement',
    'ui_ux',
    'performance',
    'other'
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildFeedbackType(),
                  const SizedBox(height: 20),
                  _buildCategory(),
                  const SizedBox(height: 20),
                  _buildRatingSection(),
                  const SizedBox(height: 20),
                  _buildSubjectField(),
                  const SizedBox(height: 16),
                  _buildMessageField(),
                  const SizedBox(height: 20),
                  _buildScreenshotSection(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              const Icon(Icons.feedback, color: AppConstants.primaryGreen, size: 24),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share Your Feedback',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Help us improve FarmEasy',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildFeedbackType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Feedback Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FeedbackType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.primaryGreen
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: AppConstants.primaryGreen)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getTypeIcon(type),
                        size: 16,
                        color:
                            isSelected ? Colors.white : Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(_getTypeDisplayName(type),
                        style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _categories
              .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryDisplayName(category))))
              .toList(),
          onChanged: (value) => setState(() => _selectedCategory = value!),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How would you rate your experience?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            final star = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = star),
              child: Icon(star <= _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber, size: 32),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(_getRatingDescription(_rating),
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSubjectField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subject',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subjectController,
          decoration: InputDecoration(
            hintText: 'Brief description of your feedback',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a subject';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Message',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Please provide detailed feedback...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your feedback message';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildScreenshotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Screenshot (Optional)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (_screenshot != null) ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                  image: FileImage(_screenshot!), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                  onPressed: _pickScreenshot,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Change Screenshot')),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _screenshot = null),
                icon: const Icon(Icons.delete, color: Colors.red),
                label:
                    const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ] else ...[
          GestureDetector(
            onTap: _pickScreenshot,
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.grey, size: 32),
                  SizedBox(height: 8),
                  Text('Tap to add screenshot',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Submit Feedback',
                style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  IconData _getTypeIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return Icons.bug_report;
      case FeedbackType.feature:
        return Icons.lightbulb;
      case FeedbackType.improvement:
        return Icons.trending_up;
      case FeedbackType.compliment:
        return Icons.favorite;
      case FeedbackType.complaint:
        return Icons.sentiment_dissatisfied;
      case FeedbackType.question:
        return Icons.help;
      case FeedbackType.general:
        return Icons.chat;
    }
  }

  String _getTypeDisplayName(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return 'Bug Report';
      case FeedbackType.feature:
        return 'Feature Request';
      case FeedbackType.improvement:
        return 'Improvement';
      case FeedbackType.compliment:
        return 'Compliment';
      case FeedbackType.complaint:
        return 'Complaint';
      case FeedbackType.question:
        return 'Question';
      case FeedbackType.general:
        return 'General';
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'general':
        return 'General';
      case 'bug':
        return 'Bug/Error';
      case 'feature':
        return 'New Feature';
      case 'improvement':
        return 'Improvement';
      case 'ui_ux':
        return 'UI/UX Design';
      case 'performance':
        return 'Performance';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Very Poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Future<void> _pickScreenshot() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _screenshot = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking screenshot: $e')),
      );
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user;
      if (user == null) {
        throw Exception('Please log in to submit feedback');
      }
      final feedbackId = await FeedbackService().submitFeedback(
        userId: (user.id ?? 0).toString(),
        userName: user.username,
        type: _selectedType,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        rating: _rating,
        category: _selectedCategory,
        screenshot: _screenshot,
      );
      widget.onFeedbackSubmitted(feedbackId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully! Thank you.'),
            backgroundColor: AppConstants.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error submitting feedback: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
