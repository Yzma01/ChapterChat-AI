import 'package:chapter_chat_ai/blocs/book/bloc/book_bloc.dart';
import 'package:chapter_chat_ai/blocs/book/bloc/book_event.dart';
import 'package:chapter_chat_ai/blocs/book/bloc/book_state.dart';
import 'package:chapter_chat_ai/blocs/book/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/book.dart';
import '../../models/chat_character.dart';
import '../../widgets/book/book_card.dart';
import '../../widgets/shop/genre_chip.dart';
import 'book_detail_screen.dart';

class ShopContent extends StatefulWidget {
  final AppThemeColors colors;
  final String searchQuery;

  const ShopContent({super.key, required this.colors, this.searchQuery = ''});

  @override
  State<ShopContent> createState() => _ShopContentState();
}

class _ShopContentState extends State<ShopContent> {
  // Lista de géneros disponibles
  List<String> get _genres => [
    'Romance',
    'Health, mind & body',
    'Art & recreation',
    'Business & investing',
    'Self-help',
    'Biographies & memoirs',
    'Science fiction',
    'Mystery',
    'Fantasy',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(FetchBooksRequested());
  }

  List<Book> getFilteredBooks(List<Book> allBooks) {
    if (widget.searchQuery.isEmpty) return allBooks;

    final query = widget.searchQuery.toLowerCase();
    return allBooks.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genre!.toLowerCase().contains(query);
    }).toList();
  }

  Book bookFromModel(BookModel model) {
    return Book(
      id: model.id ?? '',
      title: model.title,
      author: model.publisher ?? 'Unknown',
      price: model.price,
      releaseDate: DateTime.now(),
      pages: model.pages,
      aiCharactersCount: model.characters?.length ?? 0,
      minimumAge: model.minAge,
      originalLanguage: model.language,
      genre: model.genres.join(' / '),
      publisher: model.publisher ?? '',
      setting: model.storySetting ?? '',
      description: model.description,
      characters:
          model.characters?.map((c) {
            return ChatCharacter(
              id: c.name.toLowerCase(),
              name: c.name,
              lastMessageTime: DateTime.now(),
              description: c.description,
            );
          }).toList(),
    );
  }

  void _onBookTap(BuildContext context, Book book) {
    final themeProvider = context.read<ThemeProvider>();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                BookDetailScreen(book: book),
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
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BookFailure) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'Error: ${state.error}',
                style: TextStyle(color: widget.colors.textPrimary),
              ),
            ),
          );
        }

        if (state is BookLoaded) {
          // Convertir los modelos a objetos Book
          final allBooks = state.books.map(bookFromModel).toList();

          // Aplicar el filtro de búsqueda
          final filteredBooks = getFilteredBooks(allBooks);

          // Si hay búsqueda pero no hay resultados
          if (widget.searchQuery.isNotEmpty && filteredBooks.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: widget.colors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try again',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildListDelegate([
              // Solo mostrar géneros si no hay búsqueda activa
              if (widget.searchQuery.isEmpty) ...[
                _buildSectionTitle('Genres'),
                _buildGenresList(),
                const SizedBox(height: 24),
              ],

              // Título de la sección de libros
              _buildSectionTitle(
                widget.searchQuery.isEmpty
                    ? 'Books'
                    : 'Results (${filteredBooks.length})',
              ),

              const SizedBox(height: 8),

              // Lista de libros filtrados
              ...filteredBooks.map(
                (book) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: BookCard(
                    book: book,
                    colors: widget.colors,
                    mode: BookCardMode.store,
                    onTap: () => _onBookTap(context, book),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ]),
          );
        }

        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('Unknown state')),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: widget.colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildGenresList() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return GenreChip(
            label: _genres[index],
            colors: widget.colors,
            onTap: () {
              debugPrint('Genre Selected: ${_genres[index]}');
            },
          );
        },
      ),
    );
  }
}
