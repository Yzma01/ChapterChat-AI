import 'package:chapter_chat_ai/blocs/signup/signup_bloc.dart';
import 'package:chapter_chat_ai/blocs/signup/signup_event.dart';
import 'package:chapter_chat_ai/blocs/signup/signup_state.dart';
import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:chapter_chat_ai/screens/main_shell.dart';
import 'package:chapter_chat_ai/widgets/components/custom_button.dart';
import 'package:chapter_chat_ai/widgets/components/custom_datepicker.dart';
import 'package:chapter_chat_ai/widgets/components/custom_selectbox.dart';
import 'package:chapter_chat_ai/widgets/components/custom_text.dart';
import 'package:chapter_chat_ai/widgets/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameCtrl = TextEditingController();
  final lastnameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final birthdateCtrl = TextEditingController();

  String? selectedRole;
  DateTime birthdate = DateTime.now();

  @override
  void dispose() {
    nameCtrl.dispose();
    lastnameCtrl.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    birthdateCtrl.dispose();
    super.dispose();
  }

  void _onSignup() {
    final signupBloc = context.read<SignupBloc>();

    // Parse birthdate from controller
    if (birthdateCtrl.text.isNotEmpty) {
      final parts = birthdateCtrl.text.split('/');
      if (parts.length == 3) {
        birthdate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }

    signupBloc.add(
      SignupRequested(
        name: nameCtrl.text.trim(),
        lastname: lastnameCtrl.text.trim(),
        username: usernameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        birthdate: birthdate,
        role: selectedRole ?? 'Reader',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colors.iconDefault),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupLoading) {
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

          if (state is SignupFailure) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: theme.colors.error,
              ),
            );
          }

          if (state is SignupSuccess) {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainShell()),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Title
                Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: theme.colors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Enter your information to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Name fields row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextfield(
                        controller: nameCtrl,
                        hintText: 'First name',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextfield(
                        controller: lastnameCtrl,
                        hintText: 'Last name',
                      ),
                    ),
                  ],
                ),

                // Username
                CustomTextfield(controller: usernameCtrl, hintText: 'Username'),

                // Email
                CustomTextfield(
                  controller: emailCtrl,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),

                // Password
                CustomTextfield(
                  controller: passCtrl,
                  hintText: 'Password',
                  isPassword: true,
                ),

                // Helper text for password
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Use 8 or more characters with a mix of letters, numbers & symbols',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colors.textSecondary,
                    ),
                  ),
                ),

                // Birthdate and Role row
                Row(
                  children: [
                    Expanded(
                      child: CustomDatepicker(
                        controller: birthdateCtrl,
                        hintText: 'Birthdate',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomSelectbox(
                        items: const ['Writer', 'Reader'],
                        hintText: 'Role',
                        value: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Terms text
                Text.rich(
                  TextSpan(
                    text: 'By creating an account, you agree to our ',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sign in link
                    CustomText(
                      text: 'Sign in instead',
                      isLink: true,
                      onTap: () => Navigator.pop(context),
                    ),

                    // Create button
                    BlocBuilder<SignupBloc, SignupState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: 100,
                          child: CustomButton(
                            text: 'Create',
                            isLoading: state is SignupLoading,
                            onPressed: _onSignup,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
