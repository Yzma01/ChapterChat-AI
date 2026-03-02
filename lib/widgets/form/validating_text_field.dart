import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// A text field that properly handles validation states,
/// including turning the label red when there's an error.
class ValidatingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final AppThemeColors colors;
  final int maxLines;
  final int? maxLength;
  final String? helperText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool isRequired;
  final ValueChanged<String>? onChanged;

  const ValidatingTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.colors,
    this.maxLines = 1,
    this.maxLength,
    this.helperText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.isRequired = false,
    this.onChanged,
  });

  @override
  State<ValidatingTextField> createState() => _ValidatingTextFieldState();
}

class _ValidatingTextFieldState extends State<ValidatingTextField> {
  bool _hasError = false;
  bool _hasBeenValidated = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Only re-validate if the field has been validated before
    if (_hasBeenValidated && widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      final hasError = error != null;
      if (hasError != _hasError) {
        setState(() {
          _hasError = hasError;
        });
      }
    }
    widget.onChanged?.call(widget.controller.text);
  }

  String? _validate(String? value) {
    _hasBeenValidated = true;
    final error = widget.validator?.call(value);
    // Update error state after validation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _hasError = error != null;
        });
      }
    });
    return error;
  }

  @override
  Widget build(BuildContext context) {
    // Determine label color based on focus and error state
    Color getLabelColor(bool isFocused) {
      if (_hasError) {
        return widget.colors.error;
      }
      if (isFocused) {
        return widget.colors.primary;
      }
      return widget.colors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {});
        },
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;

            return TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              validator: _validate,
              autovalidateMode:
                  _hasBeenValidated
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
              style: TextStyle(color: widget.colors.textPrimary, fontSize: 16),
              cursorColor: widget.colors.primary,
              decoration: InputDecoration(
                labelText: widget.label,
                helperText: widget.helperText,
                helperMaxLines: 2,
                labelStyle: TextStyle(
                  color: getLabelColor(false),
                  fontSize: 16,
                ),
                floatingLabelStyle: TextStyle(
                  color: getLabelColor(isFocused || _focusNode.hasFocus),
                  fontSize: 14,
                ),
                helperStyle: TextStyle(
                  color: widget.colors.textSecondary,
                  fontSize: 12,
                ),
                errorStyle: TextStyle(color: widget.colors.error, fontSize: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color:
                        _hasError ? widget.colors.error : widget.colors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color:
                        _hasError ? widget.colors.error : widget.colors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: widget.colors.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: widget.colors.error, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
