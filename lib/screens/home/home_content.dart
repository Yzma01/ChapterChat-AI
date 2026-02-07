import 'package:chapter_chat_ai/core/ads/ad_provider.dart';
import 'package:chapter_chat_ai/core/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/library/bloc/library_bloc.dart';
import '../../blocs/library/bloc/library_event.dart';
import '../../blocs/library/bloc/library_state.dart';
import '../../blocs/library/models/local_book_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/book.dart';
import '../../models/chat_character.dart';
import '../../widgets/book/book_card.dart';
import '../book/book_detail_screen.dart';

class HomeContent extends StatefulWidget {
  final AppThemeColors colors;
  final String searchQuery;

  const HomeContent({super.key, required this.colors, this.searchQuery = ''});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    // Load library on init
    context.read<LibraryBloc>().add(const LoadLibrary());
  }

  List<LocalBookModel> _filterBooks(List<LocalBookModel> books) {
    if (widget.searchQuery.isEmpty) return books;
    final query = widget.searchQuery.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();
  }

  void _onBookTap(BuildContext context, LocalBookModel localBook) {
    // Navigate to book detail screen (not reader)
    _navigateToBookDetail(context, localBook);
  }

  void _onBookLongPress(BuildContext context, LocalBookModel localBook) {
    final colors = widget.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Book title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      localBook.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // View Details option
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: colors.iconDefault,
                    ),
                    title: Text(
                      'View Details',
                      style: TextStyle(color: colors.textPrimary),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToBookDetail(context, localBook);
                    },
                  ),

                  // Delete option
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: colors.error),
                    title: Text(
                      'Remove from Library',
                      style: TextStyle(color: colors.error),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, localBook);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _navigateToBookDetail(BuildContext context, LocalBookModel localBook) {
    // Convert LocalBookModel to Book for the detail screen
    final book = Book(
      id: localBook.id,
      title: localBook.title,
      author: localBook.author,
      description: localBook.description,
      genre: localBook.genres.join(' / '),
      originalLanguage: localBook.language,
      pages: localBook.pages,
      price: localBook.price,
      minimumAge: localBook.minAge,
      publisher: localBook.publisher,
      setting: localBook.storySetting,
      pdfUrl: localBook.pdfUrl,
      coverUrl: localBook.coverUrl, // NEW: Include cover URL
      isPurchased: true,
      isDownloaded: localBook.isDownloaded,
      readingProgress: localBook.readingProgress,
      isRead: localBook.isRead,
      aiCharactersCount: localBook.characters.length,
      characters:
          localBook.characters
              .map(
                (c) => ChatCharacter(
                  id: c.id,
                  name: c.name,
                  description: c.description,
                  avatarPath: c.avatarPath,
                  lastMessageTime: DateTime.now(),
                ),
              )
              .toList(),
    );

    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => BookDetailScreen(
                  book: book,
                  colors: widget.colors,
                  localBook: localBook,
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
          // Refresh library when returning from detail screen
          context.read<LibraryBloc>().add(const RefreshLibrary());
        });
  }

  void _showDeleteConfirmation(BuildContext context, LocalBookModel localBook) {
    final colors = widget.colors;
    final libraryBloc = context.read<LibraryBloc>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: colors.surface,
            title: Text(
              'Remove from Library?',
              style: TextStyle(color: colors.textPrimary),
            ),
            content: Text(
              'This will remove "${localBook.title}" from your library and delete all local data. This action cannot be undone.',
              style: TextStyle(color: colors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  libraryBloc.add(DeleteBook(bookId: localBook.id));
                },
                child: Text('Remove', style: TextStyle(color: colors.error)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state.status == LibraryStatus.loading && state.books.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: widget.colors.primary),
            ),
          );
        }

        final filteredBooks = _filterBooks(state.books);

        if (filteredBooks.isEmpty) {
          return _buildEmptyState();
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final localBook = filteredBooks[index];
              return LocalBookCard(
                localBook: localBook,
                colors: widget.colors,
                onTap: () => _onBookTap(context, localBook),
                onLongPress: () => _onBookLongPress(context, localBook),
              );
            }, childCount: filteredBooks.length),
          ),
        );
      },
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
                isSearching ? Icons.search_off : Icons.library_books_outlined,
                size: 64,
                color: widget.colors.iconDefault,
              ),
              const SizedBox(height: 16),
              Text(
                isSearching ? 'No books found' : 'Your library is empty',
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
                  'Visit the Shop to purchase books and start reading!',
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
