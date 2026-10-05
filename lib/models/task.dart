class TaskItem {
  final String id;
  final String title;
  final String? description;
  final String date; // YYYY-MM-DD
  final String? time; // HH:mm
  final String priority; // low, medium, high, urgent
  final String category;
  final String reminder; // none, at_time, 5m, 15m, 30m, 1h, 1d
  final bool completed;
  final int? completedAt;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;

  TaskItem({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.time,
    required this.priority,
    required this.category,
    this.reminder = 'none',
    this.completed = false,
    this.completedAt,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'priority': priority,
      'category': category,
      'reminder': reminder,
      'completed': completed ? 1 : 0,
      'completed_at': completedAt,
      'sort_order': sortOrder,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      date: map['date'] as String,
      time: map['time'] as String?,
      priority: map['priority'] as String? ?? 'medium',
      category: map['category'] as String? ?? 'Work',
      reminder: map['reminder'] as String? ?? 'none',
      completed: (map['completed'] as int) == 1,
      completedAt: map['completed_at'] as int?,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? priority,
    String? category,
    String? reminder,
    bool? completed,
    int? completedAt,
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      reminder: reminder ?? this.reminder,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
