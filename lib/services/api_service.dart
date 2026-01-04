import 'dart:convert';
import 'package:http/http.dart' as http;
import '../transaction_model.dart';

class ApiService {
  static const String baseUrl = 'http://ywn.atwebpages.com';

  // ================= TRANSACTIONS =================
  static Future<List<WalletTransaction>> getTransactions() async {
    final res = await http.get(
      Uri.parse('$baseUrl/get_transactions.php'),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP error');
    }

    final decoded = json.decode(res.body);

    if (decoded is! List) {
      throw Exception('Response is not a List');
    }

    return decoded
        .map<WalletTransaction>((e) => WalletTransaction.fromJson(e))
        .toList();
  }



  static Future<void> addTransaction(WalletTransaction tx) async {
    final res = await http.post(
      Uri.parse('$baseUrl/add_transaction.php'),
      body: {
        'amount': tx.amount.toString(),
        'type': tx.type,
        'category': tx.category,
        'note': tx.note,
        'date': tx.date.toIso8601String().split('T')[0],
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to add transaction');
    }
  }
  static Future<void> deleteTransaction(int id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/delete_transaction.php'),
      body: {'id': id.toString()},
    );

    final data = json.decode(res.body);

    if (res.statusCode != 200 || data['status'] != 'ok') {
      throw Exception('Failed to delete transaction');
    }
  }

  // ================= BALANCES =================
  static Future<Map<String, double>> getBalances() async {
    final res = await http.get(
      Uri.parse('$baseUrl/get_balances.php'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load balances');
    }

    final data = json.decode(res.body);
    return {
      'cash': double.parse(data['cash'].toString()),
      'saved': double.parse(data['saved'].toString()),
      'debt': double.parse(data['debt'].toString()),
    };
  }

  static Future<void> updateBalances({
    required double cash,
    required double saved,
    required double debt,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/update_balances.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'cash': cash.toString(),
        'saved': saved.toString(),
        'debt': debt.toString(),
      },
    );

    final data = json.decode(res.body);
    if (res.statusCode != 200 || data['status'] != 'ok') {
      throw Exception('Failed to update balances');
    }
  }
}
