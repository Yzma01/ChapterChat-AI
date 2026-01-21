class TransactionModel {
  String bookId;
  String paymentId;
  int lastFourDigits;
  double amount;
  DateTime date;
  String userId;

  TransactionModel({
    required this.bookId,
    required this.lastFourDigits,
    required this.paymentId,
    required this.amount,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'paymentId': paymentId,
      'lastFourDigits': lastFourDigits,
      'userId': userId,
      'createdAt': DateTime.now(),
    };
  }
}
