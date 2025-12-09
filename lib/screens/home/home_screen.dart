import 'package:flutter/material.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/book.dart';
import '../../widgets/common/custom_search_bar.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../widgets/book/book_card.dart';

class HomeScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const HomeScreen({super.key, required this.themeProvider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista de libros de ejemplo (temporal - después vendrá de una base de datos)
  final List<Book> _books = [
    Book(
      id: '1',
      title: 'Cien años de soledad',
      author: 'Gabriel García Márquez',
      isRead: true,
    ),
    Book(
      id: '2',
      title: 'El principito',
      author: 'Antoine de Saint-Exupéry',
      isRead: false,
    ),
    Book(
      id: '3',
      title: 'Don Quijote de la Mancha',
      author: 'Miguel de Cervantes',
      isRead: false,
    ),
  ];

  List<Book> _filteredBooks = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredBooks = _books;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBooks = _books;
      } else {
        _filteredBooks =
            _books.where((book) {
              final titleLower = book.title.toLowerCase();
              final authorLower = book.author.toLowerCase();
              final queryLower = query.toLowerCase();
              return titleLower.contains(queryLower) ||
                  authorLower.contains(queryLower);
            }).toList();
      }
    });
  }

  void _onChatPressed(Book book) {
    // TODO: Implementar navegación al chat
    debugPrint('Chat presionado para: ${book.title}');
  }

  void _onMarkAsReadPressed(Book book) {
    // TODO: Implementar marcar como leído
    debugPrint('Marcar como leído: ${book.title}');
  }

  void _onEditPressed(Book book) {
    // TODO: Implementar edición del libro
    debugPrint('Editar: ${book.title}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.themeProvider.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: colors.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header con título, botón de tema y barra de búsqueda
              _buildHeader(),

              // Lista de libros
              Expanded(child: _buildBookList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = widget.themeProvider.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila con título y botón de tema
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mi Biblioteca',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              ThemeToggleButton(themeProvider: widget.themeProvider),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de búsqueda
          CustomSearchBar(
            hintText: 'Buscar libros...',
            onChanged: _onSearchChanged,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    final colors = widget.themeProvider.colors;

    if (_filteredBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: colors.iconDefault),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No hay libros en tu biblioteca'
                  : 'No se encontraron resultados',
              style: TextStyle(fontSize: 16, color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBooks.length,
      itemBuilder: (context, index) {
        final book = _filteredBooks[index];
        return BookCard(
          book: book,
          colors: colors,
          onChatPressed: () => _onChatPressed(book),
          onMarkAsReadPressed: () => _onMarkAsReadPressed(book),
          onEditPressed: () => _onEditPressed(book),
        );
      },
    );
  }
}
