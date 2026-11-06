import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/sakuku_store.dart';
import '../models/transaction.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _income = false;
  bool _saving = false;
  String? _category;
  List<String> get _categories => _income
      ? ['Uang saku', 'Gaji', 'Freelance', 'Lainnya']
      : ['Makanan', 'Transportasi', 'Belanja', 'Hiburan', 'Tagihan', 'Lainnya'];
  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    final store = SakukuScope.of(context);
    setState(() => _saving = true);
    try {
      await store.add(
        MoneyTransaction(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: _title.text.trim(),
          amount: int.parse(_amount.text),
          category: _category!,
          date: DateTime.now(),
          isIncome: _income,
          note: _note.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan.')),
      );
    } catch (_) {
      // Kegagalan penyimpanan diberi pesan agar aplikasi tidak tertutup paksa.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi belum tersimpan. Silakan coba lagi.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(title: const Text('Tambah transaksi')),
      body: SafeArea(
        child: PageBody(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Pengeluaran'),
                        icon: Icon(Icons.north_east_rounded),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Pemasukan'),
                        icon: Icon(Icons.south_west_rounded),
                      ),
                    ],
                    selected: {_income},
                    showSelectedIcon: false,
                    onSelectionChanged: _saving
                        ? null
                        : (values) => setState(() {
                            _income = values.first;
                            _category = null;
                          }),
                  ),
                  const SizedBox(height: 26),
                  TextFormField(
                    controller: _amount,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: green,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp ',
                      hintText: '0',
                      helperText: 'Masukkan angka tanpa titik atau koma.',
                    ),
                    validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                        ? 'Nominal harus lebih besar dari 0.'
                        : null,
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _title,
                    enabled: !_saving,
                    maxLength: 50,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nama transaksi',
                      hintText: 'Contoh: Makan siang',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama transaksi wajib diisi.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_income),
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _category = value),
                    validator: (v) =>
                        v == null ? 'Pilih kategori transaksi.' : null,
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _note,
                    enabled: !_saving,
                    maxLength: 150,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        _saving ? 'Menyimpan...' : 'Simpan transaksi',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
