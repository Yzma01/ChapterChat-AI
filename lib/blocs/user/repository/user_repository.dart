import 'package:chapter_chat_ai/blocs/user/models/user_model.dart';
import 'package:chapter_chat_ai/core/user/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<UserModel> getProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('User profile does not exist');
    }

    UserModel userModel = UserModel.fromFirestore(doc.data()!);

    if (userModel.membership == 'premium' &&
        userModel.membershipDueDate != null &&
        userModel.membershipDueDate!.isBefore(DateTime.now())) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'membership': 'free', 'membershipDueDate': null},
      );
      final refreshedDoc =
          await _firestore.collection('users').doc(user.uid).get();

      userModel = UserModel.fromFirestore(refreshedDoc.data()!);
    }
    return userModel;
  }
}
