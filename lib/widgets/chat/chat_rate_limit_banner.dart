import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Banner widget that shows when the user is rate limited
class ChatRateLimitBanner extends StatelessWidget {
  final AppThemeColors colors;
  final int secondsRemaining;

  const ChatRateLimitBanner({
    super.key,
    required this.colors,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: colors.warning.withOpacity(0.2),
      child: Row(
        children: [
          Icon(Icons.hourglass_empty, color: colors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rate limited. Please wait $secondsRemaining seconds...',
              style: TextStyle(color: colors.warning, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
