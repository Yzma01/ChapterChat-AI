import 'dart:math';

import 'package:chapter_chat_ai/blocs/payment/models/card_data_model.dart';
import 'package:chapter_chat_ai/blocs/payment/models/membership_transaction_model.dart';
import 'package:chapter_chat_ai/blocs/payment/models/payment_model.dart';
import 'package:chapter_chat_ai/blocs/payment/models/book_transaction_model.dart';
import 'package:chapter_chat_ai/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String generateTransactionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(3); // 10 digits
    final randomPart = random.nextInt(9999).toString().padLeft(4, '0');
    return '$timestamp$randomPart'; // 14 digits total
  }

  Future<PaymentModel> pay(CardData card) async {
    // 200 accepted
    // 400 bad requested
    // 401 unauthorized
    // 408 requested timeout
    // 444 no response
    try {
      List<int> codes = [200, 400, 401, 408, 444];
      final random = Random();
      int r = random.nextInt(10);
      int randomInt = random.nextInt(codes.length - 1) + 1;
      if (r < 9) randomInt = 0;
      String transactionID = generateTransactionId();
      return PaymentModel(code: codes.elementAt(randomInt), id: transactionID);
    } catch (e) {
      throw Exception('Failed to pay: ${e.toString()}');
    }
  }

  Future<void> saveBookTransaction(String id, Book book, CardData card) async {
    try {
      String uid = _auth.currentUser!.uid;
      BookTransactionModel transaction = BookTransactionModel(
        bookId: book.id,
        lastFourDigits: int.parse(card.cardNumber.substring(card.length - 4)),
        paymentId: id,
        amount: book.price!,
        userId: uid,
      );
      _firestore.collection("book_transactions").add(transaction.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to save transaction data: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveMembershipTransaction(
    String id,
    String membership,
    CardData card,
  ) async {
    try {
      String uid = _auth.currentUser!.uid;
      MembershipTransactionModel transaction = MembershipTransactionModel(
        membershipId: membership,
        lastFourDigits: int.parse(card.cardNumber.substring(card.length - 4)),
        paymentId: id,
        date: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)),
        amount: 9.99,
        userId: uid,
      );
      _firestore.collection("membership_transactions").add(transaction.toMap());
      _firestore.collection("users").doc(uid).update({
        'membership': membership,
        'membershipDueDate': transaction.dueDate,
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to save transaction data: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
