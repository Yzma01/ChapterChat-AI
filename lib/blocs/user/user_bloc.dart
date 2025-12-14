import 'package:chapter_chat_ai/blocs/user/repository/user_repository.dart';
import 'package:chapter_chat_ai/blocs/user/user_event.dart';
import 'package:chapter_chat_ai/blocs/user/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository repo;

  ProfileBloc(this.repo) : super(ProfileLoading()) {
    on<LoadProfile>((event, emit) async {
      try {
        final data = await repo.getProfile();
        emit(ProfileLoaded(data['name'], data['lastname']));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
