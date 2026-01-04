import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'services/api_service.dart';

class AddTransactionScreen extends StatefulWidget {
  static const routeName = '/add';

  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();

  String _type = 'income';
  String _category = 'General';
  String _note = '';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final amount = double.parse(_amountCtrl.text);

    final tx = WalletTransaction(
      id: 0,
      amount: amount,
      type: _type,
      category: _category,
      note: _note,
      date: _date,
    );

    await ApiService.addTransaction(tx);

    final balances = await ApiService.getBalances();
    double cash = balances['cash']!;

    if (_type == 'income') {
      cash += amount;
    } else {
      cash -= amount;
    }

    await ApiService.updateBalances(
      cash: cash,
      saved: balances['saved']!,
      debt: balances['debt']!,
    );

    if (mounted) Navigator.pop(context);
  }


  String formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter amount';
                  }
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) {
                    return 'Enter valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 8),

              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                onSaved: (v) => _category = v ?? 'General',
              ),
              const SizedBox(height: 8),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Note'),
                onSaved: (v) => _note = v ?? '',
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Text('Date: ${formatDate(_date)}'),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pick'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
