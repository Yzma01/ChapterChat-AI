import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Delegate for creating a sticky/pinned section header
class StickySectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final AppThemeColors colors;
  final double height;
  final EdgeInsets padding;

  StickySectionHeaderDelegate({
    required this.title,
    required this.colors,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: height,
      color: colors.background,
      padding: padding,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickySectionHeaderDelegate oldDelegate) {
    return title != oldDelegate.title ||
        colors != oldDelegate.colors ||
        height != oldDelegate.height;
  }
}

/// Widget wrapper for easier use of sticky section header
class StickySectionHeader extends StatelessWidget {
  final String title;
  final AppThemeColors colors;
  final double height;
  final EdgeInsets padding;

  const StickySectionHeader({
    super.key,
    required this.title,
    required this.colors,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickySectionHeaderDelegate(
        title: title,
        colors: colors,
        height: height,
        padding: padding,
      ),
    );
  }
}
