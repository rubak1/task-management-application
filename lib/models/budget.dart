class MonthlyBudget {
  final String monthYear; // YYYY-MM
  final double amount;
  final String? notes;
  final int updatedAt;

  MonthlyBudget({
    required this.monthYear,
    required this.amount,
    this.notes,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'month_year': monthYear,
      'amount': amount,
      'notes': notes,
      'updated_at': updatedAt,
    };
  }

  factory MonthlyBudget.fromMap(Map<String, dynamic> map) {
    return MonthlyBudget(
      monthYear: map['month_year'] as String,
      amount: (map['amount'] as num).toDouble(),
      notes: map['notes'] as String?,
      updatedAt: map['updated_at'] as int,
    );
  }
}
