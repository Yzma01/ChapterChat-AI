import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/chat_character.dart';
import '../../widgets/chat/chat_card.dart';
import 'chat_screen.dart';

class ChatContent extends StatelessWidget {
  final AppThemeColors colors;
  final String searchQuery;

  const ChatContent({super.key, required this.colors, this.searchQuery = ''});

  // Lista de personajes de ejemplo
  List<ChatCharacter> get _characters => [
    ChatCharacter(
      id: '1',
      name: 'Harry Potter',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      hasUnread: true,
      description:
          'The Boy Who Lived, a young wizard who survived the killing curse.',
    ),
    ChatCharacter(
      id: '2',
      name: 'Sherlock Holmes',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 6)),
      hasUnread: true,
      description: 'The world\'s only consulting detective.',
    ),
    ChatCharacter(
      id: '3',
      name: 'Holden Caulfield',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 6)),
      hasUnread: false,
      description: 'A cynical teenager from New York.',
    ),
    ChatCharacter(
      id: '4',
      name: 'Jon Snow',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 14)),
      hasUnread: false,
      description: 'A member of the Night\'s Watch.',
    ),
  ];

  List<ChatCharacter> get filteredCharacters {
    if (searchQuery.isEmpty) return _characters;
    final query = searchQuery.toLowerCase();
    return _characters.where((character) {
      return character.name.toLowerCase().contains(query);
    }).toList();
  }

  void _onCharacterTap(BuildContext context, ChatCharacter character) {
    final themeProvider = context.read<ThemeProvider>();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ChatScreen(character: character, colors: themeProvider.colors),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    );
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
            colors: colors,
            onTap: () => _onCharacterTap(context, character),
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
              searchQuery.isEmpty
                  ? Icons.chat_bubble_outline
                  : Icons.search_off,
              size: 64,
              color: colors.iconDefault,
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No hay chats todavía'
                  : 'No se encontraron resultados',
              style: TextStyle(fontSize: 16, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
