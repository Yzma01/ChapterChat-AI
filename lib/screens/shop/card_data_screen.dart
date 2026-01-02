import 'package:chapter_chat_ai/blocs/payment/bloc/payment_bloc.dart';
import 'package:chapter_chat_ai/blocs/payment/bloc/payment_event.dart';
import 'package:chapter_chat_ai/blocs/payment/bloc/payment_state.dart';
import 'package:chapter_chat_ai/blocs/payment/models/card_data_model.dart';
import 'package:chapter_chat_ai/core/theme/theme_provider.dart';
import 'package:chapter_chat_ai/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardInputBottomSheet extends StatefulWidget {
  final Function(CardData) onSubmit;
  final Book book;

  const CardInputBottomSheet({
    Key? key,
    required this.onSubmit,
    required this.book,
  }) : super(key: key);

  @override
  State<CardInputBottomSheet> createState() => _CardInputBottomSheetState();

  static Future<CardData?> show(BuildContext context, {required Book book}) {
    return showModalBottomSheet<CardData>(
      context: context,

      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => CardInputBottomSheet(
            onSubmit:
                (cardData) => context.read<PaymentBloc>().add(
                  PaymentRequested(card: cardData, book: book),
                ),
            book: book,
          ),
    );
  }
}

class _CardInputBottomSheetState extends State<CardInputBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    'cardNumber': TextEditingController(),
    'cardHolder': TextEditingController(),
    'expiry': TextEditingController(),
    'cvv': TextEditingController(),
  };
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String? _errorMessage;
  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        CardData(
          cardNumber: _controllers['cardNumber']!.text,
          cardHolder: _controllers['cardHolder']!.text,
          expiryDate: _controllers['expiry']!.text,
          cvv: _controllers['cvv']!.text,
        ),
      );
    } else {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }

  InputDecoration _buildDecoration(
    ThemeProvider theme,
    String label,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: TextStyle(color: Colors.red),
      labelStyle: TextStyle(color: theme.colors.textPrimary),
      floatingLabelStyle: MaterialStateTextStyle.resolveWith((states) {
        if (states.contains(MaterialState.error)) {
          return TextStyle(color: Colors.red);
        }
        return TextStyle(color: theme.colors.primary);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        debugPrint('Payment state: $state'); // Agrega esto

        if (state is PaymentLoading) {
          debugPrint('Showing loading dialog'); // Y esto
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is PaymentFailure) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            _errorMessage = state.error;
          });
        }

        if (state is PaymentSuccess) {
          Navigator.of(context, rootNavigator: true).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book bought successfully!')),
          );
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Add Card Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Muestra el error aquí
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.red,
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Card Number
                TextFormField(
                  controller: _controllers['cardNumber'],
                  decoration: _buildDecoration(
                    theme,
                    'Card Number',
                    '1234 5678 9012 3456',
                    Icons.credit_card,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Please enter card number';
                    if (value!.replaceAll(' ', '').length < 13)
                      return 'Invalid card number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Card Holder
                TextFormField(
                  controller: _controllers['cardHolder'],
                  decoration: _buildDecoration(
                    theme,
                    'Card Holder Name',
                    'John Doe',
                    Icons.person,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator:
                      (value) =>
                          (value?.isEmpty ?? true)
                              ? 'Please enter card holder name'
                              : null,
                ),
                const SizedBox(height: 16),

                // Expiry & CVV
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controllers['expiry'],
                        decoration: _buildDecoration(
                          theme,
                          'Expiry Date',
                          'MM/YY',
                          Icons.calendar_today,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryDateFormatter(),
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (value!.length < 5) return 'Invalid';

                          final parts = value.split('/');
                          if (parts.length != 2) return 'Invalid format';

                          final month = int.tryParse(parts[0]);
                          final year = int.tryParse(parts[1]);

                          if (month == null || month < 1 || month > 12) {
                            return 'Invalid month';
                          }

                          if (year == null) return 'Invalid year';

                          final now = DateTime.now();
                          final currentYear =
                              now.year % 100; // Últimos 2 dígitos
                          final currentMonth = now.month;

                          if (year < currentYear) {
                            return 'Card expired';
                          }

                          if (year == currentYear && month < currentMonth) {
                            return 'Card expired';
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _controllers['cvv'],
                        decoration: _buildDecoration(
                          theme,
                          'CVV',
                          '123',
                          Icons.lock,
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (value!.length < 3) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add Card',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Formatters
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) buffer.write(' ');
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length < 2) return newValue;

    final formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
