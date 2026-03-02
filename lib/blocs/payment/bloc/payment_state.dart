import 'package:equatable/equatable.dart';

class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class BookPurchaseSuccess extends PaymentState {
  final String bookId;
  final String confirmationMessage = "Book purchased successfully.";

  BookPurchaseSuccess(this.bookId);
  @override
  List<Object?> get props => [bookId, confirmationMessage];
}

class PaymentFailure extends PaymentState {
  final String error;

  PaymentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class PaymentSuccess extends PaymentState {
  final String confirmationMessage;

  PaymentSuccess({required this.confirmationMessage});

  @override
  List<Object?> get props => [confirmationMessage];
}
