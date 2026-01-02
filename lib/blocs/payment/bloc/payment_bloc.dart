import 'package:chapter_chat_ai/blocs/payment/bloc/payment_event.dart';
import 'package:chapter_chat_ai/blocs/payment/bloc/payment_state.dart';
import 'package:chapter_chat_ai/blocs/payment/models/payment_model.dart';
import 'package:chapter_chat_ai/blocs/payment/reporitory/payment_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentBloc(this.paymentRepository) : super((PaymentInitial())) {
    on<PaymentRequested>(_onPaymentRequested);
  }

  String getErrorMessage(int code) {
    switch (code) {
      case 400:
        return 'Invalid card information. Please check your details.';
      case 401:
        return 'Payment declined. Please try a different card.';
      case 408:
        return 'Payment timed out. Please check your connection.';
      case 444:
        return 'Payment service unavailable. Please try again later.';
      default:
        return 'Payment failed (Code: $code). Please try again.';
    }
  }

  Future<void> _onPaymentRequested(
    PaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final results = await Future.wait([
        paymentRepository.pay(event.card),
        Future.delayed(const Duration(seconds: 2)), // Mínimo 2 segundos
      ]);

      final payment = results[0] as PaymentModel;
      if (payment.code == 200) {
        await paymentRepository.saveTransaction(
          payment.id,
          event.book,
          event.card,
        );
        emit(PaymentSuccess());
      } else {
        emit(PaymentFailure(error: getErrorMessage(payment.code)));
      }
    } catch (e) {
      emit(PaymentFailure(error: "Payment Error: ${e.toString()}"));
    }
  }
}
