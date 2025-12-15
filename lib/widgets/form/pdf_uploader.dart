import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A widget for uploading PDF files with visual feedback.
class PdfUploader extends StatelessWidget {
  final String? fileName;
  final AppThemeColors colors;
  final VoidCallback onTap;
  final bool hasError;
  final String? errorText;

  const PdfUploader({
    super.key,
    required this.fileName,
    required this.colors,
    required this.onTap,
    this.hasError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isUploaded = fileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? colors.error : colors.border,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isUploaded ? Icons.picture_as_pdf : Icons.upload_file,
                  size: 48,
                  color: isUploaded ? colors.primary : colors.iconDefault,
                ),
                const SizedBox(height: 12),
                Text(
                  fileName ?? 'Upload PDF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUploaded
                      ? 'Tap to change file'
                      : 'Only PDF files are accepted',
                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
              style: TextStyle(fontSize: 12, color: colors.error),
            ),
          ),
        ],
      ],
    );
  }
}
