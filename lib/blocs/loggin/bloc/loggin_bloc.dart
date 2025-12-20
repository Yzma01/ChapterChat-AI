import 'package:flutter_bloc/flutter_bloc.dart';
import 'loggin_event.dart';
import 'loggin_state.dart';
import '../repository/loggin_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
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
      emit(AuthSuccess());
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
