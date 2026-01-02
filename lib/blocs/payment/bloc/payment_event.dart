import 'package:chapter_chat_ai/screens/shop/card_data_screen.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentRequested extends PaymentEvent {
  final CardData card;

  PaymentRequested({required this.card});

  @override
  List<Object?> get props => [];
}
