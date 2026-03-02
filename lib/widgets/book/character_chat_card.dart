import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_character.dart';

/// Card widget for displaying a character available for chat
/// Used in BookDetailScreen to show characters from a book
class CharacterChatCard extends StatelessWidget {
  final ChatCharacter character;
  final AppThemeColors colors;
  final VoidCallback? onTap;

  const CharacterChatCard({
    super.key,
    required this.character,
    required this.colors,
    this.onTap,
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(),

              const SizedBox(width: 16),

              // Name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (character.description != null &&
                        character.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        character.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Arrow icon
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.arrow_forward,
                  color: colors.iconDefault,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
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
    return Icon(Icons.person, size: 28, color: colors.iconDefault);
  }
}
