import 'package:chapter_chat_ai/blocs/loggin/loggin_bloc.dart';
import 'package:chapter_chat_ai/blocs/loggin/loggin_event.dart';
import 'package:chapter_chat_ai/blocs/loggin/loggin_state.dart';
import 'package:chapter_chat_ai/blocs/user/user_bloc.dart';
import 'package:chapter_chat_ai/blocs/user/user_event.dart';
import 'package:chapter_chat_ai/blocs/user/user_state.dart';
import 'package:chapter_chat_ai/screens/auth/loggin_screen.dart';
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
  bool _isPremium = false; // Estado del plan (Free o Premium)

  void _onPlanSelected(bool premium) {
    setState(() {
      _isPremium = premium;
    });
  }

  void _onLogout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

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
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is ProfileError) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Error: ${state.error}',
                  style: TextStyle(color: colors.textPrimary),
                ),
              ),
            );
          }
          if (state is ProfileLoaded) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Avatar del usuario
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple,
                      ),
                      child: Center(
                        child: Text(
                          state.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Saludo con nombre
                    Text(
                      'Hi, ${state.name} ${state.lastname}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 28),

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
                            debugPrint('Settings pressed');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Logout button
                    _buildLogoutButton(),

                    const SizedBox(height: 32),

                    // Plan cards
                    SizedBox(
                      height: 280,
                      child: Row(
                        children: [
                          // Free Plan
                          Expanded(
                            child: PlanCard(
                              title: 'Free',
                              isSelected: !_isPremium,
                              isPremium: false,
                              colors: colors,
                              onTap: () => _onPlanSelected(false),
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
                              isSelected: _isPremium,
                              isPremium: true,
                              colors: colors,
                              onTap: () => _onPlanSelected(true),
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

                    const SizedBox(height: 32),

                    // Footer
                    _buildFooter(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('Unknown state')),
          );
        },
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
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ),
            Text(
              '  ·  ',
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            GestureDetector(
              onTap: () {
                debugPrint('Terms of Service pressed');
              },
              child: Text(
                'Terms of Service',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ChapterChat AI
        Text(
          'ChapterChat AI',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
      ],
    );
  }
}
