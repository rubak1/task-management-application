import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import '../models/task.dart';
import '../database/app_database.dart';

class ExportImportService {
  static final ExportImportService instance = ExportImportService._();
  ExportImportService._();

  Future<void> exportAndShareJson() => exportAllToJson();
  Future<void> exportAndShareExpensesCsv() async {
    final expenses = await AppDatabase.instance.getAllExpenses();
    final settings = await AppDatabase.instance.getSettings();
    await exportExpensesToCsv(expenses, settings.currencySymbol);
  }

  static Future<void> exportAllToJson() async {
    final db = AppDatabase.instance;
    final expenses = await db.getAllExpenses();
    final tasks = await db.getAllTasks();
    final monthlyTasks = await db.getAllMonthlyTasks();
    final importantDates = await db.getAllImportantDates();
    final budgets = await db.getAllBudgets();
    final recurringExpenses = await db.getAllRecurringExpenses();
    final recurringTasks = await db.getAllRecurringTasks();
    final settings = await db.getSettings();

    final data = {
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'monthly_tasks': monthlyTasks.map((m) => m.toMap()).toList(),
      'important_dates': importantDates.map((d) => d.toMap()).toList(),
      'budgets': budgets.map((b) => b.toMap()).toList(),
      'recurring_expenses': recurringExpenses.map((r) => r.toMap()).toList(),
      'recurring_tasks': recurringTasks.map((rt) => rt.toMap()).toList(),
      'settings': settings.toMap(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final file = File('${dir.path}/aether_backup_$dateStr.json');
    await file.writeAsString(jsonStr);

    await Share.shareXFiles([XFile(file.path)], text: 'Aether Finance & Tasks Backup JSON');
  }

  static Future<void> exportExpensesToCsv(List<Expense> expenses, String currencySymbol) async {
    final buffer = StringBuffer();
    buffer.writeln('ID,Date,Time,Title,Category,Amount,Currency,Payment Method,Notes');

    for (final exp in expenses) {
      final safeTitle = '"${exp.title.replaceAll('"', '""')}"';
      final safeNotes = '"${(exp.notes ?? '').replaceAll('"', '""')}"';
      buffer.writeln(
        '${exp.id},${exp.date},${exp.time},$safeTitle,${exp.category},${exp.amount},"$currencySymbol",${exp.paymentMethod},$safeNotes',
      );
    }

    final dir = await getTemporaryDirectory();
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final file = File('${dir.path}/expenses_export_$dateStr.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: 'Expenses CSV Export');
  }

  static Future<void> exportTasksToCsv(List<TaskItem> tasks) async {
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Date,Time,Priority,Category,Completed,CompletedAt');

    for (final t in tasks) {
      final safeTitle = '"${t.title.replaceAll('"', '""')}"';
      buffer.writeln(
        '${t.id},$safeTitle,${t.date},${t.time ?? ""},${t.priority},${t.category},${t.completed ? "YES" : "NO"},${t.completedAt ?? ""}',
      );
    }

    final dir = await getTemporaryDirectory();
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final file = File('${dir.path}/tasks_export_$dateStr.csv');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: 'Tasks CSV Export');
  }
}
