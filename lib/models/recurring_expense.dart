class RecurringExpense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String frequency; // weekly, monthly, yearly
  final String startDate; // YYYY-MM-DD
  final String nextDueDate; // YYYY-MM-DD
  final String paymentMethod;
  final bool autoLogExpense;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  RecurringExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    required this.paymentMethod,
    this.autoLogExpense = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'start_date': startDate,
      'next_due_date': nextDueDate,
      'payment_method': paymentMethod,
      'auto_log_expense': autoLogExpense ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      frequency: map['frequency'] as String,
      startDate: map['start_date'] as String,
      nextDueDate: map['next_due_date'] as String,
      paymentMethod: map['payment_method'] as String,
      autoLogExpense: (map['auto_log_expense'] as int?) == 1,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  RecurringExpense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? frequency,
    String? startDate,
    String? nextDueDate,
    String? paymentMethod,
    bool? autoLogExpense,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      autoLogExpense: autoLogExpense ?? this.autoLogExpense,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
