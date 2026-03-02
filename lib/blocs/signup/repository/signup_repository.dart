import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signup(
    String email,
    String password,
    String name,
    String username,
    String lastname,
    DateTime birthdate,
    String role,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "uid": user.uid,
          'name': name,
          'lastname': lastname,
          'username': username,
          'email': email,
          "birthdate": Timestamp.fromDate(birthdate),
          "role": role,
          'membership': 'free',
          'membershipDueDate': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Stream<User?> get userChanges => _auth.userChanges();
}
