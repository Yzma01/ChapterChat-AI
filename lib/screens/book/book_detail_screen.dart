import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/book.dart';
import '../../models/chat_character.dart';
import '../../blocs/library/models/local_book_model.dart';
import '../../blocs/chat/repository/active_chats_storage.dart';
import '../../widgets/book/character_chat_card.dart';
import '../chat/chat_screen.dart';
import '../reader/pdf_reader_screen.dart';

/// Simple book detail screen for Home/Library
/// Shows book info card, read button, and characters to chat with
class BookDetailScreen extends StatelessWidget {
  final Book book;
  final AppThemeColors colors;
  final LocalBookModel? localBook;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.colors,
    this.localBook,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildBookInfoCard(context),
                    if (localBook != null &&
                        localBook!.readingProgress > 0) ...[
                      const SizedBox(height: 16),
                      _buildReadingProgress(),
                    ],
                    const SizedBox(height: 32),
                    if (book.characters != null &&
                        book.characters!.isNotEmpty) ...[
                      Text(
                        'Chat with',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...book.characters!.map(
                        (character) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CharacterChatCard(
                            character: character,
                            colors: colors,
                            onTap: () => _onCharacterTap(context, character),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: colors.iconDefault, size: 24),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBookInfoCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCover(),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                book.author,
                style: TextStyle(fontSize: 15, color: colors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Released ${book.releaseDateFormatted}',
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed:
                      localBook != null ? () => _onReadPressed(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Read',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCover() {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 48,
          color: colors.iconDefault.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildReadingProgress() {
    final progress = localBook!.readingProgress;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reading Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: localBook!.isRead ? Colors.green : colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                localBook!.isRead ? Colors.green : colors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Page ${localBook!.currentPage + 1} of ${localBook!.totalPages}',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _onReadPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PdfReaderScreen(book: localBook!)),
    );
  }

  Future<void> _onCharacterTap(
    BuildContext context,
    ChatCharacter character,
  ) async {
    await ActiveChatsStorage.instance.addActiveChat(
      ActiveChatData(
        characterId: character.id,
        characterName: character.name,
        characterDescription: character.description,
        avatarPath: character.avatarPath,
        bookId: book.id,
        bookTitle: book.title,
        lastInteractionTime: DateTime.now(),
      ),
    );
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => ChatScreen(
                character: character,
                colors: context.read<ThemeProvider>().colors,
              ),
        ),
      );
    }
  }
}
