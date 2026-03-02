import 'package:chapter_chat_ai/blocs/chat/bloc/chat_bloc.dart';
import 'package:chapter_chat_ai/blocs/chat/bloc/chat_event.dart';
import 'package:chapter_chat_ai/blocs/loggin/bloc/loggin_bloc.dart';
import 'package:chapter_chat_ai/blocs/loggin/bloc/loggin_event.dart';
import 'package:chapter_chat_ai/blocs/loggin/bloc/loggin_state.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_bloc.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_event.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_state.dart';
import 'package:chapter_chat_ai/core/user/user_provider.dart';
import 'package:chapter_chat_ai/screens/auth/loggin_screen.dart';
import 'package:chapter_chat_ai/screens/shop/card_data_screen.dart';
import 'package:chapter_chat_ai/widgets/profile/settings_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../widgets/profile/plan_card.dart';

class ProfileContent extends StatefulWidget {
  final AppThemeColors colors;

  const ProfileContent({super.key, required this.colors});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  void _onPlanSelected(bool premium) async {
    if (premium) return;
    await CardInputBottomSheet.show(context, null, isMembership: true);
    context.read<ProfileBloc>().add(LoadProfile());
  }

  void _onLogout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  void _onSettings() {
    final theme = context.read<ThemeProvider>();
    final profileBLoc = context.read<ProfileBloc>();
    final chatBloc = context.read<ChatBloc>();
    final isPremium = context.read<UserProvider>().user!.isPremium;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: theme.colors.surface,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: theme.colors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: theme.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your account & data',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: theme.colors.textSecondary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Divider
                Container(
                  height: 1,
                  color: theme.colors.textSecondary.withOpacity(0.1),
                ),

                const SizedBox(height: 20),

                // Options
                SettingsOption(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Change to Free Plan',
                  subtitle: 'Downgrade your membership',
                  iconColor: theme.colors.primary,
                  iconBackgroundColor: theme.colors.primary.withOpacity(0.1),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (!isPremium) return;
                    profileBLoc.add(DowngradeToFreePlan());
                  },
                ),

                const SizedBox(height: 12),

                SettingsOption(
                  icon: Icons.delete_outline,
                  title: 'Clear Local Data',
                  subtitle: 'Delete books & characters',
                  iconColor: theme.colors.error,
                  iconBackgroundColor: theme.colors.error.withOpacity(0.1),
                  isDestructive: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    chatBloc.add(ClearLocalData());
                  },
                ),

                const SizedBox(height: 20),

                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'These actions may affect your saved data',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final name = user.name;
    final lastname = user.lastname;
    final isPremium = user.isPremium;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LogginScreen()),
            (_) => false,
          );
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Avatar del usuario
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Saludo con nombre
              Text(
                'Hi, ${name} ${lastname}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // Opciones: Theme toggle y Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Theme toggle button
                  _buildThemeToggle(),

                  const SizedBox(width: 12),

                  // Settings button
                  _buildIconButton(
                    icon: Icons.settings_outlined,
                    onTap: () {
                      _onSettings();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Logout button
              _buildLogoutButton(),

              const SizedBox(height: 16),

              // Plan cards - Expanded para ocupar el espacio disponible
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Free Plan
                    Expanded(
                      child: PlanCard(
                        title: 'Free',
                        isSelected: !isPremium,
                        isPremium: false,
                        colors: colors,
                        onTap: () => () {},
                        features: [
                          PlanFeature(
                            icon: Icons.library_books_outlined,
                            text: 'Personal library management',
                            iconColor: colors.primary,
                          ),
                          PlanFeature(
                            icon: Icons.search,
                            text: 'Book search',
                            iconColor: Colors.amber,
                          ),
                          PlanFeature(
                            icon: Icons.check_circle_outline,
                            text: 'Mark books as read',
                            iconColor: Colors.green,
                          ),
                          PlanFeature(
                            icon: Icons.storefront_outlined,
                            text: 'Book shop',
                            iconColor: Colors.purple,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Premium Plan
                    Expanded(
                      child: PlanCard(
                        title: 'Premium',
                        subtitle: '\$9,99/month',
                        isSelected: isPremium,
                        isPremium: true,
                        colors: colors,
                        onTap: () => _onPlanSelected(isPremium),
                        features: [
                          PlanFeature(
                            icon: Icons.verified_outlined,
                            text: 'Everything in Free Plan',
                            iconColor: colors.primary,
                          ),
                          PlanFeature(
                            icon: Icons.auto_awesome,
                            text: 'AI chats with characters',
                            iconColor: Colors.amber,
                          ),
                          PlanFeature(
                            icon: Icons.summarize_outlined,
                            text: 'AI automatic summaries',
                            iconColor: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Footer
              _buildFooter(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final colors = widget.colors;

    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => context.read<ThemeProvider>().toggleTheme(),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = widget.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: colors.iconDefault, size: 26),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final colors = widget.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onLogout,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.logout, color: colors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final colors = widget.colors;

    return Column(
      children: [
        // Privacy Policy · Terms of Service
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                debugPrint('Privacy Policy pressed');
              },
              child: Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
            Text(
              '  ·  ',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            GestureDetector(
              onTap: () {
                debugPrint('Terms of Service pressed');
              },
              child: Text(
                'Terms of Service',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // ChapterChat AI
        Text(
          'ChapterChat AI',
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
      ],
    );
  }
}
