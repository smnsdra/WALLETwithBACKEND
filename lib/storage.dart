import 'transaction_model.dart';

class Storage {
  static double cash = 0;
  static double saved = 0;
  static double debt = 0;

  static double getCash() => cash;
  static double getSaved() => saved;
  static double getDebt() => debt;
  static double getResources() => cash + saved;

  static Future<void> setCash(double v) async => cash = v;
  static Future<void> setSaved(double v) async => saved = v;
  static Future<void> setDebt(double v) async => debt = v;
}
