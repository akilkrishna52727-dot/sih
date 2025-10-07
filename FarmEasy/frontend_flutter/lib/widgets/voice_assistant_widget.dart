import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import '../services/voice_service.dart';
import '../utils/constants.dart';

class VoiceAssistantWidget extends StatefulWidget {
  const VoiceAssistantWidget({super.key});

  @override
  State<VoiceAssistantWidget> createState() => _VoiceAssistantWidgetState();
}

class _VoiceAssistantWidgetState extends State<VoiceAssistantWidget>
    with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeVoiceService() async {
    final initialized = await _voiceService.initialize();
    if (!mounted) return;
    setState(() {
      _isInitialized = initialized;
    });

    if (!initialized) {
      _showPermissionDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Voice Assistant Button
          AvatarGlow(
            animate: _isListening,
            glowColor: AppConstants.primaryGreen,
            endRadius: 35.0,
            duration: const Duration(milliseconds: 2000),
            repeatPauseDuration: const Duration(milliseconds: 100),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _isListening
                          ? Colors.red.shade400
                          : _isSpeaking
                              ? Colors.blue.shade400
                              : AppConstants.primaryGreen,
                      _isListening
                          ? Colors.red.shade600
                          : _isSpeaking
                              ? Colors.blue.shade600
                              : AppConstants.primaryGreen
                                  .withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening
                              ? Colors.red
                              : _isSpeaking
                                  ? Colors.blue
                                  : AppConstants.primaryGreen)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22.5),
                    onTap: _isInitialized
                        ? _handleVoiceButtonTap
                        : _showPermissionDialog,
                    child: Icon(
                      _isListening
                          ? Icons.mic
                          : _isSpeaking
                              ? Icons.volume_up
                              : Icons.mic_none,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Status indicator
          if (_isListening || _isSpeaking)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red : Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleVoiceButtonTap() {
    if (_isListening) {
      _stopListening();
    } else if (_isSpeaking) {
      _stopSpeaking();
    } else {
      _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) return;

    setState(() {
      _isListening = true;
      _currentText = '';
    });

    _animationController.forward();

    // Show listening dialog
    _showVoiceDialog();

    await _voiceService.startListening(
      onResult: (text) {
        if (!mounted) return;
        setState(() {
          _currentText = text;
          _isListening = false;
        });
        _animationController.reverse();
      },
    );
  }

  Future<void> _stopListening() async {
    await _voiceService.stopListening();
    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
    _animationController.reverse();
    Navigator.of(context).pop(); // Close dialog
  }

  Future<void> _stopSpeaking() async {
    await _voiceService.stopSpeaking();
    if (!mounted) return;
    setState(() {
      _isSpeaking = false;
    });
  }

  void _showVoiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Update dialog state when voice service state changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setDialogState(() {
              _isListening = _voiceService.isListening;
              _isSpeaking = _voiceService.isSpeaking;
              _currentText = _voiceService.lastWords;
            });
          });

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.volume_up,
                  color: _isListening ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(_isListening ? 'Listening...' : 'Speaking...'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isListening) ...[
                  AvatarGlow(
                    animate: true,
                    glowColor: Colors.red,
                    endRadius: 60.0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.mic, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Speak now...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  if (_currentText.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ] else ...[
                  const Icon(Icons.volume_up, color: Colors.blue, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Processing your request...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _stopSpeaking();
                    Navigator.of(context).pop();
                  }
                },
                child: Text(_isListening ? 'Stop Listening' : 'Stop Speaking'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Microphone Permission'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voice Assistant needs microphone permission to help you.'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('-  Ask about weather and crops'),
            Text('-  Get market price information'),
            Text('-  Find suppliers and harvesters'),
            Text('-  Navigate through the app'),
            Text('-  Get farming advice'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeVoiceService();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
