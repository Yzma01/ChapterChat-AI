import 'dart:io';
import 'package:chapter_chat_ai/blocs/payment/models/card_data_model.dart';
import 'package:chapter_chat_ai/core/ads/ad_provider.dart';
import 'package:chapter_chat_ai/core/user/user_provider.dart';
import 'package:chapter_chat_ai/screens/shop/card_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

  void _onBuyPressed() async {
    CardInputBottomSheet.show(context, _book, isMembership: false);

    if (_book.pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This book is not available for download'),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final isPremium = context.watch<UserProvider>().user!.isPremium;
    final ads = context.watch<AdProvider>();

    return BlocConsumer<LibraryBloc, LibraryState>(
      listener: (context, state) {
        if (state.status == LibraryStatus.purchaseSuccess) {
          setState(() {
            _book = _book.copyWith(isPurchased: true, isDownloaded: true);
          });
          // Note: Success snackbar is shown by CardInputBottomSheet
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

        return SafeArea(
          child: Scaffold(
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

                        !isPremium
                            ? SizedBox(height: 24)
                            : const SizedBox.shrink(),
                        ads.getBannerWidget(isPremium),
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
          // FIXED: Now displays actual cover image
          _buildCover(colors),
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

  // FIXED: New method to build cover with image support
  Widget _buildCover(AppThemeColors colors) {
    return Container(
      width: 120,
      height: 170,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildCoverImage(colors),
    );
  }

  Widget _buildCoverImage(AppThemeColors colors) {
    // Priority: Asset path > Network URL > Placeholder

    // 1. Try asset path (for bundled books)
    if (_book.coverImagePath != null && _book.coverImagePath!.isNotEmpty) {
      return Image.asset(
        _book.coverImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If asset fails, try URL
          if (_book.coverUrl != null && _book.coverUrl!.isNotEmpty) {
            return _buildNetworkImage(colors);
          }
          return _buildPlaceholder(colors);
        },
      );
    }

    // 2. Try network URL (for store books)
    if (_book.coverUrl != null && _book.coverUrl!.isNotEmpty) {
      return _buildNetworkImage(colors);
    }

    // 3. Fallback to placeholder
    return _buildPlaceholder(colors);
  }

  Widget _buildNetworkImage(AppThemeColors colors) {
    return Image.network(
      _book.coverUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primary,
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(colors);
      },
    );
  }

  Widget _buildPlaceholder(AppThemeColors colors) {
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
    if (_book.originalLanguage != null && _book.originalLanguage != '') {
      details.add(MapEntry('Original Language', _book.originalLanguage!));
    }
    if (_book.genre != null && _book.genre != '') {
      details.add(MapEntry('Genre', _book.genre!));
    }
    if (_book.releaseDate != null && _book.releaseDate != '') {
      details.add(MapEntry('Publication Date', _book.releaseDateFull));
    }
    if (_book.pages != null && _book.pages != 0) {
      details.add(MapEntry('Pages', '~${_book.pages}'));
    }
    if (_book.publisher != null && _book.publisher != '') {
      details.add(MapEntry('Publisher', _book.publisher!));
    }
    if (_book.minimumAge != null && _book.minimumAge! > 0) {
      details.add(MapEntry('Target Age', _book.ageText));
    }
    debugPrint('Book Setting: ${_book.setting}');
    if (_book.setting != null && _book.setting != '') {
      details.add(MapEntry('Setting', _book.setting!));
    }
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
