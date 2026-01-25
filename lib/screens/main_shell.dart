import 'package:chapter_chat_ai/core/ads/ad_provider.dart';
import 'package:chapter_chat_ai/core/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/library/bloc/library_bloc.dart';
import '../blocs/library/bloc/library_event.dart';
import '../blocs/user/bloc/user_bloc.dart';
import '../blocs/user/bloc/user_state.dart';
import '../core/theme/theme_provider.dart';
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
  bool _adsInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load library when MainShell initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryBloc>().add(const LoadLibrary());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_adsInitialized) {
      final ads = context.read<AdProvider>();
      final isPremium = context.read<UserProvider>().user?.isPremium ?? false;

      if (!isPremium) {
        ads.loadBannerAd();
        ads.loadRewardedAd();
        ads.loadNativeAd();
      }

      _adsInitialized = true;
    }
  }

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

    // Refresh library when switching to home tab
    if (tab == NavTab.home) {
      context.read<LibraryBloc>().add(const RefreshLibrary());
    }
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

  String get _searchHintText {
    switch (_currentTab) {
      case NavTab.home:
        return 'Search your library';
      case NavTab.chat:
        return 'Search chats';
      case NavTab.shop:
        return 'Search books';
      case NavTab.profile:
        return 'Search';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final userProvider = context.watch<UserProvider>();

    if (!userProvider.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = userProvider.user!.name;

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
                        hintText: _searchHintText,
                        transparentBackground: _currentTab == NavTab.shop,
                        showPublishButton: _currentTab == NavTab.shop,
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
                profileInitial: name.substring(0, 1).toUpperCase(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final colors = context.watch<ThemeProvider>().colors;

    switch (_currentTab) {
      case NavTab.home:
        return HomeContent(colors: colors, searchQuery: _searchQuery);
      case NavTab.chat:
        return ChatContent(colors: colors, searchQuery: _searchQuery);
      case NavTab.shop:
        return ShopContent(colors: colors, searchQuery: _searchQuery);
      case NavTab.profile:
        return ProfileContent(colors: colors);
    }
  }
}
