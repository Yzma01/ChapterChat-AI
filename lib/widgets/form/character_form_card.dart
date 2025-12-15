import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Data class to hold character form controllers
class CharacterFormData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}

/// A card widget for entering character information with validation support.
class CharacterFormCard extends StatefulWidget {
  final int index;
  final CharacterFormData character;
  final AppThemeColors colors;
  final VoidCallback onRemove;
  final bool showValidationErrors;

  const CharacterFormCard({
    super.key,
    required this.index,
    required this.character,
    required this.colors,
    required this.onRemove,
    this.showValidationErrors = false,
  });

  @override
  State<CharacterFormCard> createState() => _CharacterFormCardState();
}

class _CharacterFormCardState extends State<CharacterFormCard> {
  bool _nameHasError = false;
  bool _descriptionHasError = false;
  bool _hasBeenValidated = false;

  bool _nameFocused = false;
  bool _descriptionFocused = false;

  @override
  void initState() {
    super.initState();
    widget.character.nameController.addListener(_onNameChanged);
    widget.character.descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void didUpdateWidget(CharacterFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When showValidationErrors changes to true, validate fields
    if (widget.showValidationErrors && !oldWidget.showValidationErrors) {
      _validateFields();
    }
  }

  @override
  void dispose() {
    widget.character.nameController.removeListener(_onNameChanged);
    widget.character.descriptionController.removeListener(
      _onDescriptionChanged,
    );
    super.dispose();
  }

  void _validateFields() {
    _hasBeenValidated = true;
    setState(() {
      _nameHasError = widget.character.nameController.text.trim().isEmpty;
      _descriptionHasError =
          widget.character.descriptionController.text.trim().isEmpty;
    });
  }

  void _onNameChanged() {
    if (_hasBeenValidated || widget.showValidationErrors) {
      final hasError = widget.character.nameController.text.trim().isEmpty;
      if (hasError != _nameHasError) {
        setState(() {
          _nameHasError = hasError;
        });
      }
    }
  }

  void _onDescriptionChanged() {
    if (_hasBeenValidated || widget.showValidationErrors) {
      final hasError =
          widget.character.descriptionController.text.trim().isEmpty;
      if (hasError != _descriptionHasError) {
        setState(() {
          _descriptionHasError = hasError;
        });
      }
    }
  }

  Color _getNameLabelColor() {
    if (_nameHasError) return widget.colors.error;
    if (_nameFocused) return widget.colors.primary;
    return widget.colors.textSecondary;
  }

  Color _getDescriptionLabelColor() {
    if (_descriptionHasError) return widget.colors.error;
    if (_descriptionFocused) return widget.colors.primary;
    return widget.colors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    // Check for validation errors if showValidationErrors is true
    final showNameError =
        widget.showValidationErrors &&
        widget.character.nameController.text.trim().isEmpty;
    final showDescError =
        widget.showValidationErrors &&
        widget.character.descriptionController.text.trim().isEmpty;

    // Update local error state
    if (showNameError != _nameHasError ||
        showDescError != _descriptionHasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _nameHasError = showNameError;
            _descriptionHasError = showDescError;
            _hasBeenValidated = true;
          });
        }
      });
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Character ${widget.index + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.colors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                icon: Icon(
                  Icons.delete_outline,
                  color: widget.colors.error,
                  size: 22,
                ),
                tooltip: 'Remove character',
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Name field
          Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _nameFocused = hasFocus;
              });
            },
            child: TextFormField(
              controller: widget.character.nameController,
              style: TextStyle(color: widget.colors.textPrimary, fontSize: 16),
              cursorColor: widget.colors.primary,
              decoration: InputDecoration(
                labelText: 'Character name',
                labelStyle: TextStyle(
                  color: _getNameLabelColor(),
                  fontSize: 16,
                ),
                floatingLabelStyle: TextStyle(
                  color: _getNameLabelColor(),
                  fontSize: 14,
                ),
                errorText: _nameHasError ? 'Please enter a name' : null,
                errorStyle: TextStyle(color: widget.colors.error, fontSize: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color:
                        _nameHasError
                            ? widget.colors.error
                            : widget.colors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color:
                        _nameHasError
                            ? widget.colors.error
                            : widget.colors.primary,
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
                  vertical: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Description field
          Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _descriptionFocused = hasFocus;
              });
            },
            child: TextFormField(
              controller: widget.character.descriptionController,
              style: TextStyle(color: widget.colors.textPrimary, fontSize: 16),
              cursorColor: widget.colors.primary,
              maxLines: 3,
              maxLength: 150,
              decoration: InputDecoration(
                labelText: 'Character description',
                helperText:
                    'Describe personality, role, and key traits. Be detailed for better AI responses.',
                helperMaxLines: 2,
                labelStyle: TextStyle(
                  color: _getDescriptionLabelColor(),
                  fontSize: 16,
                ),
                floatingLabelStyle: TextStyle(
                  color: _getDescriptionLabelColor(),
                  fontSize: 14,
                ),
                helperStyle: TextStyle(
                  color: widget.colors.textSecondary,
                  fontSize: 12,
                ),
                errorText:
                    _descriptionHasError ? 'Please enter a description' : null,
                errorStyle: TextStyle(color: widget.colors.error, fontSize: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color:
                        _descriptionHasError
                            ? widget.colors.error
                            : widget.colors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color:
                        _descriptionHasError
                            ? widget.colors.error
                            : widget.colors.primary,
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
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
