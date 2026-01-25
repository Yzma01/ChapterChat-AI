import 'dart:typed_data';
import 'package:chapter_chat_ai/core/ads/ad_provider.dart';
import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:chapter_chat_ai/core/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

class _ChatScreenContent extends StatefulWidget {
  final ChatCharacter character;
  final AppThemeColors colors;

  const _ChatScreenContent({required this.character, required this.colors});

  @override
  State<_ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<UserProvider>().user!.isPremium;
    final ads = context.watch<AdProvider>();

    return Scaffold(
      backgroundColor: widget.colors.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Header
          DetailHeader(
            colors: widget.colors,
            character: widget.character,
            onBackPressed: () => Navigator.of(context).pop(),
          ),

          // Rate limit banner
          BlocSelector<ChatBloc, ChatState, (bool, int)>(
            selector: (state) => (state.isRateLimited, state.rateLimitSeconds),
            builder: (context, data) {
              final (isRateLimited, seconds) = data;
              if (!isRateLimited) return const SizedBox.shrink();
              return ChatRateLimitBanner(
                colors: widget.colors,
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
              return SafeArea(
                child: Column(
                  children: [
                    ChatInputBar(
                      colors: widget.colors,
                      onSendText: (text) {
                        ads.getRewardedWidget(isPremium, () {
                          context.read<ChatBloc>().add(
                            ChatSendTextMessage(text: text),
                          );
                        });
                      },
                      onSendImage: (bytes, caption) {
                        ads.getRewardedWidget(isPremium, () {
                          context.read<ChatBloc>().add(
                            ChatSendImageMessage(
                              imageBytes: bytes,
                              caption: caption,
                            ),
                          );
                        });
                      },
                      enabled: state.canSendMessage,
                      hintText: state.getInputHint(),
                    ),
                    ads.getBannerWidget(isPremium),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatState state) {
    if (state.status == ChatStatus.loading) {
      return Center(
        child: CircularProgressIndicator(color: widget.colors.primary),
      );
    }

    final List<Widget> chatItems = [];

    // Typing indicator (shown at bottom when reversed)
    if (state.isTyping && !state.isRateLimited) {
      chatItems.add(ChatTypingIndicator(colors: widget.colors));
    }

    // Messages (reversed for bottom-up display)
    for (int i = state.messages.length - 1; i >= 0; i--) {
      chatItems.add(
        MessageBubble(message: state.messages[i], colors: widget.colors),
      );
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
