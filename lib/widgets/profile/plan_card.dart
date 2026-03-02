import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PlanFeature {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const PlanFeature({required this.icon, required this.text, this.iconColor});
}

class PlanCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<PlanFeature> features;
  final bool isSelected;
  final bool isPremium;
  final VoidCallback? onTap;
  final AppThemeColors colors;

  const PlanCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.features,
    required this.isSelected,
    required this.colors,
    this.isPremium = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPremium ? colors.primary : colors.border,
            width: isPremium ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del plan
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ),

            // Subtítulo del plan (opcional)
            const SizedBox(height: 16),

            // Lista de características
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      feature.icon,
                      size: 18,
                      color: feature.iconColor ?? colors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature.text,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (subtitle != null)
              Center(
                child: Text(
                  subtitle!,
                  style: TextStyle(fontSize: 16, color: colors.textSecondary),
                ),
              ),
            const SizedBox(height: 12),
            const Spacer(),

            // Radio button de selección
            Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.border,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primary,
                            ),
                          ),
                        )
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
