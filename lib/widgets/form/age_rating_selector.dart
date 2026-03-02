import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A selector widget for choosing minimum age ratings.
class AgeRatingSelector extends StatelessWidget {
  final int selectedAge;
  final List<int> ageRatings;
  final AppThemeColors colors;
  final ValueChanged<int> onAgeSelected;
  final String? label;

  const AgeRatingSelector({
    super.key,
    required this.selectedAge,
    required this.ageRatings,
    required this.colors,
    required this.onAgeSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            children:
                ageRatings.map((age) {
                  final isSelected = selectedAge == age;
                  return ChoiceChip(
                    label: Text(age == 0 ? 'All ages' : '$age+'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        onAgeSelected(age);
                      }
                    },
                    selectedColor: colors.primary,
                    backgroundColor: colors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : colors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.border,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
