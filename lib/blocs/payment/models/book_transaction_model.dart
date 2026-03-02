class BookTransactionModel {
  String bookId;
  String paymentId;
  int lastFourDigits;
  double amount;
  String userId;

  BookTransactionModel({
    required this.bookId,
    required this.lastFourDigits,
    required this.paymentId,
    required this.amount,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'lastFourDigits': lastFourDigits,
      'paymentId': paymentId,
      'amount': amount,
      'userId': userId,
      'createdAt': DateTime.now(),
    };
  }
}
