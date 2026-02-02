import 'package:chapter_chat_ai/blocs/user/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'loggin_event.dart';
import 'loggin_state.dart';
import '../repository/loggin_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthBloc({required this.authRepository, required this.userRepository})
    : super(AuthInitial()) {
    on<LoginRequested>(_onLogginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.login(event.email, event.password);
      final isVerify = await userRepository.isEmailVerified();
      if (!isVerify) {
        await authRepository.logout();
        emit(
          AuthFailure(
            error:
                "Email not verified. Please verify your email. Check your spam folder if you don't see it in your inbox.",
          ),
        );
        return;
      }
      // Load profile here
      final user = await userRepository.getProfile();

      emit(AuthSuccess(user: user)); // Pass user to success state
    } catch (e) {
      emit(AuthFailure(error: "Login Failed: ${e.toString()}"));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(error: "Logout Failed: ${e.toString()}"));
    }
  }
}
