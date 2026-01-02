import 'dart:io';

import 'package:chapter_chat_ai/blocs/payment/bloc/payment_event.dart';
import 'package:chapter_chat_ai/blocs/payment/bloc/payment_state.dart';
import 'package:chapter_chat_ai/blocs/payment/reporitory/payment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;

  PaymentBloc(this.paymentRepository) : super((PaymentInitial())) {
    on<PaymentRequested>(_onPaymentRequested);
  }

  Future<void> _onPaymentRequested(
    PaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    sleep(Duration(seconds: 5));
    emit(PaymentLoading());

    try {
      emit(PaymentSuccess());
    } catch (e) {
      emit(PaymentFailure(error: "Payment Error: ${e.toString()}"));
    }
  }
}
