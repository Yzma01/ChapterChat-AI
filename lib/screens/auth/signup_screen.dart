import 'package:chapter_chat_ai/blocs/signup/signup_bloc.dart';
import 'package:chapter_chat_ai/blocs/signup/signup_event.dart';
import 'package:chapter_chat_ai/blocs/signup/signup_state.dart';
import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:chapter_chat_ai/widgets/common/theme_toggle_button.dart';
import 'package:chapter_chat_ai/widgets/components/custom_button.dart';
import 'package:chapter_chat_ai/widgets/components/custom_datepicker.dart';
import 'package:chapter_chat_ai/widgets/components/custom_icon.dart';
import 'package:chapter_chat_ai/widgets/components/custom_selectbox.dart';
import 'package:chapter_chat_ai/widgets/components/custom_text.dart';
import 'package:chapter_chat_ai/widgets/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final namectrl = TextEditingController();
  final emailctrl = TextEditingController();
  final passctrl = TextEditingController();
  final usernamectrl = TextEditingController();
  final lastnamectrl = TextEditingController();
  final birthdatectrl = TextEditingController();
  final rolectrl = TextEditingController();

  final DateTime birthdate = DateTime.now();

  void onPressed() async {
    final signupBloc = context.read<SignupBloc>();

    signupBloc.add(
      SignupRequested(
        name: namectrl.text,
        lastname: lastnamectrl.text,
        username: usernamectrl.text,
        email: emailctrl.text,
        password: passctrl.text,
        birthdate: birthdate,
        role: rolectrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupLoading) {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is SignupFailure) {
            Navigator.pop(context); // remove loading
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }

          if (state is SignupSuccess) {
            Navigator.pop(context); // remove loading
            Navigator.pushReplacementNamed(context, "/home");
          }
        },
        child: Center(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [ThemeToggleButton(themeProvider: theme)],
                      ),
                      CustomIcon(
                        icon: Icons.person,
                        size: 50,
                        color: theme.colors.primary,
                      ),
                      const SizedBox(height: 20),
                      CustomTextfield(
                        controller: namectrl,
                        hintText: "Name",
                        icon: Icons.account_box_rounded,
                      ),
                      CustomTextfield(
                        controller: lastnamectrl,
                        hintText: "Last Name",
                        icon: Icons.account_box_rounded,
                      ),
                      CustomTextfield(
                        controller: usernamectrl,
                        hintText: "Username",
                        icon: Icons.account_circle_rounded,
                      ),
                      CustomTextfield(
                        controller: emailctrl,
                        hintText: "Email",
                        icon: Icons.email_rounded,
                      ),
                      CustomTextfield(
                        controller: passctrl,
                        hintText: "Password",
                        isPassword: true,
                        icon: Icons.lock_rounded,
                      ),
                      CustomDatepicker(
                        controller: birthdatectrl,
                        hintText: "Birthdate",
                        icon: Icons.date_range_rounded,
                      ),
                      CustomSelectbox(
                        items: ["Writter", "Reader"],
                        hintText: "Role",
                        onChanged: (e) => rolectrl.text = e ?? '',
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(text: "Sing Up", onPressed: onPressed),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
