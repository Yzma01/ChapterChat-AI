import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomSelectbox extends StatefulWidget {
  final List<String> items;
  final String hintText;
  final ValueChanged<String?> onChanged;
  final String? value;

  const CustomSelectbox({
    super.key,
    required this.items,
    required this.hintText,
    required this.onChanged,
    this.value,
  });

  @override
  State<CustomSelectbox> createState() => _CustomSelectboxState();
}

class _CustomSelectboxState extends State<CustomSelectbox> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: widget.value,
        icon: Icon(Icons.arrow_drop_down, color: theme.colors.iconDefault),
        dropdownColor: theme.colors.surface,
        style: TextStyle(color: theme.colors.textPrimary, fontSize: 16),
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
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.colors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: theme.colors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items:
            widget.items
                .map(
                  (item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
        onChanged: widget.onChanged,
      ),
    );
  }
}
