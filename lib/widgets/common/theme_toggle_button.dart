import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ThemeToggleButton({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    final colors = themeProvider.colors;
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            key: ValueKey<bool>(isDark),
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
