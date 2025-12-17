import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_character.dart';
import '../../models/chat_message.dart';
import '../../services/gemini_chat_service.dart';
import '../../widgets/common/detail_header.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input_bar.dart';

class ChatScreen extends StatefulWidget {
  final ChatCharacter character;
  final AppThemeColors colors;

  const ChatScreen({super.key, required this.character, required this.colors});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final GeminiChatService _chatService = GeminiChatService();

  bool _isTyping = false;
  bool _isWaitingResponse = false;
  bool _isRateLimited = false;
  int _rateLimitSeconds = 0;
  Timer? _rateLimitTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _rateLimitTimer?.cancel();
    super.dispose();
  }

  void _loadInitialMessages() {
    _messages.add(
      ChatMessage.text(
        id: 'welcome',
        text: "Hello! I'm ${widget.character.name}. How can I help you today?",
        sender: MessageSender.character,
        timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
      ),
    );
  }

  void _startRateLimitCountdown(int seconds) {
    setState(() {
      _isRateLimited = true;
      _rateLimitSeconds = seconds;
      _isTyping = false;
      _isWaitingResponse = false;
    });

    _rateLimitTimer?.cancel();
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _rateLimitSeconds--;
        if (_rateLimitSeconds <= 0) {
          _isRateLimited = false;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _onSendText(String text) async {
    if (_isWaitingResponse || _isRateLimited) return;

    print('═══════════════════════════════════════');
    print('🔵 NEW MESSAGE: $text');
    print('═══════════════════════════════════════');

    final userMessage = ChatMessage.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _isWaitingResponse = true;
    });

    final result = await _chatService.sendTextMessage(
      character: widget.character,
      userMessage: text,
      conversationHistory: _messages,
    );

    if (result.isRateLimited) {
      print('🚫 Rate limited! Waiting ${result.retryAfterSeconds}s');
      _startRateLimitCountdown(result.retryAfterSeconds ?? 60);
      _addCharacterMessage(
        "Give me a moment... I need to catch my breath. Try again in about a minute.",
      );
      return;
    }

    if (result.isSuccess) {
      _addCharacterMessage(result.response!);
    } else {
      print('❌ Error: ${result.errorMessage}');
      _addCharacterMessage(_getCharacterFallbackMessage());
    }
  }

  Future<void> _onSendImage(Uint8List imageBytes, String? caption) async {
    if (_isWaitingResponse || _isRateLimited) return;

    print(
      '🖼️ Sending image${caption != null ? " with caption: $caption" : ""}',
    );

    final userMessage = ChatMessage.image(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      text: caption,
      imageBytes: imageBytes,
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _isWaitingResponse = true;
    });

    final result = await _chatService.sendImageMessage(
      character: widget.character,
      imageBytes: imageBytes,
      caption: caption,
      conversationHistory: _messages,
    );

    if (result.isRateLimited) {
      _startRateLimitCountdown(result.retryAfterSeconds ?? 60);
      _addCharacterMessage("I need a moment... Try again shortly.");
      return;
    }

    if (result.isSuccess) {
      _addCharacterMessage(result.response!);
    } else {
      _addCharacterMessage(
        "I see you've shared something. Tell me more about it.",
      );
    }
  }

  String _getCharacterFallbackMessage() {
    final fallbacks = [
      "Hmm, I seem to have lost my train of thought. What were we discussing?",
      "My mind wandered for a moment. Could you repeat that?",
      "I... I'm not sure what to say to that. Perhaps we could talk about something else?",
    ];
    return fallbacks[DateTime.now().second % fallbacks.length];
  }

  void _addCharacterMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage.text(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          sender: MessageSender.character,
        ),
      );
      _isTyping = false;
      _isWaitingResponse = false;
    });
  }

  void _resetConversation() {
    setState(() {
      _messages.clear();
      _loadInitialMessages();
      _isRateLimited = false;
      _rateLimitSeconds = 0;
    });
    _rateLimitTimer?.cancel();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Conversation reset')));
  }

  String _getInputHint() {
    if (_isRateLimited) {
      return 'Wait $_rateLimitSeconds seconds...';
    }
    if (_isWaitingResponse) {
      return '${widget.character.name} is typing...';
    }
    return 'Text message';
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> chatItems = [];

    // Typing indicator
    if (_isTyping && !_isRateLimited) {
      chatItems.add(_buildTypingIndicator());
    }

    // Messages (reversed for bottom-up display)
    for (int i = _messages.length - 1; i >= 0; i--) {
      chatItems.add(
        MessageBubble(message: _messages[i], colors: widget.colors),
      );
    }

    return Scaffold(
      backgroundColor: widget.colors.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          DetailHeader(
            colors: widget.colors,
            character: widget.character,
            onBackPressed: () => Navigator.of(context).pop(),
          ),

          // Rate limit banner
          if (_isRateLimited)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: widget.colors.warning.withOpacity(0.2),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: widget.colors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rate limited. Please wait $_rateLimitSeconds seconds...',
                      style: TextStyle(
                        color: widget.colors.warning,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: GestureDetector(
              onLongPress: () => _showResetDialog(),
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: chatItems.length,
                itemBuilder: (context, index) => chatItems[index],
              ),
            ),
          ),

          ChatInputBar(
            colors: widget.colors,
            onSendText: _onSendText,
            onSendImage: _onSendImage,
            enabled: !_isWaitingResponse && !_isRateLimited,
            hintText: _getInputHint(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.colors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Padding(
                  padding: EdgeInsets.only(left: index > 0 ? 4 : 0),
                  child: _AnimatedDot(
                    color: widget.colors.textSecondary,
                    delay: index * 150,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset conversation?'),
            content: const Text(
              'This will clear all messages and start fresh. '
              'Use this if the AI is stuck or rate limited.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetConversation();
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }
}

/// Animated dot for typing indicator
class _AnimatedDot extends StatefulWidget {
  final Color color;
  final int delay;

  const _AnimatedDot({required this.color, required this.delay});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}
