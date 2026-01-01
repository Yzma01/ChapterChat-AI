import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/bloc/chat_bloc.dart';
import '../../blocs/chat/bloc/chat_event.dart';
import '../../blocs/chat/bloc/chat_state.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_character.dart';
import '../../widgets/common/detail_header.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/chat/chat_rate_limit_banner.dart';
import '../../widgets/chat/chat_typing_indicator.dart';

class ChatScreen extends StatelessWidget {
  final ChatCharacter character;
  final AppThemeColors colors;

  const ChatScreen({super.key, required this.character, required this.colors});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ChatBloc()..add(ChatLoadMessages(character: character)),
      child: _ChatScreenContent(character: character, colors: colors),
    );
  }
}

class _ChatScreenContent extends StatelessWidget {
  final ChatCharacter character;
  final AppThemeColors colors;

  const _ChatScreenContent({required this.character, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Header
          DetailHeader(
            colors: colors,
            character: character,
            onBackPressed: () => Navigator.of(context).pop(),
          ),

          // Rate limit banner
          BlocSelector<ChatBloc, ChatState, (bool, int)>(
            selector: (state) => (state.isRateLimited, state.rateLimitSeconds),
            builder: (context, data) {
              final (isRateLimited, seconds) = data;
              if (!isRateLimited) return const SizedBox.shrink();
              return ChatRateLimitBanner(
                colors: colors,
                secondsRemaining: seconds,
              );
            },
          ),

          // Messages list
          Expanded(
            child: GestureDetector(
              onLongPress: () => _showResetDialog(context),
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return _buildMessagesList(context, state);
                },
              ),
            ),
          ),

          // Input bar
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return ChatInputBar(
                colors: colors,
                onSendText: (text) {
                  context.read<ChatBloc>().add(ChatSendTextMessage(text: text));
                },
                onSendImage: (bytes, caption) {
                  context.read<ChatBloc>().add(
                    ChatSendImageMessage(imageBytes: bytes, caption: caption),
                  );
                },
                enabled: state.canSendMessage,
                hintText: state.getInputHint(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatState state) {
    if (state.status == ChatStatus.loading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }

    final List<Widget> chatItems = [];

    // Typing indicator (shown at bottom when reversed)
    if (state.isTyping && !state.isRateLimited) {
      chatItems.add(ChatTypingIndicator(colors: colors));
    }

    // Messages (reversed for bottom-up display)
    for (int i = state.messages.length - 1; i >= 0; i--) {
      chatItems.add(MessageBubble(message: state.messages[i], colors: colors));
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: chatItems.length,
      itemBuilder: (context, index) => chatItems[index],
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Reset conversation?'),
            content: const Text(
              'This will clear all messages and start fresh. '
              'Use this if the AI is stuck or rate limited.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<ChatBloc>().add(const ChatResetConversation());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conversation reset')),
                  );
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }
}
