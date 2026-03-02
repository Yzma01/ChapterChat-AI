import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A dropdown that properly handles validation states,
/// including turning the label red when there's an error.
class ValidatingDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final AppThemeColors colors;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;

  const ValidatingDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.colors,
    required this.onChanged,
    this.validator,
    this.isRequired = true,
  });

  @override
  State<ValidatingDropdown> createState() => _ValidatingDropdownState();
}

class _ValidatingDropdownState extends State<ValidatingDropdown> {
  bool _hasError = false;
  bool _hasBeenValidated = false;
  bool _isFocused = false;

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

  void _onChanged(String? value) {
    widget.onChanged(value);
    // Re-validate if has been validated before
    if (_hasBeenValidated && widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _hasError = error != null;
      });
    }
  }

  Color _getLabelColor() {
    if (_hasError) {
      return widget.colors.error;
    }
    if (_isFocused) {
      return widget.colors.primary;
    }
    return widget.colors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: DropdownButtonFormField<String>(
          value: widget.value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: widget.colors.iconDefault),
          dropdownColor: widget.colors.surface,
          style: TextStyle(color: widget.colors.textPrimary, fontSize: 16),
          validator: _validate,
          autovalidateMode:
              _hasBeenValidated
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(color: _getLabelColor(), fontSize: 16),
            floatingLabelStyle: TextStyle(
              color: _getLabelColor(),
              fontSize: 14,
            ),
            errorStyle: TextStyle(color: widget.colors.error, fontSize: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: _hasError ? widget.colors.error : widget.colors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: _hasError ? widget.colors.error : widget.colors.primary,
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
              horizontal: 12,
              vertical: 16,
            ),
          ),
          items:
              widget.items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
          onChanged: _onChanged,
        ),
      ),
    );
  }
}
