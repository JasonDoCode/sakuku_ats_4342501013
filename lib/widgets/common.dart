import 'package:flutter/material.dart';

import '../theme.dart';
import '../models/transaction.dart';

String rupiah(int value) {
  final digits = value.abs().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '${value < 0 ? '-' : ''}Rp $digits';
}

const months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];
IconData categoryIcon(String category) => switch (category) {
  'Makanan' => Icons.restaurant_rounded,
  'Transportasi' => Icons.directions_bus_rounded,
  'Belanja' => Icons.shopping_bag_outlined,
  'Hiburan' => Icons.headphones_rounded,
  'Tagihan' => Icons.receipt_long_outlined,
  'Gaji' || 'Freelance' => Icons.work_outline_rounded,
  'Uang saku' => Icons.savings_outlined,
  _ => Icons.wallet_outlined,
};

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 60, this.light = false});
  final double size;
  final bool light;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: light ? const Color(0xFFD9EFB1) : green,
      borderRadius: BorderRadius.circular(size * .3),
    ),
    child: Icon(
      Icons.account_balance_wallet_rounded,
      color: light ? green : Colors.white,
      size: size * .52,
    ),
  );
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: Color(0xFFE6EBE5)),
    ),
    child: Padding(padding: padding, child: child),
  );
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: child,
    ),
  );
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: index,
    backgroundColor: Colors.white,
    indicatorColor: const Color(0xFFE0EEDC),
    onDestinationSelected: (value) {
      if (value == 1) {
        Navigator.pushNamed(context, '/add');
      } else if (value != index) {
        Navigator.pushReplacementNamed(
          context,
          value == 0 ? '/dashboard' : '/history',
        );
      }
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.grid_view_outlined),
        selectedIcon: Icon(Icons.grid_view_rounded),
        label: 'Beranda',
      ),
      NavigationDestination(
        icon: Icon(Icons.add_circle_outline_rounded),
        label: 'Tambah',
      ),
      NavigationDestination(
        icon: Icon(Icons.history_rounded),
        label: 'Riwayat',
      ),
    ],
  );
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onTap});
  final MoneyTransaction transaction;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final color = t.isIncome ? green : expenseColor;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(categoryIcon(t.category), color: color, size: 21),
      ),
      title: Text(
        t.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        t.category,
        style: const TextStyle(fontSize: 11, color: muted),
      ),
      trailing: Text(
        '${t.isIncome ? '+' : '-'}${rupiah(t.amount)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class EmptyTransactions extends StatelessWidget {
  const EmptyTransactions({super.key, this.filtered = false});
  final bool filtered;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Column(
      children: [
        const Icon(Icons.receipt_long_outlined, size: 48, color: muted),
        const SizedBox(height: 14),
        Text(
          filtered ? 'Transaksi tidak ditemukan' : 'Belum ada transaksi',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          filtered
              ? 'Pilih filter lain.'
              : 'Tekan Tambah untuk mencatat transaksi.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted),
        ),
      ],
    ),
  );
}
