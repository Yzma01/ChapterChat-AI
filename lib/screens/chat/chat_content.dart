import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/chat_character.dart';
import '../../blocs/chat/repository/chat_repository.dart';
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
  final ChatRepository _repository = ChatRepository();
  Map<String, String> _lastMessagePreviews = {};
  Map<String, DateTime> _lastMessageTimes = {};
  bool _isLoading = true;

  // Lista de personajes de ejemplo
  List<ChatCharacter> get _characters => [
    ChatCharacter(
      id: '1',
      name: 'Harry Potter',
      lastMessageTime:
          _lastMessageTimes['1'] ??
          DateTime.now().subtract(const Duration(hours: 2)),
      hasUnread: false,
      description:
          'The Boy Who Lived, a young wizard who survived the killing curse.',
    ),
    ChatCharacter(
      id: '2',
      name: 'Sherlock Holmes',
      lastMessageTime:
          _lastMessageTimes['2'] ??
          DateTime.now().subtract(const Duration(hours: 6)),
      hasUnread: false,
      description: 'The world\'s only consulting detective.',
    ),
    ChatCharacter(
      id: '3',
      name: 'Holden Caulfield',
      lastMessageTime:
          _lastMessageTimes['3'] ??
          DateTime.now().subtract(const Duration(hours: 6)),
      hasUnread: false,
      description: 'A cynical teenager from New York.',
    ),
    ChatCharacter(
      id: '4',
      name: 'Jon Snow',
      lastMessageTime:
          _lastMessageTimes['4'] ??
          DateTime.now().subtract(const Duration(days: 14)),
      hasUnread: false,
      description: 'A member of the Night\'s Watch.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLastMessages();
  }

  Future<void> _loadLastMessages() async {
    final Map<String, String> previews = {};
    final Map<String, DateTime> times = {};

    for (final character in _characters) {
      final lastMessage = await _repository.getLastMessage(character.id);
      if (lastMessage != null) {
        previews[character.id] = lastMessage.text ?? '[Image]';
        times[character.id] = lastMessage.timestamp;
      }
    }

    if (mounted) {
      setState(() {
        _lastMessagePreviews = previews;
        _lastMessageTimes = times;
        _isLoading = false;
      });
    }
  }

  List<ChatCharacter> get filteredCharacters {
    if (widget.searchQuery.isEmpty) return _characters;
    final query = widget.searchQuery.toLowerCase();
    return _characters.where((character) {
      return character.name.toLowerCase().contains(query);
    }).toList();
  }

  void _onCharacterTap(BuildContext context, ChatCharacter character) {
    final themeProvider = context.read<ThemeProvider>();
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
          // Reload last messages when returning from chat
          _loadLastMessages();
        });
  }

  @override
  Widget build(BuildContext context) {
    final displayCharacters = filteredCharacters;

    if (displayCharacters.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final character = displayCharacters[index];
          return ChatCard(
            character: character,
            colors: widget.colors,
            onTap: () => _onCharacterTap(context, character),
            lastMessagePreview: _lastMessagePreviews[character.id],
          );
        }, childCount: displayCharacters.length),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.searchQuery.isEmpty
                  ? Icons.chat_bubble_outline
                  : Icons.search_off,
              size: 64,
              color: widget.colors.iconDefault,
            ),
            const SizedBox(height: 16),
            Text(
              widget.searchQuery.isEmpty
                  ? 'No hay chats todavía'
                  : 'No se encontraron resultados',
              style: TextStyle(
                fontSize: 16,
                color: widget.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
