import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/expense.dart';
import '../models/task.dart';
import '../models/monthly_task.dart';
import '../models/important_date.dart';
import '../models/budget.dart';
import '../models/recurring_expense.dart';
import '../models/recurring_task.dart';
import '../models/app_settings.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aether_finance_tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 2. Tasks Table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT,
        priority TEXT NOT NULL,
        category TEXT NOT NULL,
        reminder TEXT NOT NULL,
        completed INTEGER NOT NULL,
        completed_at INTEGER,
        sort_order INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 3. Monthly Tasks Table
    await db.execute('''
      CREATE TABLE monthly_tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        month_year TEXT NOT NULL,
        completed INTEGER NOT NULL,
        completed_at INTEGER,
        priority TEXT NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 4. Important Dates Table
    await db.execute('''
      CREATE TABLE important_dates (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT,
        category TEXT NOT NULL,
        notes TEXT,
        reminder TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 5. Budgets Table
    await db.execute('''
      CREATE TABLE budgets (
        month_year TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        notes TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 6. Recurring Expenses Table
    await db.execute('''
      CREATE TABLE recurring_expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        start_date TEXT NOT NULL,
        next_due_date TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        auto_log_expense INTEGER NOT NULL,
        is_active INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 7. Recurring Tasks Table
    await db.execute('''
      CREATE TABLE recurring_tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        custom_days INTEGER,
        priority TEXT NOT NULL,
        start_date TEXT NOT NULL,
        next_due_date TEXT NOT NULL,
        last_completed_date TEXT,
        is_active INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 8. Custom Categories Table
    await db.execute('''
      CREATE TABLE custom_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // 9. Settings Table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Seed default categories into SQLite on first installation
    final defaultExpenseCategories = [
      'Food',
      'Travel',
      'Shopping',
      'Bills',
      'Groceries',
      'Entertainment',
      'Health',
      'Education',
      'Fuel',
      'Rent',
      'Subscriptions',
      'Electronics',
      'Other',
    ];
    for (final cat in defaultExpenseCategories) {
      await db.insert('custom_categories', {
        'id': 'exp_cat_${cat.toLowerCase().replaceAll(' ', '_')}',
        'name': cat,
        'type': 'expense',
      });
    }

    final defaultTaskCategories = [
      'Work',
      'Personal',
      'Study',
      'Health',
      'Finance',
      'Home',
      'Other',
    ];
    for (final cat in defaultTaskCategories) {
      await db.insert('custom_categories', {
        'id': 'task_cat_${cat.toLowerCase().replaceAll(' ', '_')}',
        'name': cat,
        'type': 'task',
      });
    }

    // Default settings
    final defaultSettings = AppSettings();
    for (final entry in defaultSettings.toMap().entries) {
      await db.insert('settings', {'key': entry.key, 'value': entry.value});
    }
  }

  // --- Expenses CRUD ---
  Future<void> insertExpense(Expense expense) async {
    final db = await instance.database;
    await db.insert('expenses', expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await instance.database;
    await db.update('expenses', expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> deleteExpense(String id) async {
    final db = await instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC, time DESC');
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // --- Tasks CRUD ---
  Future<void> insertTask(TaskItem task) async {
    final db = await instance.database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(TaskItem task) async {
    final db = await instance.database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TaskItem>> getAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks', orderBy: 'date ASC, time ASC');
    return result.map((json) => TaskItem.fromMap(json)).toList();
  }

  // --- Monthly Tasks CRUD ---
  Future<void> insertMonthlyTask(MonthlyTask task) async {
    final db = await instance.database;
    await db.insert('monthly_tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateMonthlyTask(MonthlyTask task) async {
    final db = await instance.database;
    await db.update('monthly_tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteMonthlyTask(String id) async {
    final db = await instance.database;
    await db.delete('monthly_tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MonthlyTask>> getAllMonthlyTasks() async {
    final db = await instance.database;
    final result = await db.query('monthly_tasks', orderBy: 'created_at DESC');
    return result.map((json) => MonthlyTask.fromMap(json)).toList();
  }

  // --- Important Dates CRUD ---
  Future<void> insertImportantDate(ImportantDate item) async {
    final db = await instance.database;
    await db.insert('important_dates', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateImportantDate(ImportantDate item) async {
    final db = await instance.database;
    await db.update('important_dates', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteImportantDate(String id) async {
    final db = await instance.database;
    await db.delete('important_dates', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ImportantDate>> getAllImportantDates() async {
    final db = await instance.database;
    final result = await db.query('important_dates', orderBy: 'date ASC');
    return result.map((json) => ImportantDate.fromMap(json)).toList();
  }

  // --- Budgets CRUD ---
  Future<void> setBudget(MonthlyBudget budget) async {
    final db = await instance.database;
    await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MonthlyBudget>> getAllBudgets() async {
    final db = await instance.database;
    final result = await db.query('budgets');
    return result.map((json) => MonthlyBudget.fromMap(json)).toList();
  }

  // --- Recurring Expenses CRUD ---
  Future<void> insertRecurringExpense(RecurringExpense item) async {
    final db = await instance.database;
    await db.insert('recurring_expenses', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRecurringExpense(RecurringExpense item) async {
    final db = await instance.database;
    await db.update('recurring_expenses', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteRecurringExpense(String id) async {
    final db = await instance.database;
    await db.delete('recurring_expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RecurringExpense>> getAllRecurringExpenses() async {
    final db = await instance.database;
    final result = await db.query('recurring_expenses', orderBy: 'next_due_date ASC');
    return result.map((json) => RecurringExpense.fromMap(json)).toList();
  }

  // --- Recurring Tasks CRUD ---
  Future<void> insertRecurringTask(RecurringTask item) async {
    final db = await instance.database;
    await db.insert('recurring_tasks', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRecurringTask(RecurringTask item) async {
    final db = await instance.database;
    await db.update('recurring_tasks', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteRecurringTask(String id) async {
    final db = await instance.database;
    await db.delete('recurring_tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RecurringTask>> getAllRecurringTasks() async {
    final db = await instance.database;
    final result = await db.query('recurring_tasks', orderBy: 'next_due_date ASC');
    return result.map((json) => RecurringTask.fromMap(json)).toList();
  }

  // --- Custom Categories CRUD ---
  Future<void> insertCategory(String name, String type) async {
    final db = await instance.database;
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    await db.insert('custom_categories', {
      'id': id,
      'name': name.trim(),
      'type': type,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> deleteCategory(String name, String type) async {
    final db = await instance.database;
    await db.delete('custom_categories', where: 'name = ? AND type = ?', whereArgs: [name, type]);
  }

  Future<List<String>> getCategories(String type) async {
    final db = await instance.database;
    final result = await db.query('custom_categories', where: 'type = ?', whereArgs: [type]);
    return result.map((m) => m['name'] as String).toList();
  }

  // --- Settings CRUD ---
  Future<void> saveSettings(AppSettings settings) async {
    final db = await instance.database;
    final batch = db.batch();
    for (final entry in settings.toMap().entries) {
      batch.insert('settings', {'key': entry.key, 'value': entry.value}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<AppSettings> getSettings() async {
    final db = await instance.database;
    final result = await db.query('settings');
    final map = <String, String>{};
    for (final row in result) {
      map[row['key'] as String] = row['value'] as String;
    }
    return AppSettings.fromMap(map);
  }

  // --- Reset All Data ---
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('expenses');
    await db.delete('tasks');
    await db.delete('monthly_tasks');
    await db.delete('important_dates');
    await db.delete('budgets');
    await db.delete('recurring_expenses');
    await db.delete('recurring_tasks');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
