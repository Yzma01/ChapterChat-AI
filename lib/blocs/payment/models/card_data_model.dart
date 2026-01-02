class CardData {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;

  CardData({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
  });

  int get length => cardNumber.length;
}
