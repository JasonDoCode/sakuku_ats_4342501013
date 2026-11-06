class MoneyTransaction {
  const MoneyTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
    this.note = '',
  });
  final String id;
  final String title;
  final int amount;
  final String category;
  final DateTime date;
  final bool isIncome;
  final String note;
  // JSON digunakan untuk menyimpan transaksi ke perangkat.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'isIncome': isIncome,
    'note': note,
  };
  factory MoneyTransaction.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'] as int;
    if (amount <= 0) throw const FormatException('Nominal tidak valid');
    return MoneyTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: amount,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      isIncome: json['isIncome'] as bool,
      note: json['note'] as String? ?? '',
    );
  }
}
