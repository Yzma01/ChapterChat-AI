import 'package:chapter_chat_ai/blocs/user/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isReady => _user != null;

  String? get uid => _user?.uid;
  String get membership => _user?.membership ?? 'free';
  DateTime? get membershipDueDate => _user?.membershipDueDate;
  String? get role => _user?.role;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }

  void updateMembership(String membership, DateTime? dueDate) {
    if (_user == null) return;

    _user = UserModel(
      uid: _user!.uid,
      name: _user!.name,
      lastname: _user!.lastname,
      username: _user!.username,
      email: _user!.email,
      birthdate: _user!.birthdate,
      role: _user!.role,
      membership: membership,
      membershipDueDate: dueDate,
    );

    notifyListeners();
  }
}
