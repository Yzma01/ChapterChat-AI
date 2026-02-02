import 'package:chapter_chat_ai/blocs/user/models/user_model.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class DowngradeToFreePlan extends ProfileEvent {}

class SendEmailVerification extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UserModel user;

  UpdateProfile(this.user);

  @override
  List<Object?> get props => [user];
}
