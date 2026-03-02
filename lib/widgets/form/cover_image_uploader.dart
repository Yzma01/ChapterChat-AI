import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';

/// Widget for uploading cover images with preview
class CoverImageUploader extends StatefulWidget {
  final AppThemeColors colors;
  final Function(File?) onImageSelected;
  final String? Function(File?)? validator;

  const CoverImageUploader({
    super.key,
    required this.colors,
    required this.onImageSelected,
    this.validator,
  });

  @override
  State<CoverImageUploader> createState() => _CoverImageUploaderState();
}

class _CoverImageUploaderState extends State<CoverImageUploader> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _errorMessage;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Validate file size (max 5MB)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          setState(() {
            _errorMessage = 'Image size must be less than 5MB';
          });
          return;
        }

        setState(() {
          _selectedImage = file;
          _errorMessage = null;
        });

        widget.onImageSelected(file);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _errorMessage = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview or upload button
        if (_selectedImage == null)
          _buildUploadButton()
        else
          _buildImagePreview(),

        // Error message
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],

        // Validation error from parent
        if (widget.validator != null) ...[
          const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final error = widget.validator!(_selectedImage);
              if (error != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],

        const SizedBox(height: 8),
        Text(
          'Recommended size: 800x1200px • Max 5MB • JPG, PNG, or WEBP',
          style: TextStyle(fontSize: 12, color: widget.colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: widget.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _errorMessage != null ? Colors.red : widget.colors.border,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: widget.colors.iconDefault,
            ),
            const SizedBox(height: 12),
            Text(
              'Upload Book Cover',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to select image',
              style: TextStyle(
                fontSize: 14,
                color: widget.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.colors.border),
      ),
      child: Column(
        children: [
          // Image preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                // Remove button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: _removeImage,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Change button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Change Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.colors.primary,
                  side: BorderSide(color: widget.colors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
