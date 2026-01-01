import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_character.dart';

/// Enum para definir el modo de visualización del ChatCard
enum ChatCardMode {
  /// Modo Chat: muestra tiempo desde última conversación y preview
  chat,

  /// Modo Book Preview: muestra descripción del personaje
  bookPreview,
}

class ChatCard extends StatelessWidget {
  final ChatCharacter character;
  final AppThemeColors colors;
  final VoidCallback? onTap;
  final ChatCardMode mode;
  final String? lastMessagePreview; // Optional preview from storage

  const ChatCard({
    super.key,
    required this.character,
    required this.colors,
    this.onTap,
    this.mode = ChatCardMode.chat,
    this.lastMessagePreview,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.textPrimary.withOpacity(0.08),
        highlightColor: colors.textPrimary.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment:
                mode == ChatCardMode.bookPreview
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
            children: [
              // Avatar del personaje
              _buildAvatar(),

              const SizedBox(width: 16),

              // Nombre y subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y tiempo
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            character.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (mode == ChatCardMode.chat) ...[
                          const SizedBox(width: 8),
                          Text(
                            character.timeAgo,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Subtítulo
                    Text(
                      _buildSubtitle(),
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: mode == ChatCardMode.bookPreview ? null : 2,
                      overflow:
                          mode == ChatCardMode.bookPreview
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Indicador de no leído (solo en modo chat)
              if (mode == ChatCardMode.chat && character.hasUnread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surface,
        border: Border.all(color: colors.border, width: 1),
      ),
      child:
          character.avatarPath != null
              ? ClipOval(
                child: Image.asset(
                  character.avatarPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderAvatar();
                  },
                ),
              )
              : _buildPlaceholderAvatar(),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Icon(Icons.person, size: 32, color: colors.iconDefault);
  }

  String _buildSubtitle() {
    switch (mode) {
      case ChatCardMode.chat:
        // Show last message preview if available
        if (lastMessagePreview != null && lastMessagePreview!.isNotEmpty) {
          // Truncate long messages
          final preview = lastMessagePreview!;
          if (preview.length > 50) {
            return '${preview.substring(0, 50)}...';
          }
          return preview;
        }
        return 'Tap to start chatting';

      case ChatCardMode.bookPreview:
        // Show full description
        return character.description ?? '';
    }
  }
}
