import 'package:chapter_chat_ai/blocs/payment/models/card_data_model.dart';
import 'package:chapter_chat_ai/models/book.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentRequested extends PaymentEvent {
  final CardData card;
  final Book book;

  PaymentRequested({required this.card, required this.book});

  @override
  List<Object?> get props => [card, book];
}
