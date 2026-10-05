class ImportantDate {
  final String id;
  final String title;
  final String date; // YYYY-MM-DD
  final String? time; // HH:mm
  final String category;
  final String? notes;
  final String reminder;
  final int createdAt;
  final int updatedAt;

  ImportantDate({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    required this.category,
    this.notes,
    this.reminder = '1d',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'category': category,
      'notes': notes,
      'reminder': reminder,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ImportantDate.fromMap(Map<String, dynamic> map) {
    return ImportantDate(
      id: map['id'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      time: map['time'] as String?,
      category: map['category'] as String,
      notes: map['notes'] as String?,
      reminder: map['reminder'] as String? ?? '1d',
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  ImportantDate copyWith({
    String? id,
    String? title,
    String? date,
    String? time,
    String? category,
    String? notes,
    String? reminder,
    int? createdAt,
    int? updatedAt,
  }) {
    return ImportantDate(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
