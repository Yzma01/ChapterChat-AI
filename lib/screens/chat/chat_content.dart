import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/chat_character.dart';
import '../../blocs/chat/repository/active_chats_storage.dart';
import '../../widgets/chat/chat_card.dart';
import 'chat_screen.dart';

class ChatContent extends StatefulWidget {
  final AppThemeColors colors;
  final String searchQuery;

  const ChatContent({super.key, required this.colors, this.searchQuery = ''});

  @override
  State<ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends State<ChatContent> {
  List<ActiveChatData> _activeChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveChats();
  }

  Future<void> _loadActiveChats() async {
    try {
      final chats = await ActiveChatsStorage.instance.getAllActiveChats();
      if (mounted) {
        setState(() {
          _activeChats = chats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading active chats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ActiveChatData> get filteredChats {
    if (widget.searchQuery.isEmpty) return _activeChats;
    final query = widget.searchQuery.toLowerCase();
    return _activeChats.where((chat) {
      return chat.characterName.toLowerCase().contains(query) ||
          chat.bookTitle.toLowerCase().contains(query);
    }).toList();
  }

  ChatCharacter _activeChatToCharacter(ActiveChatData data) {
    return ChatCharacter(
      id: data.characterId,
      name: data.characterName,
      avatarPath: data.avatarPath,
      lastMessageTime: data.lastInteractionTime,
      hasUnread: data.hasUnread,
      description: data.characterDescription,
    );
  }

  void _onCharacterTap(BuildContext context, ActiveChatData chatData) async {
    // Update last interaction time
    await ActiveChatsStorage.instance.updateLastInteraction(
      chatData.characterId,
    );

    if (!context.mounted) return;

    final themeProvider = context.read<ThemeProvider>();
    final character = _activeChatToCharacter(chatData);

    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => ChatScreen(
                  character: character,
                  colors: themeProvider.colors,
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        )
        .then((_) {
          // Reload chats when returning
          _loadActiveChats();
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: widget.colors.primary),
        ),
      );
    }

    final displayChats = filteredChats;

    if (displayChats.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final chatData = displayChats[index];
          final character = _activeChatToCharacter(chatData);

          return ChatCard(
            character: character,
            colors: widget.colors,
            onTap: () => _onCharacterTap(context, chatData),
            bookTitle:
                chatData.bookTitle, // Show which book the character is from
          );
        }, childCount: displayChats.length),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isSearching = widget.searchQuery.isNotEmpty;

    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.chat_bubble_outline,
                size: 64,
                color: widget.colors.iconDefault,
              ),
              const SizedBox(height: 16),
              Text(
                isSearching
                    ? 'No se encontraron resultados'
                    : 'No active chats yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isSearching) ...[
                const SizedBox(height: 8),
                Text(
                  'Open a book and tap on a character to start chatting with them.',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
