import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? errorText;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType,
    this.errorText,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword && _obscureText,
        keyboardType: widget.keyboardType,
        style: TextStyle(color: theme.colors.textPrimary, fontSize: 16),
        cursorColor: theme.colors.primary,
        decoration: InputDecoration(
          labelText: widget.hintText,
          labelStyle: TextStyle(
            color: theme.colors.textSecondary,
            fontSize: 16,
          ),
          floatingLabelStyle: TextStyle(
            color: theme.colors.primary,
            fontSize: 14,
          ),
          errorText: widget.errorText,
          errorStyle: TextStyle(color: theme.colors.error, fontSize: 12),
          // Password visibility toggle
          suffixIcon:
              widget.isPassword
                  ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: theme.colors.iconDefault,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                  : null,
          // Google-style outlined border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.colors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.colors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.colors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.colors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
