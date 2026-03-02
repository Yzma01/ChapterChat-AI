import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget that shows typing animation when AI is responding
class ChatTypingIndicator extends StatefulWidget {
  final AppThemeColors colors;

  const ChatTypingIndicator({super.key, required this.colors});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.colors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return _AnimatedDot(
                      color: widget.colors.textSecondary,
                      animationValue: _controller.value,
                      dotIndex: index,
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Single animated dot for typing indicator
class _AnimatedDot extends StatelessWidget {
  final Color color;
  final double animationValue;
  final int dotIndex;

  const _AnimatedDot({
    required this.color,
    required this.animationValue,
    required this.dotIndex,
  });

  @override
  Widget build(BuildContext context) {
    final delay = dotIndex * 0.2;
    final animValue = ((animationValue + delay) % 1.0);
    final opacity =
        (animValue < 0.5)
            ? 0.3 + (animValue * 1.4)
            : 1.0 - ((animValue - 0.5) * 1.4);

    return Padding(
      padding: EdgeInsets.only(left: dotIndex > 0 ? 4 : 0),
      child: Opacity(
        opacity: opacity.clamp(0.3, 1.0),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
