import 'package:chapter_chat_ai/blocs/user/repository/user_repository.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_event.dart';
import 'package:chapter_chat_ai/blocs/user/bloc/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository repo;

  ProfileBloc(this.repo) : super(ProfileLoading()) {
    on<LoadProfile>((event, emit) async {
      try {
        final user = await repo.getProfile();
        emit(ProfileLoaded(user));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
    on<UpdateProfile>((event, emit) {
      // Directly update with already-loaded user
      emit(ProfileLoaded(event.user));
    });
    on<DowngradeToFreePlan>((event, emit) async {
      try {
        emit(ProfileLoading());
        await repo.downgradeToFreePlan();
        final updatedUser = await repo.getProfile();
        emit(ProfileLoaded(updatedUser));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
    on<SendEmailVerification>((event, emit) async {
      try {
        await repo.sendVerificationEmail();
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
