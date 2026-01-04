
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_transaction_screen.dart';

void main() {
  runApp(const SimpleWalletApp());
}

class SimpleWalletApp extends StatelessWidget {
  const SimpleWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Wallet',
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => HomeScreen(),
        AddTransactionScreen.routeName: (_) => const AddTransactionScreen(),
      },
    );
  }
}
