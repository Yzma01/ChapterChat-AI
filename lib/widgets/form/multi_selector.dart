import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ValidatingMultiSelect extends FormField<List<String>> {
  ValidatingMultiSelect({
    super.key,
    required String label,
    required List<String> items,
    required AppThemeColors colors,
    required List<String> value,
    required ValueChanged<List<String>> onChanged,
    FormFieldValidator<List<String>>? validator,
  }) : super(
         initialValue: value,
         validator: validator,
         autovalidateMode: AutovalidateMode.onUserInteraction,
         builder: (FormFieldState<List<String>> field) {
           final hasError = field.hasError;

           Future<void> openDialog(BuildContext context) async {
             final tempSelected = List<String>.from(field.value ?? []);

             final result = await showDialog<List<String>>(
               context: context,
               builder:
                   (context) => AlertDialog(
                     title: Text(label),
                     content: SingleChildScrollView(
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children:
                             items.map((item) {
                               return CheckboxListTile(
                                 value: tempSelected.contains(item),
                                 title: Text(item),
                                 controlAffinity:
                                     ListTileControlAffinity.leading,
                                 onChanged: (checked) {
                                   if (checked == true) {
                                     tempSelected.add(item);
                                   } else {
                                     tempSelected.remove(item);
                                   }
                                   (context as Element).markNeedsBuild();
                                 },
                               );
                             }).toList(),
                       ),
                     ),
                     actions: [
                       TextButton(
                         onPressed: () => Navigator.pop(context),
                         child: const Text('Cancel'),
                       ),
                       ElevatedButton(
                         onPressed: () => Navigator.pop(context, tempSelected),
                         child: const Text('OK'),
                       ),
                     ],
                   ),
             );

             if (result != null) {
               field.didChange(result);
               onChanged(result);
             }
           }

           final displayText =
               field.value == null || field.value!.isEmpty
                   ? 'Genres'
                   : field.value!.join(', ');

           return Padding(
             padding: const EdgeInsets.only(bottom: 16),
             child: InkWell(
               onTap: () => openDialog(field.context),
               child: InputDecorator(
                 decoration: InputDecoration(
                   labelText: value.isEmpty ? '' : label,
                   errorText: field.errorText,
                   enabledBorder: OutlineInputBorder(
                     borderSide: BorderSide(
                       color: hasError ? colors.error : colors.border,
                     ),
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderSide: BorderSide(
                       color: hasError ? colors.error : colors.primary,
                       width: 2,
                     ),
                   ),
                   errorBorder: OutlineInputBorder(
                     borderSide: BorderSide(color: colors.error),
                   ),
                 ),
                 child: Row(
                   children: [
                     Expanded(
                       child: Text(
                         displayText,
                         overflow: TextOverflow.ellipsis,
                         style: TextStyle(
                           fontSize: 16,
                           color:
                               hasError
                                   ? colors.error
                                   : field.value!.isEmpty
                                   ? colors.textSecondary
                                   : colors.textPrimary,
                         ),
                       ),
                     ),
                     Icon(Icons.arrow_drop_down, color: colors.iconDefault),
                   ],
                 ),
               ),
             ),
           );
         },
       );
}
