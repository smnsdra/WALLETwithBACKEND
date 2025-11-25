import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'storage.dart';
import 'add_transaction_screen.dart';
import 'summary_card.dart';
import 'transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WalletTransaction> _txs = [];
  final _cashCtrl = TextEditingController();
  final _savedCtrl = TextEditingController();
  final _debtCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _cashCtrl.text = Storage.getCash().toStringAsFixed(2);
    _savedCtrl.text = Storage.getSaved().toStringAsFixed(2);
    _debtCtrl.text = Storage.getDebt().toStringAsFixed(2);
  }

  void _load() {
    final loaded = Storage.loadTransactions();
    setState(() => _txs = loaded);
    _cashCtrl.text = Storage.getCash().toStringAsFixed(2);
    _savedCtrl.text = Storage.getSaved().toStringAsFixed(2);
    _debtCtrl.text = Storage.getDebt().toStringAsFixed(2);
  }

  void _onAdd() async {
    await Navigator.pushNamed(context, AddTransactionScreen.routeName);
    _load();
  }

  void _delete(int id) async {
    await Storage.deleteTransaction(id);
    _load();
  }

  double get income =>
      _txs.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);
  double get expenses =>
      _txs.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);
  double get saved => Storage.getSaved();
  double get cash => Storage.getCash();
  double get debt => Storage.getDebt();
  double get resources => Storage.getResources();

  String formatCurrency(double n) {
    final sign = n < 0 ? '-' : '';
    final absn = n.abs();
    return '$sign\$${absn.toStringAsFixed(2)}';
  }

  void _saveBalances() {
    final c = double.tryParse(_cashCtrl.text) ?? Storage.getCash();
    final s = double.tryParse(_savedCtrl.text) ?? Storage.getSaved();
    final d = double.tryParse(_debtCtrl.text) ?? Storage.getDebt();
    Storage.setCash(c);
    Storage.setSaved(s);
    Storage.setDebt(d);
    setState(() {});
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    _savedCtrl.dispose();
    _debtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Wallet'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Editable cash, saved and debt fields
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cashCtrl,
                        keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Cash',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _savedCtrl,
                        keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Saved',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _debtCtrl,
                        keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Debt',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(onPressed: _saveBalances, child: Text('Save')),
                  ],
                ),
                SizedBox(height: 12),

                // Summary cards
                Row(
                  children: [
                    Expanded(
                        child: SummaryCard(
                          title: 'Resources',
                          value: formatCurrency(resources),
                          color: Colors.blueGrey,
                        )),
                    SizedBox(width: 8),
                    Expanded(
                        child: SummaryCard(
                          title: 'Cash',
                          value: formatCurrency(cash),
                          color: Colors.teal,
                        )),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: SummaryCard(
                          title: 'Income',
                          value: formatCurrency(income),
                          color: Colors.green,
                        )),
                    SizedBox(width: 8),
                    Expanded(
                        child: SummaryCard(
                          title: 'Expenses',
                          value: formatCurrency(expenses),
                          color: Colors.redAccent,
                        )),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: SummaryCard(
                          title: 'Saved',
                          value: formatCurrency(saved),
                          color: Colors.indigo,
                        )),
                    Expanded(
                        child: SummaryCard(
                          title: 'Debt',
                          value: formatCurrency(debt),
                          color: Colors.deepOrange,
                        )),
                  ],
                ),
                SizedBox(height: 16),

                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Transactions',
                        style: Theme.of(context).textTheme.titleLarge)),
                SizedBox(height: 8),
                _txs.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No transactions yet. Tap + to add.'),
                    ],
                  ),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _txs.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (ctx, i) {
                    final t = _txs[i];
                    return TransactionTile(
                      transaction: t,
                      onDelete: () => _delete(t.id),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: Icon(Icons.add),
      ),
    );
  }
}