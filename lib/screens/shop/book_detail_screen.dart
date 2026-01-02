import 'package:chapter_chat_ai/screens/shop/card_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/book.dart';
import '../../models/chat_character.dart';
import '../../widgets/common/detail_header.dart';
import '../../widgets/book/expandable_section.dart';
import '../../widgets/chat/chat_card.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
  }

  void _onBuyPressed() async {
    await CardInputBottomSheet.show(context, book: _book);

    setState(() {
      _book = _book.copyWith(isPurchased: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          // Header (solo back arrow y search icon)
          DetailHeader(
            colors: colors,
            onBackPressed: () => Navigator.of(context).pop(),
            // No character = no avatar/name shown
          ),

          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book header card
                  _buildBookHeader(colors),

                  const SizedBox(height: 20),

                  // Book stats row
                  _buildStatsRow(colors),

                  const SizedBox(height: 24),

                  // Buy button
                  _buildBuyButton(colors),

                  const SizedBox(height: 24),

                  // Characters available to chat (expandable) - show if book has AI characters
                  if (_book.aiCharactersCount != null &&
                      _book.aiCharactersCount! > 0)
                    ExpandableSection(
                      title: 'Characters available to chat',
                      colors: colors,
                      initiallyExpanded: false,
                      previewContent:
                          const SizedBox.shrink(), // Nothing shown when collapsed
                      content: _buildCharactersContent(colors),
                    ),

                  if (_book.aiCharactersCount != null &&
                      _book.aiCharactersCount! > 0)
                    const SizedBox(height: 8),

                  // About this book (expandable)
                  ExpandableSection(
                    title: 'About this book',
                    colors: colors,
                    initiallyExpanded: false,
                    previewContent: _buildAboutPreview(colors),
                    content: _buildAboutContent(colors),
                  ),

                  const SizedBox(height: 8),

                  // More details (expandable)
                  ExpandableSection(
                    title: 'More details',
                    colors: colors,
                    initiallyExpanded: false,
                    previewContent: _buildDetailsPreview(colors),
                    content: _buildDetailsContent(colors),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookHeader(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          Container(
            width: 120,
            height: 170,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border, width: 1),
            ),
            child:
                _book.coverImagePath != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.asset(
                        _book.coverImagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderCover(colors);
                        },
                      ),
                    )
                    : _buildPlaceholderCover(colors),
          ),

          const SizedBox(width: 20),

          // Book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Title
                Text(
                  _book.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Author
                Text(
                  _book.author,
                  style: TextStyle(fontSize: 16, color: colors.textSecondary),
                ),

                const SizedBox(height: 4),

                // Release date
                Text(
                  'Released ${_book.releaseDateFormatted}',
                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover(AppThemeColors colors) {
    return Center(
      child: Icon(
        Icons.menu_book_outlined,
        size: 48,
        color: colors.iconDefault,
      ),
    );
  }

  Widget _buildStatsRow(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pages
          _buildStatItem(
            value: _book.pages?.toString() ?? '—',
            label: 'Pages',
            colors: colors,
          ),

          // Divider
          Container(height: 40, width: 1, color: colors.border),

          // AI Characters
          _buildStatItem(
            value: _book.aiCharactersCount?.toString() ?? '0',
            label: 'AI Characters',
            colors: colors,
            icon: Icons.auto_awesome,
          ),

          // Divider
          Container(height: 40, width: 1, color: colors.border),

          // Age
          _buildStatItem(value: _book.ageText, label: 'Age', colors: colors),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required AppThemeColors colors,
    IconData? icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: colors.textPrimary),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBuyButton(AppThemeColors colors) {
    final isPurchased = _book.isPurchased;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: isPurchased ? colors.background : colors.primary,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap:
                isPurchased
                    ? () {
                      debugPrint('Go to book: ${_book.title}');
                      // TODO: Navigate to book reader
                    }
                    : _onBuyPressed,
            borderRadius: BorderRadius.circular(24),
            splashColor:
                isPurchased
                    ? colors.primary.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
            highlightColor:
                isPurchased
                    ? colors.primary.withOpacity(0.05)
                    : Colors.white.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration:
                  isPurchased
                      ? BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.border, width: 1),
                      )
                      : null,
              child: Center(
                child: Text(
                  isPurchased ? 'Go to Book' : 'Buy ${_book.priceText}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isPurchased ? colors.textPrimary : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharactersContent(AppThemeColors colors) {
    // Use existing characters or generate placeholders based on aiCharactersCount
    List<ChatCharacter> characters;

    if (_book.characters != null && _book.characters!.isNotEmpty) {
      characters = _book.characters!;
    } else {
      // Generate placeholder characters based on aiCharactersCount
      final count = _book.aiCharactersCount ?? 0;
      characters = List.generate(
        count,
        (index) => ChatCharacter(
          id: 'placeholder_$index',
          name: 'Character ${index + 1}',
          lastMessageTime: DateTime.now(),
          description:
              'An AI character from "${_book.title}" available to chat with.',
        ),
      );
    }

    if (characters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children:
            characters
                .map(
                  (character) => ChatCard(
                    character: character,
                    colors: colors,
                    mode: ChatCardMode.bookPreview,
                    onTap: () {
                      debugPrint('Character tapped: ${character.name}');
                      // TODO: Could show more info or start chat if purchased
                    },
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildAboutPreview(AppThemeColors colors) {
    final description = _book.description ?? 'No description available.';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 15,
          color: colors.textSecondary,
          height: 1.5,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAboutContent(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        _book.description ?? 'No description available.',
        style: TextStyle(
          fontSize: 15,
          color: colors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  List<MapEntry<String, String>> _getDetailsList() {
    final details = <MapEntry<String, String>>[];

    details.add(MapEntry('Title', _book.title));
    details.add(MapEntry('Author', _book.author));

    if (_book.originalLanguage != null) {
      details.add(MapEntry('Original Language', _book.originalLanguage!));
    }
    if (_book.genre != null) {
      details.add(MapEntry('Genre', _book.genre!));
    }
    if (_book.releaseDate != null) {
      details.add(MapEntry('Publication Date', _book.releaseDateFull));
    }
    if (_book.pages != null) {
      details.add(MapEntry('Pages', '~${_book.pages} (varies by edition)'));
    }
    if (_book.publisher != null) {
      details.add(MapEntry('Publisher (original)', _book.publisher!));
    }
    if (_book.minimumAge != null) {
      details.add(MapEntry('Target Age', '${_book.ageText} (All Ages)'));
    }
    if (_book.setting != null) {
      details.add(MapEntry('Setting', _book.setting!));
    }

    return details;
  }

  Widget _buildDetailsPreview(AppThemeColors colors) {
    final details = _getDetailsList();
    final previewDetails = details.take(3).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            previewDetails
                .map(
                  (detail) => _buildDetailRow(detail.key, detail.value, colors),
                )
                .toList(),
      ),
    );
  }

  Widget _buildDetailsContent(AppThemeColors colors) {
    final details = _getDetailsList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            details
                .map(
                  (detail) => _buildDetailRow(detail.key, detail.value, colors),
                )
                .toList(),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(fontSize: 15, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
