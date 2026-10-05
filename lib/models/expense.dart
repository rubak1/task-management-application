class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String date; // YYYY-MM-DD
  final String time; // HH:mm
  final String paymentMethod;
  final String? notes;
  final int createdAt;
  final int updatedAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.time,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'time': time,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      paymentMethod: map['payment_method'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? date,
    String? time,
    String? paymentMethod,
    String? notes,
    int? createdAt,
    int? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
