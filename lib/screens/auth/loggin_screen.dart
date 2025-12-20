import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:chapter_chat_ai/screens/auth/signup_screen.dart';
import 'package:chapter_chat_ai/screens/main_shell.dart';
import 'package:chapter_chat_ai/widgets/components/custom_button.dart';
import 'package:chapter_chat_ai/widgets/components/custom_text.dart';
import 'package:chapter_chat_ai/widgets/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/loggin/bloc/loggin_bloc.dart';
import '../../blocs/loggin/bloc/loggin_state.dart';
import '../../blocs/loggin/bloc/loggin_event.dart';

class LogginScreen extends StatefulWidget {
  const LogginScreen({super.key});

  @override
  State<LogginScreen> createState() => _LogginScreenState();
}

class _LogginScreenState extends State<LogginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (_) => Center(
                    child: CircularProgressIndicator(
                      color: theme.colors.primary,
                    ),
                  ),
            );
          }

          if (state is AuthFailure) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: theme.colors.error,
              ),
            );
          }

          if (state is AuthSuccess) {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainShell()),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: theme.colors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Use your ChapterChat account',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email field
                  CustomTextfield(
                    controller: emailCtrl,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // Password field
                  CustomTextfield(
                    controller: passCtrl,
                    hintText: 'Password',
                    isPassword: true,
                  ),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: 'Forgot password?',
                      isLink: true,
                      onTap: () {
                        debugPrint('Forgot password pressed');
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Create account and Login row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Create account link
                      CustomText(
                        text: 'Create account',
                        isLink: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                      ),

                      // Login button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: 100,
                            child: CustomButton(
                              text: 'Sign in',
                              isLoading: state is AuthLoading,
                              onPressed: () {
                                final email = emailCtrl.text.trim();
                                final pass = passCtrl.text.trim();

                                context.read<AuthBloc>().add(
                                  LoginRequested(email: email, password: pass),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
