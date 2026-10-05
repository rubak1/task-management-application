import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/task.dart';
import '../models/monthly_task.dart';
import '../models/important_date.dart';
import '../models/budget.dart';
import '../models/recurring_expense.dart';
import '../models/recurring_task.dart';
import '../models/app_settings.dart';
import '../database/app_database.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];
  String get selectedDate => _selectedDate;

  // In-memory reactive state loaded from SQLite
  List<Expense> _expenses = [];
  List<TaskItem> _tasks = [];
  List<MonthlyTask> _monthlyTasks = [];
  List<ImportantDate> _importantDates = [];
  List<MonthlyBudget> _budgets = [];
  List<RecurringExpense> _recurringExpenses = [];
  List<RecurringTask> _recurringTasks = [];
  List<String> _expenseCategories = [];
  List<String> _taskCategories = [];
  AppSettings _settings = AppSettings();

  List<Expense> get expenses => _expenses;
  List<TaskItem> get tasks => _tasks;
  List<MonthlyTask> get monthlyTasks => _monthlyTasks;
  List<ImportantDate> get importantDates => _importantDates;
  List<MonthlyBudget> get budgets => _budgets;
  List<RecurringExpense> get recurringExpenses => _recurringExpenses;
  List<RecurringTask> get recurringTasks => _recurringTasks;
  List<String> get expenseCategories => _expenseCategories;
  List<String> get taskCategories => _taskCategories;
  AppSettings get settings => _settings;

  AppProvider() {
    loadFromDatabase();
  }

  Future<void> loadFromDatabase() async {
    _expenses = await _db.getAllExpenses();
    _tasks = await _db.getAllTasks();
    _monthlyTasks = await _db.getAllMonthlyTasks();
    _importantDates = await _db.getAllImportantDates();
    _budgets = await _db.getAllBudgets();
    _recurringExpenses = await _db.getAllRecurringExpenses();
    _recurringTasks = await _db.getAllRecurringTasks();
    _expenseCategories = await _db.getCategories('expense');
    _taskCategories = await _db.getCategories('task');
    _settings = await _db.getSettings();

    _isLoaded = true;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSelectedDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  String formatCurrency(double amount) {
    final symbol = _settings.currencySymbol;
    final formatter = NumberFormat('#,##,###.##', 'en_IN');
    final formatted = formatter.format(amount);
    return '$symbol$formatted';
  }

  // --- Expenses ---
  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required String date,
    required String time,
    required String paymentMethod,
    String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expense = Expense(
      id: _uuid.v4(),
      title: title.trim(),
      amount: amount,
      category: category,
      date: date,
      time: time,
      paymentMethod: paymentMethod,
      notes: notes?.trim(),
      createdAt: now,
      updatedAt: now,
    );

    // Immediate SQLite Persistence
    await _db.insertExpense(expense);
    _expenses.insert(0, expense);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    final updated = expense.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
    await _db.updateExpense(updated);
    final idx = _expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) {
      _expenses[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // --- Tasks ---
  Future<void> addTask({
    required String title,
    String? description,
    required String date,
    String? time,
    required String priority,
    required String category,
    String reminder = 'none',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final task = TaskItem(
      id: _uuid.v4(),
      title: title.trim(),
      description: description?.trim(),
      date: date,
      time: time,
      priority: priority,
      category: category,
      reminder: reminder,
      completed: false,
      sortOrder: _tasks.length + 1,
      createdAt: now,
      updatedAt: now,
    );

    await _db.insertTask(task);
    _tasks.add(task);

    // Schedule Android local notification if reminder set
    if (reminder != 'none' && time != null) {
      _scheduleTaskReminder(task);
    }

    notifyListeners();
  }

  Future<void> updateTask(TaskItem task) async {
    final updated = task.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
    await _db.updateTask(updated);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompleted(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final current = _tasks[idx];
    final willComplete = !current.completed;
    final updated = current.copyWith(
      completed: willComplete,
      completedAt: willComplete ? DateTime.now().millisecondsSinceEpoch : null,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.updateTask(updated);
    _tasks[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void _scheduleTaskReminder(TaskItem task) {
    if (task.time == null) return;
    try {
      final timeParts = task.time!.split(':');
      final dateParts = task.date.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      var scheduleTime = DateTime(year, month, day, hour, minute);

      if (task.reminder == '5m') {
        scheduleTime = scheduleTime.subtract(const Duration(minutes: 5));
      } else if (task.reminder == '15m') {
        scheduleTime = scheduleTime.subtract(const Duration(minutes: 15));
      } else if (task.reminder == '30m') {
        scheduleTime = scheduleTime.subtract(const Duration(minutes: 30));
      } else if (task.reminder == '1h') {
        scheduleTime = scheduleTime.subtract(const Duration(hours: 1));
      } else if (task.reminder == '1d') {
        scheduleTime = scheduleTime.subtract(const Duration(days: 1));
      }

      final notifId = task.id.hashCode;
      NotificationService.instance.scheduleNotification(
        id: notifId,
        title: 'Task Reminder: ${task.title}',
        body: task.description?.isNotEmpty == true ? task.description! : 'Scheduled for ${task.time}',
        scheduledDate: scheduleTime,
      );
    } catch (_) {}
  }

  // --- Monthly Tasks ---
  Future<void> addMonthlyTask({
    required String title,
    required String monthYear,
    String priority = 'medium',
    String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = MonthlyTask(
      id: _uuid.v4(),
      title: title.trim(),
      monthYear: monthYear,
      priority: priority,
      notes: notes?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertMonthlyTask(item);
    _monthlyTasks.insert(0, item);
    notifyListeners();
  }

  Future<void> toggleMonthlyTaskCompleted(String id) async {
    final idx = _monthlyTasks.indexWhere((m) => m.id == id);
    if (idx == -1) return;

    final curr = _monthlyTasks[idx];
    final willComplete = !curr.completed;
    final updated = curr.copyWith(
      completed: willComplete,
      completedAt: willComplete ? DateTime.now().millisecondsSinceEpoch : null,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.updateMonthlyTask(updated);
    _monthlyTasks[idx] = updated;
    notifyListeners();
  }

  Future<void> updateMonthlyTask(MonthlyTask item) async {
    final updated = item.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
    await _db.updateMonthlyTask(updated);
    final idx = _monthlyTasks.indexWhere((m) => m.id == item.id);
    if (idx != -1) {
      _monthlyTasks[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteMonthlyTask(String id) async {
    await _db.deleteMonthlyTask(id);
    _monthlyTasks.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // --- Important Dates ---
  Future<void> addImportantDate({
    required String title,
    required String date,
    String? time,
    required String category,
    String? notes,
    String reminder = '1d',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = ImportantDate(
      id: _uuid.v4(),
      title: title.trim(),
      date: date,
      time: time,
      category: category,
      notes: notes?.trim(),
      reminder: reminder,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertImportantDate(item);
    _importantDates.add(item);
    _importantDates.sort((a, b) => a.date.compareTo(b.date));

    // Schedule Android Notification with user's own event title
    try {
      final parts = date.split('-');
      var dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]), 9, 0);
      if (reminder == '1d') {
        dt = dt.subtract(const Duration(days: 1));
      }
      NotificationService.instance.scheduleNotification(
        id: item.id.hashCode,
        title: 'Upcoming: ${item.title}',
        body: '${item.category} on $date',
        scheduledDate: dt,
      );
    } catch (_) {}

    notifyListeners();
  }

  Future<void> updateImportantDate(ImportantDate item) async {
    final updated = item.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
    await _db.updateImportantDate(updated);
    final idx = _importantDates.indexWhere((d) => d.id == item.id);
    if (idx != -1) {
      _importantDates[idx] = updated;
      _importantDates.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    }
  }

  Future<void> deleteImportantDate(String id) async {
    await _db.deleteImportantDate(id);
    _importantDates.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  // --- Budgets ---
  double getBudgetForMonth(String monthYear) {
    final found = _budgets.firstWhere(
      (b) => b.monthYear == monthYear,
      orElse: () => MonthlyBudget(
        monthYear: monthYear,
        amount: _settings.defaultMonthlyBudget,
        updatedAt: 0,
      ),
    );
    return found.amount;
  }

  Future<void> setBudgetForMonth(String monthYear, double amount, [String? notes]) async {
    final budget = MonthlyBudget(
      monthYear: monthYear,
      amount: amount,
      notes: notes?.trim(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.setBudget(budget);
    final idx = _budgets.indexWhere((b) => b.monthYear == monthYear);
    if (idx != -1) {
      _budgets[idx] = budget;
    } else {
      _budgets.add(budget);
    }
    notifyListeners();
  }

  // --- Recurring Expenses ---
  Future<void> addRecurringExpense({
    required String title,
    required double amount,
    required String category,
    required String frequency,
    required String startDate,
    required String nextDueDate,
    required String paymentMethod,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = RecurringExpense(
      id: _uuid.v4(),
      title: title.trim(),
      amount: amount,
      category: category,
      frequency: frequency,
      startDate: startDate,
      nextDueDate: nextDueDate,
      paymentMethod: paymentMethod,
      autoLogExpense: true,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertRecurringExpense(item);
    _recurringExpenses.add(item);
    notifyListeners();
  }

  Future<void> markRecurringExpensePaid(String id) async {
    final idx = _recurringExpenses.indexWhere((r) => r.id == id);
    if (idx == -1) return;

    final target = _recurringExpenses[idx];
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    final timeStr = '${today.hour.toString().padLeft(2, '0')}:${today.minute.toString().padLeft(2, '0')}';

    // 1. Create real Expense record
    await addExpense(
      title: target.title,
      amount: target.amount,
      category: target.category,
      date: todayStr,
      time: timeStr,
      paymentMethod: target.paymentMethod,
      notes: 'Paid recurring bill on $todayStr',
    );

    // 2. Advance next due date
    final curr = DateTime.tryParse(target.nextDueDate) ?? today;
    DateTime next;
    if (target.frequency == 'weekly') {
      next = curr.add(const Duration(days: 7));
    } else if (target.frequency == 'yearly') {
      next = DateTime(curr.year + 1, curr.month, curr.day);
    } else {
      // default monthly
      next = DateTime(curr.year, curr.month + 1, curr.day);
    }
    final nextDueStr = next.toIso8601String().split('T')[0];

    final updated = target.copyWith(
      nextDueDate: nextDueStr,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.updateRecurringExpense(updated);
    _recurringExpenses[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteRecurringExpense(String id) async {
    await _db.deleteRecurringExpense(id);
    _recurringExpenses.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // --- Recurring Tasks ---
  Future<void> addRecurringTask({
    required String title,
    required String category,
    required String frequency,
    int? customDays,
    required String priority,
    required String startDate,
    required String nextDueDate,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = RecurringTask(
      id: _uuid.v4(),
      title: title.trim(),
      category: category,
      frequency: frequency,
      customDays: customDays,
      priority: priority,
      startDate: startDate,
      nextDueDate: nextDueDate,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertRecurringTask(item);
    _recurringTasks.add(item);
    notifyListeners();
  }

  Future<void> completeRecurringTask(String id) async {
    final idx = _recurringTasks.indexWhere((r) => r.id == id);
    if (idx == -1) return;

    final target = _recurringTasks[idx];
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];

    // Compute next due date
    final curr = DateTime.tryParse(target.nextDueDate) ?? today;
    DateTime next;
    if (target.frequency == 'daily') {
      next = curr.add(const Duration(days: 1));
    } else if (target.frequency == 'weekly') {
      next = curr.add(const Duration(days: 7));
    } else if (target.frequency == 'yearly') {
      next = DateTime(curr.year + 1, curr.month, curr.day);
    } else if (target.frequency == 'custom' && target.customDays != null) {
      next = curr.add(Duration(days: target.customDays!));
    } else {
      next = DateTime(curr.year, curr.month + 1, curr.day);
    }

    final nextDueStr = next.toIso8601String().split('T')[0];
    final updated = target.copyWith(
      lastCompletedDate: todayStr,
      nextDueDate: nextDueStr,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.updateRecurringTask(updated);
    _recurringTasks[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteRecurringTask(String id) async {
    await _db.deleteRecurringTask(id);
    _recurringTasks.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // --- Custom Categories Management ---
  Future<void> addCustomCategory(String name, String type) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _db.insertCategory(trimmed, type);
    if (type == 'expense' && !_expenseCategories.contains(trimmed)) {
      _expenseCategories.add(trimmed);
    } else if (type == 'task' && !_taskCategories.contains(trimmed)) {
      _taskCategories.add(trimmed);
    }
    notifyListeners();
  }

  Future<void> removeCustomCategory(String name, String type) async {
    await _db.deleteCategory(name, type);
    if (type == 'expense') {
      _expenseCategories.remove(name);
    } else {
      _taskCategories.remove(name);
    }
    notifyListeners();
  }

  // --- Settings ---
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _db.saveSettings(newSettings);
    notifyListeners();
  }

  // --- Erase All Data ---
  Future<void> resetAllData() async {
    await _db.clearAllData();
    _expenses.clear();
    _tasks.clear();
    _monthlyTasks.clear();
    _importantDates.clear();
    _budgets.clear();
    _recurringExpenses.clear();
    _recurringTasks.clear();
    notifyListeners();
  }
}
