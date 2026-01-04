class WalletTransaction {
  final int id;
  final double amount;
  final String type;
  final String category;
  final String note;
  final DateTime date;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.date,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: int.parse(json['id'].toString()),
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
      category: json['category'],
      note: json['note'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }
}
