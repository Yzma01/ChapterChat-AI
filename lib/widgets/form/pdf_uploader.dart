import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PdfUploader extends FormField<File> {
  PdfUploader({
    super.key,
    required AppThemeColors colors,
    required ValueChanged<File> onFileSelected,
    String label = 'Upload PDF',
    String? Function(File?)? validator,
  }) : super(
         validator: validator,
         autovalidateMode: AutovalidateMode.onUserInteraction,
         builder: (FormFieldState<File> field) {
           final hasError = field.hasError;
           final file = field.value;
           final fileName = file != null ? file.path.split('/').last : null;

           Future<void> pickPDF(BuildContext context) async {
             try {
               final result = await FilePicker.platform.pickFiles(
                 type: FileType.custom,
                 allowedExtensions: ['pdf'],
               );

               if (result == null) return;

               final picked = result.files.single;
               if (picked.path == null) {
                 field.didChange(null);
                 return;
               }

               final pdf = File(picked.path!);
               field.didChange(pdf);
               onFileSelected(pdf);
             } catch (_) {
               field.didChange(null);
             }
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               GestureDetector(
                 onTap: () => pickPDF(field.context),
                 child: Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     color: colors.surface,
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(
                       color: hasError ? colors.error : colors.border,
                     ),
                   ),
                   child: Column(
                     children: [
                       Icon(
                         file != null
                             ? Icons.picture_as_pdf
                             : Icons.upload_file,
                         size: 48,
                         color:
                             hasError
                                 ? colors.error
                                 : file != null
                                 ? colors.primary
                                 : colors.iconDefault,
                       ),
                       const SizedBox(height: 12),
                       Text(
                         fileName ?? label,
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w500,
                           color: hasError ? colors.error : colors.textPrimary,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         file != null
                             ? 'Tap to change file'
                             : 'Only PDF files are accepted',
                         style: TextStyle(
                           fontSize: 14,
                           color:
                               hasError ? colors.error : colors.textSecondary,
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
               if (hasError && field.errorText != null) ...[
                 const SizedBox(height: 8),
                 Padding(
                   padding: const EdgeInsets.only(left: 12),
                   child: Text(
                     field.errorText!,
                     style: TextStyle(fontSize: 12, color: colors.error),
                   ),
                 ),
               ],
             ],
           );
         },
       );
}
