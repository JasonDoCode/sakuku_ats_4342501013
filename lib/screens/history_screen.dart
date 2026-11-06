import 'package:flutter/material.dart';

import '../data/sakuku_store.dart';
import '../models/transaction.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filter = 0;

  void _details(MoneyTransaction transaction) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}${rupiah(transaction.amount)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: transaction.isIncome ? green : expenseColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(transaction.category, style: const TextStyle(color: muted)),
            if (transaction.note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(transaction.note),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = SakukuScope.of(context);
    final transactions = store.transactions
        .where((t) => _filter == 0 || (_filter == 1 ? t.isIncome : !t.isIncome))
        .toList();
    final total = transactions.fold<int>(
      0,
      (sum, t) => sum + (t.isIncome ? t.amount : -t.amount),
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Riwayat transaksi'),
        actions: [
          IconButton(
            tooltip: 'Tambah transaksi',
            onPressed: () => Navigator.pushNamed(context, '/add'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const MainNavigation(index: 2),
      body: SafeArea(
        child: PageBody(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: ['Semua', 'Pemasukan', 'Pengeluaran']
                            .asMap()
                            .entries
                            .map(
                              (e) => ChoiceChip(
                                label: Text(e.value),
                                selected: _filter == e.key,
                                onSelected: (_) =>
                                    setState(() => _filter = e.key),
                                showCheckmark: false,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      Surface(
                        child: Row(
                          children: [
                            const Icon(Icons.swap_vert_rounded, color: green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${transactions.length} transaksi ditampilkan',
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  FittedBox(
                                    child: Text(
                                      rupiah(total),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 21,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ketuk transaksi untuk melihat detail.',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (transactions.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyTransactions(filtered: _filter != 0),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) => TransactionTile(
                      transaction: transactions[index],
                      onTap: () => _details(transactions[index]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
