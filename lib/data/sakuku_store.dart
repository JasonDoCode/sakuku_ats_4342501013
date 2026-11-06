import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

class SakukuStore extends ChangeNotifier {
  static const loginEmail = '123@gmail.com';
  static const loginPassword = '123';
  static const monthlyBudget = 1500000;
  static const _key = 'sakuku_transactions_v1';
  List<MoneyTransaction> _transactions = [];
  List<MoneyTransaction> get transactions {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  int get income => _sum(_transactions.where((t) => t.isIncome));
  int get expense => _sum(_transactions.where((t) => !t.isIncome));
  int get balance => income - expense;
  int get monthlyExpense {
    final now = DateTime.now();
    return _sum(
      _transactions.where(
        (t) =>
            !t.isIncome && t.date.month == now.month && t.date.year == now.year,
      ),
    );
  }

  int _sum(Iterable<MoneyTransaction> items) =>
      items.fold(0, (sum, t) => sum + t.amount);
  Future<String?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved == null) {
        final now = DateTime.now();
        // Data dummy disiapkan hanya jika belum ada data tersimpan.
        _transactions = [
          MoneyTransaction(
            id: 'demo-1',
            title: 'Uang bulanan',
            amount: 2500000,
            category: 'Uang saku',
            date: DateTime(now.year, now.month, 1),
            isIncome: true,
          ),
          MoneyTransaction(
            id: 'demo-2',
            title: 'Makan siang',
            amount: 25000,
            category: 'Makanan',
            date: now,
            isIncome: false,
            note: 'Nasi ayam favorit',
          ),
          MoneyTransaction(
            id: 'demo-3',
            title: 'Bensin motor',
            amount: 35000,
            category: 'Transportasi',
            date: now.subtract(const Duration(days: 1)),
            isIncome: false,
          ),
          MoneyTransaction(
            id: 'demo-4',
            title: 'Belanja kebutuhan',
            amount: 140000,
            category: 'Belanja',
            date: now.subtract(const Duration(days: 2)),
            isIncome: false,
          ),
          MoneyTransaction(
            id: 'demo-5',
            title: 'Proyek desain',
            amount: 350000,
            category: 'Freelance',
            date: now.subtract(const Duration(days: 3)),
            isIncome: true,
          ),
        ];
        final success = await prefs.setString(
          _key,
          jsonEncode(_transactions.map((t) => t.toJson()).toList()),
        );
        if (!success) throw Exception('Penyimpanan gagal');
      } else {
        _transactions = (jsonDecode(saved) as List)
            .map((e) => MoneyTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      notifyListeners();
      return null;
    } catch (_) {
      return 'Data lokal tidak dapat dibaca atau disimpan.';
    }
  }

  Future<void> _save(List<MoneyTransaction> next) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setString(
      _key,
      jsonEncode(next.map((t) => t.toJson()).toList()),
    );
    if (!success) throw Exception('Penyimpanan gagal');
    // Tampilan berubah setelah penyimpanan berhasil.
    _transactions = next;
    notifyListeners();
  }

  Future<void> add(MoneyTransaction transaction) =>
      _save([..._transactions, transaction]);
}

class SakukuScope extends InheritedNotifier<SakukuStore> {
  const SakukuScope({
    super.key,
    required SakukuStore store,
    required super.child,
  }) : super(notifier: store);
  static SakukuStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SakukuScope>()!.notifier!;
}
