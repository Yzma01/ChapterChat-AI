import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:chapter_chat_ai/screens/auth/signup_screen.dart';
import 'package:chapter_chat_ai/screens/main_shell.dart';
import 'package:chapter_chat_ai/widgets/components/custom_button.dart';
import 'package:chapter_chat_ai/widgets/components/custom_icon.dart';
import 'package:chapter_chat_ai/widgets/components/custom_text.dart';
import 'package:chapter_chat_ai/widgets/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/loggin/loggin_bloc.dart';
import '../../blocs/loggin/loggin_state.dart';
import '../../blocs/loggin/loggin_event.dart';

class LogginScreen extends StatefulWidget {
  const LogginScreen({super.key});

  @override
  State<LogginScreen> createState() => _LogginScreenState();
}

class _LogginScreenState extends State<LogginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AuthFailure) {
            Navigator.pop(context); // remove loading
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }

          if (state is AuthSuccess) {
            Navigator.pop(context); // remove loading
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainShell()),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIcon(
                    icon: Icons.person,
                    size: 100,
                    color: theme.colors.primary,
                  ),
                  const SizedBox(height: 20),

                  CustomTextfield(
                    controller: emailCtrl,
                    hintText: 'Email',
                    icon: Icons.email,
                  ),

                  CustomTextfield(
                    controller: passCtrl,
                    hintText: 'Password',
                    isPassword: true,
                    icon: Icons.password,
                  ),

                  const SizedBox(height: 20),

                  CustomText(
                    text: "Create an account",
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

                  const SizedBox(height: 20),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: state is AuthLoading ? "Loading..." : "Login",
                        onPressed: () {
                          final email = emailCtrl.text.trim();
                          final pass = passCtrl.text.trim();

                          context.read<AuthBloc>().add(
                            LoginRequested(email: email, password: pass),
                          );
                        },
                      );
                    },
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
