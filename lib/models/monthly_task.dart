class MonthlyTask {
  final String id;
  final String title;
  final String monthYear; // YYYY-MM
  final bool completed;
  final int? completedAt;
  final String priority;
  final String? notes;
  final int createdAt;
  final int updatedAt;

  MonthlyTask({
    required this.id,
    required this.title,
    required this.monthYear,
    this.completed = false,
    this.completedAt,
    this.priority = 'medium',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'month_year': monthYear,
      'completed': completed ? 1 : 0,
      'completed_at': completedAt,
      'priority': priority,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MonthlyTask.fromMap(Map<String, dynamic> map) {
    return MonthlyTask(
      id: map['id'] as String,
      title: map['title'] as String,
      monthYear: map['month_year'] as String,
      completed: (map['completed'] as int) == 1,
      completedAt: map['completed_at'] as int?,
      priority: map['priority'] as String? ?? 'medium',
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  MonthlyTask copyWith({
    String? id,
    String? title,
    String? monthYear,
    bool? completed,
    int? completedAt,
    String? priority,
    String? notes,
    int? createdAt,
    int? updatedAt,
  }) {
    return MonthlyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      monthYear: monthYear ?? this.monthYear,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
