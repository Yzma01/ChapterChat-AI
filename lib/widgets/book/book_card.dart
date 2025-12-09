import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final AppThemeColors colors;
  final VoidCallback? onChatPressed;
  final VoidCallback? onMarkAsReadPressed;
  final VoidCallback? onEditPressed;

  const BookCard({
    super.key,
    required this.book,
    required this.colors,
    this.onChatPressed,
    this.onMarkAsReadPressed,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del libro (lado izquierdo)
          _buildBookCover(),

          const SizedBox(width: 16),

          // Información y acciones (lado derecho)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del libro
                Text(
                  book.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Autor
                Text(
                  book.author,
                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Botones de acción
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 110,
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            book.coverImagePath != null
                ? Image.asset(
                  book.coverImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderCover();
                  },
                )
                : _buildPlaceholderCover(),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Center(
      child: Icon(Icons.menu_book, size: 40, color: colors.iconDefault),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Botón Chat
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          label: 'Chat',
          onPressed: onChatPressed,
          color: colors.primary,
        ),

        // Botón Marcar como leído
        _buildActionButton(
          icon: book.isRead ? Icons.check_circle : Icons.check_circle_outline,
          label: book.isRead ? 'Leído' : 'Marcar',
          onPressed: onMarkAsReadPressed,
          color: book.isRead ? colors.success : colors.primaryLight,
        ),

        // Botón Editar
        _buildActionButton(
          icon: Icons.edit_outlined,
          label: 'Editar',
          onPressed: onEditPressed,
          color: colors.iconDefault,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
