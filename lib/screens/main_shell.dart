import 'package:chapter_chat_ai/blocs/book/bloc/book_bloc.dart';
import 'package:chapter_chat_ai/blocs/book/bloc/book_event.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_bloc.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/theme_provider.dart';
import '../models/book.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/common/search_header.dart';
import '../widgets/common/sticky_section_header.dart';
import 'home/home_content.dart';
import 'chat/chat_content.dart';
import 'shop/shop_content.dart';
import 'profile/profile_content.dart';
import 'publish/publish_book_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  NavTab _currentTab = NavTab.home;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchFocused = false;

  // Lista de libros de ejemplo
  final List<Book> _books = [
    Book(
      id: '1',
      title: 'The Hobbit',
      author: 'J.R.R. Tolkien',
      isRead: false,
      isDownloaded: true,
      readingProgress: 0.45,
    ),
    Book(
      id: '2',
      title: '1984',
      author: 'George Orwell',
      isRead: false,
      isDownloaded: true,
      readingProgress: 0.72,
    ),
    Book(
      id: '3',
      title: 'Pride and Prejudice',
      author: 'Jane Austen',
      isRead: true,
      isDownloaded: true,
      readingProgress: 1.0,
    ),
    Book(
      id: '4',
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      isRead: false,
      isDownloaded: true,
      readingProgress: 0.33,
    ),
    Book(
      id: '5',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      isRead: false,
      isDownloaded: false,
      readingProgress: 0.0,
    ),
    Book(
      id: '6',
      title: 'Harry Potter and the Sorcerer\'s Stone',
      author: 'J.K. Rowling',
      isRead: true,
      isDownloaded: true,
      readingProgress: 1.0,
    ),
    Book(
      id: '7',
      title: 'The Catcher in the Rye',
      author: 'J.D. Salinger',
      isRead: false,
      isDownloaded: true,
      readingProgress: 0.58,
    ),
    Book(
      id: '8',
      title: 'Lord of the Flies',
      author: 'William Golding',
      isRead: false,
      isDownloaded: true,
      readingProgress: 0.21,
    ),
    Book(
      id: '9',
      title: 'Brave New World',
      author: 'Aldous Huxley',
      isRead: false,
      isDownloaded: false,
      readingProgress: 0.0,
    ),
    Book(
      id: '10',
      title: 'The Lord of the Rings',
      author: 'J.R.R. Tolkien',
      isRead: false,
      isDownloaded: true,
      readingProgress: 0.15,
    ),
    Book(
      id: '11',
      title: 'Fahrenheit 451',
      author: 'Ray Bradbury',
      isRead: false,
      isDownloaded: true,
      readingProgress: 0.89,
    ),
    Book(
      id: '12',
      title: 'Jane Eyre',
      author: 'Charlotte Brontë',
      isRead: true,
      isDownloaded: true,
      readingProgress: 1.0,
    ),
    Book(
      id: '13',
      title: 'Moby Dick',
      author: 'Herman Melville',
      isRead: false,
      isDownloaded: true,
      readingProgress: 0.08,
    ),
    Book(
      id: '14',
      title: 'The Chronicles of Narnia',
      author: 'C.S. Lewis',
      isRead: false,
      isDownloaded: false,
      readingProgress: 0.0,
    ),
    Book(
      id: '15',
      title: 'Wuthering Heights',
      author: 'Emily Brontë',
      isRead: false,
      isDownloaded: true,
      readingProgress: 0.42,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onSearchFocusChanged(bool isFocused) {
    setState(() {
      _isSearchFocused = isFocused;
    });
  }

  void _onTabSelected(NavTab tab) {
    setState(() {
      _currentTab = tab;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _onBookTap(Book book) {
    debugPrint('Libro seleccionado: ${book.title}');
  }

  void _onBookActionPressed(Book book) {
    debugPrint('Acción en libro: ${book.title}');
  }

  void _onPublishPressed() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const PublishBookScreen(),
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

  String? get _currentSectionTitle {
    switch (_currentTab) {
      case NavTab.home:
        return 'Your Books';
      case NavTab.chat:
        return 'AI Chats';
      case NavTab.shop:
      case NavTab.profile:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: colors.background,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        physics:
                            _isSearchFocused
                                ? const NeverScrollableScrollPhysics()
                                : const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            floating: true,
                            snap: false,
                            backgroundColor:
                                _currentTab == NavTab.shop
                                    ? Colors.transparent
                                    : colors.background,
                            surfaceTintColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.transparent,
                            elevation: 0,
                            scrolledUnderElevation: 0,
                            toolbarHeight: 72,
                            automaticallyImplyLeading: false,
                            flexibleSpace: SearchHeader(
                              colors: colors,
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              onFocusChanged: _onSearchFocusChanged,
                              hintText: 'Search Books',
                              transparentBackground: _currentTab == NavTab.shop,
                              showPublishButton: true,
                              onPublishPressed: _onPublishPressed,
                            ),
                          ),

                          if (_currentSectionTitle != null)
                            StickySectionHeader(
                              title: _currentSectionTitle!,
                              colors: colors,
                            ),

                          _buildContent(),
                        ],
                      ),
                    ),

                    BottomNavBar(
                      currentTab: _currentTab,
                      onTabSelected: _onTabSelected,
                      colors: colors,
                      profileInitial: state.name.substring(0, 1).toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent() {
    final colors = context.watch<ThemeProvider>().colors;

    switch (_currentTab) {
      case NavTab.home:
        return HomeContent(
          colors: colors,
          books: _books,
          searchQuery: _searchQuery,
          onBookTap: _onBookTap,
          onBookActionPressed: _onBookActionPressed,
        );
      case NavTab.chat:
        return ChatContent(colors: colors, searchQuery: _searchQuery);
      case NavTab.shop:
        return ShopContent(colors: colors, searchQuery: _searchQuery);
      case NavTab.profile:
        return ProfileContent(colors: colors);
    }
  }
}
