import 'package:flutter/material.dart';
import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDatepicker extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomDatepicker({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  State<CustomDatepicker> createState() => _CustomDatepickerState();
}

class _CustomDatepickerState extends State<CustomDatepicker> {
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final theme = context.read<ThemeProvider>();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.colors.primary,
              onPrimary: Colors.white,
              surface: theme.colors.surface,
              onSurface: theme.colors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.controller.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: _selectDate,
        child: AbsorbPointer(
          child: TextField(
            controller: widget.controller,
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
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                color: theme.colors.iconDefault,
                size: 20,
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
          ),
        ),
      ),
    );
  }
}
