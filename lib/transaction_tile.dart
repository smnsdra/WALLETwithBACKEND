import 'package:flutter/material.dart';
import 'transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;
  final VoidCallback onDelete;

  const TransactionTile({
    required this.transaction,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';

    return ListTile(
      title: Text(transaction.category),
      subtitle: Text(
        '${transaction.date.toString().split(' ')[0]} — ${transaction.note}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
