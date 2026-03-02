import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum NavTab { home, chat, shop, profile }

class BottomNavBar extends StatelessWidget {
  final NavTab currentTab;
  final ValueChanged<NavTab> onTabSelected;
  final AppThemeColors colors;
  final String? profileInitial;

  const BottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.colors,
    this.profileInitial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              tab: NavTab.home,
              icon: Icons.menu_book_rounded,
              isSelected: currentTab == NavTab.home,
            ),
            _buildNavItem(
              tab: NavTab.chat,
              icon: Icons.auto_awesome,
              isSelected: currentTab == NavTab.chat,
            ),
            _buildNavItem(
              tab: NavTab.shop,
              icon: Icons.storefront_outlined,
              isSelected: currentTab == NavTab.shop,
            ),
            _buildProfileItem(isSelected: currentTab == NavTab.profile),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required NavTab tab,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTabSelected(tab),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? colors.primary : colors.iconDefault,
        ),
      ),
    );
  }

  Widget _buildProfileItem({required bool isSelected}) {
    final initial = profileInitial ?? 'U';

    return GestureDetector(
      onTap: () => onTabSelected(NavTab.profile),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? colors.primary : Colors.deepPurple,
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
