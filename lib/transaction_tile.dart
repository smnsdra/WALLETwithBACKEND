import 'package:flutter/material.dart';
import 'transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final WalletTransaction transaction;
  final VoidCallback onDelete;
  TransactionTile({required this.transaction, required this.onDelete});

  String formatCurrency(double n) {
    final sign = n < 0 ? '-' : '';
    final absn = n.abs();
    return '$sign\$${absn.toStringAsFixed(2)}';
  }

  String formatDateShort(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    final sign = transaction.type == 'income' ? '+' : '-';
    final color = transaction.type == 'income' ? Colors.green : Colors.redAccent;
    final details = [
      if (transaction.appliedCash > 0) 'cash ${formatCurrency(transaction.appliedCash)}',
      if (transaction.appliedSaved > 0) 'saved ${formatCurrency(transaction.appliedSaved)}',
      if (transaction.appliedDebt > 0) 'debt ${formatCurrency(transaction.appliedDebt)}',
    ].join(' • ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(
          transaction.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
      ),
      title: Text('${transaction.category}'),
      subtitle: Text('${formatDateShort(transaction.date)} — ${transaction.note}\n$details'),
      isThreeLine: details.isNotEmpty,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$sign${formatCurrency(transaction.amount)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}