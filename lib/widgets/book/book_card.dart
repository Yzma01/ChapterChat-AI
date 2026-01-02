import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book.dart';
import '../../blocs/library/models/local_book_model.dart';

/// Enum para definir el modo de visualización del BookCard
enum BookCardMode {
  /// Modo Home: muestra progreso de lectura e icono de descarga
  home,

  /// Modo Store: muestra precio, sin icono de descarga
  store,

  /// Modo Library: muestra progreso de lectura de libros locales
  library,
}

class BookCard extends StatelessWidget {
  final Book? book;
  final LocalBookModel? localBook;
  final AppThemeColors colors;
  final VoidCallback? onTap;
  final VoidCallback? onActionPressed;
  final BookCardMode mode;

  const BookCard({
    super.key,
    this.book,
    this.localBook,
    required this.colors,
    this.onTap,
    this.onActionPressed,
    this.mode = BookCardMode.home,
  }) : assert(
         book != null || localBook != null,
         'Either book or localBook must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: colors.textPrimary.withOpacity(0.08),
          highlightColor: colors.textPrimary.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Portada del libro
                _buildCover(),

                const SizedBox(width: 16),

                // Información del libro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        _title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Autor
                      Text(
                        _author,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Progreso o Precio según el modo
                      _buildBottomInfo(),
                    ],
                  ),
                ),

                // Icono de descarga (solo en modo Home o Library)
                if (mode == BookCardMode.home ||
                    mode == BookCardMode.library) ...[
                  const SizedBox(width: 12),
                  _buildDownloadIcon(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _title => localBook?.title ?? book?.title ?? '';
  String get _author => localBook?.author ?? book?.author ?? '';
  double get _progress =>
      localBook?.readingProgress ?? book?.readingProgress ?? 0.0;
  bool get _isDownloaded =>
      localBook?.isDownloaded ?? book?.isDownloaded ?? false;

  Widget _buildCover() {
    return Container(
      width: 70,
      height: 100,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_outlined,
          size: 32,
          color: colors.iconDefault,
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    switch (mode) {
      case BookCardMode.home:
      case BookCardMode.library:
        final percentage = (_progress * 100).toInt();
        return Text(
          '$percentage% complete',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        );
      case BookCardMode.store:
        return Text(
          book?.priceText ?? 'Free',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        );
    }
  }

  Widget _buildDownloadIcon() {
    return Icon(
      _isDownloaded ? Icons.download_done_rounded : Icons.download_outlined,
      size: 24,
      color: _isDownloaded ? colors.primary : colors.iconDefault,
    );
  }
}

/// Specialized BookCard for displaying LocalBookModel directly
class LocalBookCard extends StatelessWidget {
  final LocalBookModel localBook;
  final AppThemeColors colors;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const LocalBookCard({
    super.key,
    required this.localBook,
    required this.colors,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          splashColor: colors.textPrimary.withOpacity(0.08),
          highlightColor: colors.textPrimary.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Book cover
                _buildCover(),

                const SizedBox(width: 16),

                // Book info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        localBook.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Author
                      Text(
                        localBook.author,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Progress
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: localBook.readingProgress,
                                backgroundColor: colors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  localBook.isRead
                                      ? Colors.green
                                      : colors.primary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(localBook.readingProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Status icon
                Icon(
                  localBook.isRead
                      ? Icons.check_circle
                      : localBook.isDownloaded
                      ? Icons.download_done_rounded
                      : Icons.download_outlined,
                  size: 24,
                  color:
                      localBook.isRead
                          ? Colors.green
                          : localBook.isDownloaded
                          ? colors.primary
                          : colors.iconDefault,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      width: 70,
      height: 100,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_outlined,
          size: 32,
          color: colors.iconDefault,
        ),
      ),
    );
  }
}
