import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A simple section title widget for form sections.
class SectionTitle extends StatelessWidget {
  final String title;
  final AppThemeColors colors;
  final double fontSize;
  final FontWeight fontWeight;

  const SectionTitle({
    super.key,
    required this.title,
    required this.colors,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: colors.textPrimary,
      ),
    );
  }
}
