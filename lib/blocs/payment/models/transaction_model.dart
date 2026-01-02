class TransactionModel {
  String bookId;
  String paymentId;
  int lastFourDigits;
  String userId;

  TransactionModel({
    required this.bookId,
    required this.lastFourDigits,
    required this.paymentId,
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
