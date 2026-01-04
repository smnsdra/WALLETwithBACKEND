import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'add_transaction_screen.dart';
import 'transaction_model.dart';
import 'transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cashCtrl = TextEditingController();
  final _savedCtrl = TextEditingController();
  final _debtCtrl = TextEditingController();

  bool _loading = true;
  List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([
      _loadBalances(),
      _loadTransactions(),
    ]);
    setState(() => _loading = false);
  }

  // ================= BALANCES =================
  Future<void> _loadBalances() async {
    try {
      final balances = await ApiService.getBalances();
      _cashCtrl.text = balances['cash']!.toString();
      _savedCtrl.text = balances['saved']!.toString();
      _debtCtrl.text = balances['debt']!.toString();
    } catch (_) {
      _showSnack('Error loading balances');
    }
  }

  Future<void> _saveBalances() async {
    try {
      await ApiService.updateBalances(
        cash: double.tryParse(_cashCtrl.text) ?? 0,
        saved: double.tryParse(_savedCtrl.text) ?? 0,
        debt: double.tryParse(_debtCtrl.text) ?? 0,
      );
      _showSnack('Balances saved');
    } catch (e) {
      _showSnack('Error saving balances');
    }
  }

  // ================= TRANSACTIONS =================
  Future<void> _loadTransactions() async {
    try {
      final data = await ApiService.getTransactions();
      setState(() {
        _transactions = data;
      });
    } catch (e) {
      _showSnack('Error loading transactions');
    }
  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Wallet')),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // -------- BALANCES --------
            Row(
              children: [
                Expanded(child: _field('Cash', _cashCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _field('Saved', _savedCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _field('Debt', _debtCtrl)),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveBalances,
                  child: const Text('Save'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),

            // -------- TRANSACTIONS LIST --------
            if (_transactions.isEmpty)
              const Text('No transactions yet')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (ctx, i) {
                    final tx = _transactions[i];
                    return TransactionTile(
                      transaction: tx,
                      onDelete: () async {
                        try {
                          await ApiService.deleteTransaction(tx.id);
                          await _loadTransactions();
                          _showSnack('Transaction deleted');
                        } catch (e) {
                          _showSnack('Error deleting transaction');
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AddTransactionScreen.routeName);
          await _loadAll(); // يعيد تحميل balances + transactions
        },
        child: const Icon(Icons.add),
      ),


    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    _savedCtrl.dispose();
    _debtCtrl.dispose();
    super.dispose();
  }
}
