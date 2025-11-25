// lib/storage.dart
import 'transaction_model.dart';

/// In-memory storage with balances and transaction history.
/// Expense consumption order: cash -> saved -> debt
/// Defensive: clamps small negative results to zero and logs actions.
class Storage {
  static final List<WalletTransaction> _list = [];

  static double cash = 0.0;
  static double saved = 0.0;
  static double debt = 0.0;

  static List<WalletTransaction> loadTransactions() {
    return List<WalletTransaction>.from(_list);
  }

  static double getCash() => cash;
  static double getSaved() => saved;
  static double getDebt() => debt;
  static double getResources() => cash + saved;

  static Future<void> setCash(double v) async {
    cash = v;
    _clamp();
    print('[Storage] setCash -> $cash');
  }

  static Future<void> setSaved(double v) async {
    saved = v;
    _clamp();
    print('[Storage] setSaved -> $saved');
  }

  static Future<void> setDebt(double v) async {
    debt = v;
    _clamp();
    print('[Storage] setDebt -> $debt');
  }

  static void _clamp() {
    // avoid tiny negative floats
    if (cash.abs() < 0.000001) cash = 0.0;
    if (saved.abs() < 0.000001) saved = 0.0;
    if (debt.abs() < 0.000001) debt = 0.0;
  }

  /// Adds a transaction and updates balances.
  /// Returns the stored WalletTransaction (with applied fields set).
  static Future<WalletTransaction> addTransaction(WalletTransaction t) async {
    final type = t.type.toLowerCase();
    final amount = t.amount;
    double appliedCash = 0.0;
    double appliedSaved = 0.0;
    double appliedDebt = 0.0;

    print('[Storage] ADD starting: type=$type amount=$amount  BEFORE cash=$cash saved=$saved debt=$debt');

    if (amount.isNaN || amount <= 0) {
      print('[Storage] ADD aborted: invalid amount $amount');
      return t;
    }

    if (type == 'income') {
      final savedPart = (amount * 0.10);
      final cashPart = amount - savedPart;
      appliedSaved = savedPart;
      appliedCash = cashPart;
      // update balances using Storage.* fields directly
      saved += appliedSaved;
      cash += appliedCash;
      print('[Storage] income applied -> cash+=$appliedCash saved+=$appliedSaved');
    } else if (type == 'expense') {
      var remaining = amount;

      // 1) consume cash
      if (cash > 0) {
        appliedCash = remaining <= cash ? remaining : cash;
        cash -= appliedCash;
        remaining -= appliedCash;
      }

      // 2) consume saved (IMPORTANT: operate on Storage.saved)
      if (remaining > 0 && saved > 0) {
        appliedSaved = remaining <= saved ? remaining : saved;
        saved -= appliedSaved;
        remaining -= appliedSaved;
      }

      // 3) remaining -> debt
      if (remaining > 0) {
        appliedDebt = remaining;
        debt += appliedDebt;
        remaining = 0;
      }

      print('[Storage] expense applied -> cash-=$appliedCash saved-=$appliedSaved debt+=$appliedDebt');
    } else {
      print('[Storage] unknown transaction type "$type" - no balance change');
    }

    _clamp();

    final stored = t.copyWith(
      appliedCash: appliedCash,
      appliedSaved: appliedSaved,
      appliedDebt: appliedDebt,
    );

    _list.insert(0, stored);

    print('[Storage] ADD done: AFTER cash=$cash saved=$saved debt=$debt totalTxs=${_list.length}');
    return stored;
  }

  /// Deletes transaction and reverses its effect on balances.
  static Future<void> deleteTransaction(int id) async {
    final idx = _list.indexWhere((t) => t.id == id);
    if (idx == -1) {
      print('[Storage] deleteTransaction: id=$id not found');
      return;
    }
    final t = _list.removeAt(idx);

    print('[Storage] DELETE starting: id=${t.id} appliedCash=${t.appliedCash} appliedSaved=${t.appliedSaved} appliedDebt=${t.appliedDebt}  BEFORE cash=$cash saved=$saved debt=$debt');

    // reverse applied values
    cash += t.appliedCash;
    saved += t.appliedSaved;
    debt -= t.appliedDebt;
    if (debt < 0) debt = 0.0;

    _clamp();

    print('[Storage] DELETE done: AFTER cash=$cash saved=$saved debt=$debt totalTxs=${_list.length}');
  }

  static Future<void> saveTransactions(List<WalletTransaction> txs) async {
    _list
      ..clear()
      ..addAll(txs);
    print('[Storage] saveTransactions -> totalTxs=${_list.length}');
  }
}