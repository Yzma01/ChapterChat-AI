class MembershipTransactionModel {
  final String membershipId;
  final int lastFourDigits;
  final String paymentId;
  final DateTime date;
  final DateTime dueDate;
  final double amount;
  final String userId;

  MembershipTransactionModel({
    required this.membershipId,
    required this.lastFourDigits,
    required this.paymentId,
    required this.date,
    required this.dueDate,
    required this.amount,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'membershipId': membershipId,
      'lastFourDigits': lastFourDigits,
      'paymentId': paymentId,
      'date': date.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'amount': amount,
      'userId': userId,
    };
  }
}
