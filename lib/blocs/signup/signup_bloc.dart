import 'package:flutter_bloc/flutter_bloc.dart';
import 'signup_event.dart';
import 'signup_state.dart';
import './repository/signup_repository.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupRepository signupRepository;

  SignupBloc(this.signupRepository) : super(SignupInitial()) {
    on<SignupRequested>(_onSignupRequested);
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());
    try {
      await signupRepository.signup(
        event.email,
        event.password,
        event.name,
        event.username,
        event.lastname,
        event.birthdate,
        event.role,
      );
      emit(SignupSuccess());
    } catch (e) {
      emit(SignupFailure(error: "Signup Failed: ${e.toString()}"));
    }
  }
}
