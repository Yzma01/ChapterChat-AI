abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String lastname;

  ProfileLoaded(this.name, this.lastname);
}

class ProfileError extends ProfileState {
  final String error;
  ProfileError(this.error);
}
