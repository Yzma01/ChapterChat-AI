import 'package:equatable/equatable.dart';

class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentFailure extends PaymentState {
  final String error;

  PaymentFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class PaymentSuccess extends PaymentState {}
