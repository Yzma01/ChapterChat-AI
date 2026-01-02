import 'dart:math';

import 'package:chapter_chat_ai/blocs/payment/models/card_data_model.dart';
import 'package:chapter_chat_ai/blocs/payment/models/payment_model.dart';
import 'package:chapter_chat_ai/blocs/payment/models/transaction_model.dart';
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

  Future<void> saveTransaction(String id, Book book, CardData card) async {
    try {
      String uid = _auth.currentUser!.uid;
      TransactionModel transaction = TransactionModel(
        bookId: book.id,
        lastFourDigits: int.parse(card.cardNumber.substring(card.length - 4)),
        paymentId: id,
        userId: uid,
      );
      _firestore.collection("transactions").add(transaction.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Failed to save transaction data: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
