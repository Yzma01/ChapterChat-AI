import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_character.dart';

class DetailHeader extends StatelessWidget {
  final AppThemeColors colors;
  final VoidCallback? onBackPressed;
  final ChatCharacter? character;
  final String? title;

  const DetailHeader({
    super.key,
    required this.colors,
    this.onBackPressed,
    this.character,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: colors.background,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            IconButton(
              onPressed: onBackPressed,
              icon: Icon(Icons.arrow_back, color: colors.iconDefault, size: 24),
            ),

            // Center content
            Expanded(child: _buildCenterContent()),

            // Empty space to balance the back button
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterContent() {
    // If character is provided, show character info
    if (character != null) {
      return Row(
        children: [
          // Character avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
              border: Border.all(color: colors.border, width: 1),
            ),
            child:
                character!.avatarPath != null
                    ? ClipOval(
                      child: Image.asset(
                        character!.avatarPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 24,
                            color: colors.iconDefault,
                          );
                        },
                      ),
                    )
                    : Icon(Icons.person, size: 24, color: colors.iconDefault),
          ),

          const SizedBox(width: 12),

          // Character name
          Expanded(
            child: Text(
              character!.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // If title is provided, show title
    if (title != null) {
      return Text(
        title!,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Otherwise, empty
    return const SizedBox.shrink();
  }
}
