import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/book.dart';
import '../../models/chat_character.dart';
import '../../blocs/library/bloc/library_bloc.dart';
import '../../blocs/library/bloc/library_event.dart';
import '../../blocs/library/bloc/library_state.dart';
import '../../blocs/library/models/local_book_model.dart';
import '../../widgets/common/detail_header.dart';
import '../../widgets/book/expandable_section.dart';
import '../../widgets/chat/chat_card.dart';
import '../reader/pdf_reader_screen.dart';

/// Shop book detail screen - shows full book info with buy/download functionality
class ShopBookDetailScreen extends StatefulWidget {
  final Book book;

  const ShopBookDetailScreen({super.key, required this.book});

  @override
  State<ShopBookDetailScreen> createState() => _ShopBookDetailScreenState();
}

class _ShopBookDetailScreenState extends State<ShopBookDetailScreen> {
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
  }

  void _onBuyPressed() {
    if (_book.pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This book is not available for download'),
        ),
      );
      return;
    }

    context.read<LibraryBloc>().add(
      PurchaseBook(
        id: _book.id,
        title: _book.title,
        author: _book.author,
        description: _book.description,
        genres: _book.genre?.split(' / ') ?? [],
        language: _book.originalLanguage ?? 'Unknown',
        pages: _book.pages ?? 0,
        price: _book.price ?? 0,
        minAge: _book.minimumAge ?? 0,
        publisher: _book.publisher,
        storySetting: _book.setting,
        pdfUrl: _book.pdfUrl!,
        characters:
            _book.characters
                ?.map(
                  (c) => LocalCharacterModel(
                    id: c.id,
                    name: c.name,
                    description: c.description ?? '',
                    avatarPath: c.avatarPath,
                  ),
                )
                .toList() ??
            [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return BlocConsumer<LibraryBloc, LibraryState>(
      listener: (context, state) {
        if (state.status == LibraryStatus.purchaseSuccess) {
          setState(() {
            _book = _book.copyWith(isPurchased: true, isDownloaded: true);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book purchased successfully!')),
          );
        } else if (state.status == LibraryStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Purchase failed')),
          );
        }
      },
      builder: (context, libraryState) {
        final isPurchasing = libraryState.status == LibraryStatus.purchasing;
        final localBook = libraryState.getBook(_book.id);
        final isPurchased = localBook != null || _book.isPurchased;

        return Scaffold(
          backgroundColor: colors.background,
          body: Column(
            children: [
              DetailHeader(
                colors: colors,
                onBackPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBookHeader(colors),
                      const SizedBox(height: 20),
                      _buildStatsRow(colors),
                      const SizedBox(height: 24),
                      _buildActionButton(
                        colors,
                        isPurchased,
                        isPurchasing,
                        localBook,
                      ),
                      const SizedBox(height: 24),
                      if (_book.aiCharactersCount != null &&
                          _book.aiCharactersCount! > 0) ...[
                        ExpandableSection(
                          title: 'Characters available to chat',
                          colors: colors,
                          initiallyExpanded: false,
                          previewContent: const SizedBox.shrink(),
                          content: _buildCharactersContent(colors),
                        ),
                        const SizedBox(height: 8),
                      ],
                      ExpandableSection(
                        title: 'About this book',
                        colors: colors,
                        initiallyExpanded: false,
                        previewContent: _buildAboutPreview(colors),
                        content: _buildAboutContent(colors),
                      ),
                      const SizedBox(height: 8),
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
      },
    );
  }

  Widget _buildBookHeader(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 170,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Center(
              child: Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: colors.iconDefault,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  _book.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _book.author,
                  style: TextStyle(fontSize: 16, color: colors.textSecondary),
                ),
                const SizedBox(height: 4),
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

  Widget _buildStatsRow(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            value: _book.pages?.toString() ?? '—',
            label: 'Pages',
            colors: colors,
          ),
          Container(height: 40, width: 1, color: colors.border),
          _buildStatItem(
            value: _book.aiCharactersCount?.toString() ?? '0',
            label: 'AI Characters',
            colors: colors,
            icon: Icons.auto_awesome,
          ),
          Container(height: 40, width: 1, color: colors.border),
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

  Widget _buildActionButton(
    AppThemeColors colors,
    bool isPurchased,
    bool isPurchasing,
    LocalBookModel? localBook,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: isPurchased ? colors.background : colors.primary,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap:
                isPurchasing
                    ? null
                    : isPurchased
                    ? () {
                      if (localBook != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PdfReaderScreen(book: localBook),
                          ),
                        );
                      }
                    }
                    : _onBuyPressed,
            borderRadius: BorderRadius.circular(24),
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
                child:
                    isPurchasing
                        ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          isPurchased ? 'Read' : 'Buy ${_book.priceText}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isPurchased ? colors.textPrimary : Colors.white,
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
    final characters = _book.characters ?? [];
    if (characters.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children:
            characters
                .map(
                  (c) => ChatCard(
                    character: c,
                    colors: colors,
                    mode: ChatCardMode.bookPreview,
                    onTap: () {},
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildAboutPreview(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        _book.description ?? 'No description available.',
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
    if (_book.originalLanguage != null)
      details.add(MapEntry('Original Language', _book.originalLanguage!));
    if (_book.genre != null) details.add(MapEntry('Genre', _book.genre!));
    if (_book.releaseDate != null)
      details.add(MapEntry('Publication Date', _book.releaseDateFull));
    if (_book.pages != null) details.add(MapEntry('Pages', '~${_book.pages}'));
    if (_book.publisher != null)
      details.add(MapEntry('Publisher', _book.publisher!));
    if (_book.minimumAge != null)
      details.add(MapEntry('Target Age', _book.ageText));
    if (_book.setting != null) details.add(MapEntry('Setting', _book.setting!));
    return details;
  }

  Widget _buildDetailsPreview(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            _getDetailsList()
                .take(3)
                .map((d) => _buildDetailRow(d.key, d.value, colors))
                .toList(),
      ),
    );
  }

  Widget _buildDetailsContent(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            _getDetailsList()
                .map((d) => _buildDetailRow(d.key, d.value, colors))
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
