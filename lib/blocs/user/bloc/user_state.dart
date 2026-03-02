import 'package:chapter_chat_ai/blocs/user/models/user_model.dart';

abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  ProfileLoaded(this.user);
}

class ProfileError extends ProfileState {
  final String error;
  ProfileError(this.error);
}
