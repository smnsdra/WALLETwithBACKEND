// WalletTransaction model used by the app.
// Includes appliedCash/appliedSaved/appliedDebt so we can correctly reverse effects.
class WalletTransaction {
  final int id; // timestamp millis
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String note;
  final DateTime date;

  // How the transaction was actually applied to balances:
  final double appliedCash;
  final double appliedSaved;
  final double appliedDebt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.date,
    this.appliedCash = 0.0,
    this.appliedSaved = 0.0,
    this.appliedDebt = 0.0,
  });

  WalletTransaction copyWith({
    int? id,
    double? amount,
    String? type,
    String? category,
    String? note,
    DateTime? date,
    double? appliedCash,
    double? appliedSaved,
    double? appliedDebt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      appliedCash: appliedCash ?? this.appliedCash,
      appliedSaved: appliedSaved ?? this.appliedSaved,
      appliedDebt: appliedDebt ?? this.appliedDebt,
    );
  }

  @override
  String toString() {
    return 'WalletTransaction(id:$id amount:$amount type:$type appliedCash:$appliedCash appliedSaved:$appliedSaved appliedDebt:$appliedDebt)';
  }
}