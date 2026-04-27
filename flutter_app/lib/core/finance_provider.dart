import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modelos do Aplicativo
class FinanceTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isExpense;

  FinanceTransaction({required this.id, required this.title, required this.amount, required this.date, required this.isExpense});

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'amount': amount, 'date': date.toIso8601String(), 'isExpense': isExpense
  };

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) => FinanceTransaction(
    id: json['id'], title: json['title'], amount: json['amount'], date: DateTime.parse(json['date']), isExpense: json['isExpense']
  );
}

class DebtLoan {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isDebt;
  bool isPaid;

  DebtLoan({required this.id, required this.title, required this.amount, required this.date, required this.isDebt, this.isPaid = false});

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'amount': amount, 'date': date.toIso8601String(), 'isDebt': isDebt, 'isPaid': isPaid
  };

  factory DebtLoan.fromJson(Map<String, dynamic> json) => DebtLoan(
    id: json['id'], title: json['title'], amount: json['amount'], date: DateTime.parse(json['date']), isDebt: json['isDebt'], isPaid: json['isPaid']
  );
}

// Provider de Estado Global com SharedPreferences (Sincronização Local)
class FinanceProvider extends ChangeNotifier {
  List<FinanceTransaction> _transactions = [];
  List<DebtLoan> _debtsLoans = [];

  List<FinanceTransaction> get transactions => _transactions;
  List<DebtLoan> get debtsLoans => _debtsLoans;

  double get totalBalance {
    double exp = _transactions.where((t) => t.isExpense).fold(0, (sum, t) => sum + t.amount);
    double inc = _transactions.where((t) => !t.isExpense).fold(0, (sum, t) => sum + t.amount);
    return inc - exp;
  }

  double get totalUnpaidDebts => _debtsLoans.where((d) => d.isDebt && !d.isPaid).fold(0, (sum, d) => sum + d.amount);
  double get totalUnpaidLoans => _debtsLoans.where((d) => !d.isDebt && !d.isPaid).fold(0, (sum, d) => sum + d.amount);

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trStr = prefs.getString('transactions');
      final dlStr = prefs.getString('debtsLoans');

      if (trStr != null) {
        Iterable l = json.decode(trStr);
        _transactions = List<FinanceTransaction>.from(l.map((model) => FinanceTransaction.fromJson(model)));
      }
      if (dlStr != null) {
        Iterable l = json.decode(dlStr);
        _debtsLoans = List<DebtLoan>.from(l.map((model) => DebtLoan.fromJson(model)));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar dados locais: \$e');
    }
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(_transactions.map((t) => t.toJson()).toList()));
      await prefs.setString('debtsLoans', json.encode(_debtsLoans.map((d) => d.toJson()).toList()));
    } catch (e) {
      debugPrint('Erro ao salvar dados locais: \$e');
    }
  }

  void addTransaction(FinanceTransaction transaction) {
    _transactions.add(transaction);
    saveData();
    notifyListeners();
  }

  void addDebtLoan(DebtLoan debtLoan) {
    _debtsLoans.add(debtLoan);
    saveData();
    notifyListeners();
  }

  void togglePaidStatus(String id) {
    final idx = _debtsLoans.indexWhere((element) => element.id == id);
    if (idx != -1) {
      _debtsLoans[idx].isPaid = !_debtsLoans[idx].isPaid;
      saveData();
      notifyListeners();
    }
  }
}
