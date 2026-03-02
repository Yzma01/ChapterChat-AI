import 'package:chapter_chat_ai/blocs/payment/models/card_data_model.dart';
import 'package:chapter_chat_ai/models/book.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentMembershipRequested extends PaymentEvent {
  final CardData card;
  final String membership;

  PaymentMembershipRequested({required this.card, required this.membership});

  @override
  List<Object?> get props => [card, membership];
}

class PaymentBookRequested extends PaymentEvent {
  final CardData card;
  final Book book;

  PaymentBookRequested({required this.card, required this.book});

  @override
  List<Object?> get props => [card, book];
}
