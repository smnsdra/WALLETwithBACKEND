import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'storage.dart';

class AddTransactionScreen extends StatefulWidget {
  static const routeName = '/add';
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  String _type = 'income';
  String _category = 'General';
  String _note = '';
  DateTime _date = DateTime.now();

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final amount = double.parse(_amountCtrl.text);

    final tx = WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch,
      amount: amount,
      type: _type,
      category: _category,
      note: _note,
      date: _date,
      // applied fields will be computed by Storage.addTransaction
      appliedCash: 0.0,
      appliedSaved: 0.0,
      appliedDebt: 0.0,
    );

    await Storage.addTransaction(tx);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  String formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // amount input as text field
              TextFormField(
                controller: _amountCtrl,
                decoration: InputDecoration(labelText: 'Amount', prefixText: '\$'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                  final n = double.tryParse(v);
                  if (n == null) return 'Enter valid number';
                  if (n <= 0) return 'Amount must be positive';
                  return null;
                },
              ),
              SizedBox(height: 8),

              // type and category
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _type,
                      onChanged: (v) => setState(() => _type = v!),
                      items: [
                        DropdownMenuItem(value: 'income', child: Text('Income')),
                        DropdownMenuItem(value: 'expense', child: Text('Expense')),
                      ],
                      decoration: InputDecoration(labelText: 'Type'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: _category,
                      decoration: InputDecoration(labelText: 'Category'),
                      onSaved: (v) => _category = v ?? 'General',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // note
              TextFormField(
                decoration: InputDecoration(labelText: 'Note'),
                onSaved: (v) => _note = v ?? '',
              ),
              SizedBox(height: 8),

              // date shown
              Row(
                children: [
                  Text('Date: ${formatDate(_date)}'),
                  SizedBox(width: 12),
                  TextButton(onPressed: _pickDate, child: Text('Pick')),
                ],
              ),

              SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: Text('Save'))
            ],
          ),
        ),
      ),
    );
  }
}