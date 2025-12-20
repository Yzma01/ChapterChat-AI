import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignupRequested extends SignupEvent {
  final String email;
  final String password;
  final String name;
  final String username;
  final String lastname;
  final DateTime birthdate;
  final String role;

  SignupRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.username,
    required this.lastname,
    required this.birthdate,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password];
}
