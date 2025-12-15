import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A button widget for adding new characters.
class AddCharacterButton extends StatelessWidget {
  final AppThemeColors colors;
  final VoidCallback onPressed;
  final String label;

  const AddCharacterButton({
    super.key,
    required this.colors,
    required this.onPressed,
    this.label = 'Add character',
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.primary,
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: colors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
