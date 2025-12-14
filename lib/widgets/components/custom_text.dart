import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isLink;
  final VoidCallback? onTap;

  const CustomText({
    super.key,
    required this.text,
    this.style,
    this.isLink = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    if (isLink) {
      return GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style:
              style ??
              TextStyle(
                color: theme.colors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
        ),
      );
    }

    return Text(
      text,
      style: style ?? TextStyle(color: theme.colors.textPrimary, fontSize: 14),
    );
  }
}
