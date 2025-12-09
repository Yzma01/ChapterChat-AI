import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final AppThemeColors colors;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: TextField(
        onChanged: onChanged,
        onTap: onTap,
        style: TextStyle(color: colors.textPrimary, fontSize: 16),
        cursorColor: colors.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: colors.textSecondary, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: colors.iconDefault),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
