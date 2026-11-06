import 'package:flutter/material.dart';

import '../data/sakuku_store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Sakuku?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = SakukuScope.of(context);
    final spent = store.monthlyExpense;
    final ratio = spent / SakukuStore.monthlyBudget;
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            BrandMark(size: 32),
            SizedBox(width: 10),
            Text(
              'sakuku',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: const MainNavigation(index: 0),
      body: SafeArea(
        child: PageBody(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Beranda', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [green, Color(0xFF0E4938)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo tersedia',
                          style: TextStyle(color: Color(0xFFD8E9DF)),
                        ),
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Color(0xFFD9EFB1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        rupiah(store.balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Summary(
                      label: 'Pemasukan',
                      amount: store.income,
                      income: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Summary(
                      label: 'Pengeluaran',
                      amount: store.expense,
                      income: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.pie_chart_outline_rounded,
                          color: green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Budget ${months[DateTime.now().month - 1]}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${(ratio * 100).round()}%',
                          style: TextStyle(
                            color: ratio > 1 ? expenseColor : green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFEDF1E8),
                        color: ratio > 1 ? expenseColor : green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${rupiah(spent)} dari ${rupiah(SakukuStore.monthlyBudget)}',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ratio > 1
                          ? 'Budget terlewati.'
                          : 'Sisa budget ${rupiah(SakukuStore.monthlyBudget - spent)}.',
                      style: TextStyle(
                        color: ratio > 1 ? expenseColor : green,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/add'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah transaksi'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Transaksi terbaru',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/history'),
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              Surface(
                padding: const EdgeInsets.all(12),
                child: store.transactions.isEmpty
                    ? const EmptyTransactions()
                    : Column(
                        children: store.transactions
                            .take(3)
                            .map((t) => TransactionTile(transaction: t))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.amount,
    required this.income,
  });
  final String label;
  final int amount;
  final bool income;
  @override
  Widget build(BuildContext context) => Surface(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          income ? Icons.south_west_rounded : Icons.north_east_rounded,
          color: income ? green : expenseColor,
          size: 21,
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            rupiah(amount),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: income ? green : expenseColor,
            ),
          ),
        ),
      ],
    ),
  );
}
