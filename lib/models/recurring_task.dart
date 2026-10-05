class RecurringTask {
  final String id;
  final String title;
  final String category;
  final String frequency; // daily, weekly, monthly, yearly, custom
  final int? customDays;
  final String priority;
  final String startDate; // YYYY-MM-DD
  final String nextDueDate; // YYYY-MM-DD
  final String? lastCompletedDate;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  RecurringTask({
    required this.id,
    required this.title,
    required this.category,
    required this.frequency,
    this.customDays,
    this.priority = 'medium',
    required this.startDate,
    required this.nextDueDate,
    this.lastCompletedDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'frequency': frequency,
      'custom_days': customDays,
      'priority': priority,
      'start_date': startDate,
      'next_due_date': nextDueDate,
      'last_completed_date': lastCompletedDate,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory RecurringTask.fromMap(Map<String, dynamic> map) {
    return RecurringTask(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      frequency: map['frequency'] as String,
      customDays: map['custom_days'] as int?,
      priority: map['priority'] as String? ?? 'medium',
      startDate: map['start_date'] as String,
      nextDueDate: map['next_due_date'] as String,
      lastCompletedDate: map['last_completed_date'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  RecurringTask copyWith({
    String? id,
    String? title,
    String? category,
    String? frequency,
    int? customDays,
    String? priority,
    String? startDate,
    String? nextDueDate,
    String? lastCompletedDate,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return RecurringTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
