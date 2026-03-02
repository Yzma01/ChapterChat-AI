import 'package:chapter_chat_ai/blocs/user/models/user_model.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// loggin_state.dart
class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
