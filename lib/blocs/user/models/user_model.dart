import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String lastname;
  final String username;
  final String email;
  final DateTime birthdate;
  final String role;
  final String membership;
  final DateTime? membershipDueDate;

  UserModel({
    required this.uid,
    required this.name,
    required this.lastname,
    required this.username,
    required this.email,
    required this.birthdate,
    required this.role,
    this.membership = 'free',
    this.membershipDueDate,
  });

  bool get isPremium {
    if (membership != 'premium') return false;
    if (membershipDueDate == null) return true;
    return membershipDueDate!.isAfter(DateTime.now());
  }

  bool get isWritter {
    return role == 'writer';
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      lastname: data['lastname'],
      username: data['username'],
      email: data['email'],
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      role: data['role'],
      membership: data['membership'] ?? 'free',
      membershipDueDate:
          data['membershipDueDate'] != null
              ? (data['membershipDueDate'] as Timestamp).toDate()
              : null,
    );
  }
}
