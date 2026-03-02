import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book.dart';
import '../../blocs/library/models/local_book_model.dart';

/// Card widget displaying book cover, title, author, date and Read button
class BookInfoCard extends StatelessWidget {
  final Book? book;
  final LocalBookModel? localBook;
  final AppThemeColors colors;
  final VoidCallback? onReadPressed;

  const BookInfoCard({
    super.key,
    this.book,
    this.localBook,
    required this.colors,
    this.onReadPressed,
  }) : assert(
         book != null || localBook != null,
         'Either book or localBook must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book cover
        _buildCover(),

        const SizedBox(width: 20),

        // Book info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                _title,
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

              // Author
              Text(
                _author,
                style: TextStyle(fontSize: 15, color: colors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Release date
              if (_releaseDate != null)
                Text(
                  'Released $_releaseDate',
                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                ),

              const SizedBox(height: 16),

              // Read button
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: onReadPressed,
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

  String get _title => localBook?.title ?? book?.title ?? '';
  String get _author => localBook?.author ?? book?.author ?? '';
  String? get _releaseDate => book?.releaseDateFormatted;

  Widget _buildCover() {
    // Determine cover source
    String? coverUrl;
    String? localCoverPath;
    String? assetPath;

    if (localBook != null) {
      localCoverPath = localBook!.localCoverPath;
      coverUrl = localBook!.coverUrl;
    } else if (book != null) {
      coverUrl = book!.coverUrl;
      assetPath = book!.coverImagePath;
    }

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
      clipBehavior: Clip.antiAlias,
      child: _buildCoverImage(localCoverPath, coverUrl, assetPath),
    );
  }

  Widget _buildCoverImage(String? localPath, String? url, String? assetPath) {
    // Priority: Local file > Asset > Network URL > Placeholder

    // 1. Try local file (for purchased books)
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (url != null && url.isNotEmpty) {
            return _buildNetworkImage(url);
          }
          return _buildPlaceholderCover();
        },
      );
    }

    // 2. Try asset path (for bundled books)
    if (assetPath != null && assetPath.isNotEmpty) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (url != null && url.isNotEmpty) {
            return _buildNetworkImage(url);
          }
          return _buildPlaceholderCover();
        },
      );
    }

    // 3. Try network URL (for store books)
    if (url != null && url.isNotEmpty) {
      return _buildNetworkImage(url);
    }

    // 4. Fallback to placeholder
    return _buildPlaceholderCover();
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
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
        return _buildPlaceholderCover();
      },
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: colors.surface,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 48,
          color: colors.iconDefault.withOpacity(0.5),
        ),
      ),
    );
  }
}
