import 'package:flutter_test/flutter_test.dart';
import 'package:aether_finance_tasks/models/expense.dart';
import 'package:aether_finance_tasks/models/task.dart';
import 'package:aether_finance_tasks/models/important_date.dart';
import 'package:aether_finance_tasks/models/monthly_task.dart';
import 'package:aether_finance_tasks/models/recurring_expense.dart';
import 'package:aether_finance_tasks/models/recurring_task.dart';
import 'package:aether_finance_tasks/models/budget.dart';
import 'package:aether_finance_tasks/models/app_settings.dart';

void main() {
  group('SQLite Persistence & Model Serialization Tests', () {
    test('Expense model serialization round-trip', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final expense = Expense(
        id: 'exp-101',
        title: 'Lunch',
        amount: 250.0,
        category: 'Food',
        date: '2026-09-25',
        time: '13:30',
        paymentMethod: 'UPI',
        notes: 'Personal dining',
        createdAt: now,
        updatedAt: now,
      );

      final map = expense.toMap();
      final restored = Expense.fromMap(map);

      expect(restored.id, 'exp-101');
      expect(restored.title, 'Lunch');
      expect(restored.amount, 250.0);
      expect(restored.category, 'Food');
      expect(restored.paymentMethod, 'UPI');
      expect(restored.notes, 'Personal dining');
    });

    test('TaskItem model serialization round-trip', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final task = TaskItem(
        id: 'task-202',
        title: 'My first personal task',
        description: 'Complete offline mobile app setup',
        date: '2026-09-25',
        time: '18:00',
        priority: 'high',
        category: 'Work',
        reminder: '15m',
        completed: false,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      );

      final map = task.toMap();
      final restored = TaskItem.fromMap(map);

      expect(restored.id, 'task-202');
      expect(restored.title, 'My first personal task');
      expect(restored.priority, 'high');
      expect(restored.reminder, '15m');
      expect(restored.completed, false);
    });

    test('ImportantDate model serialization round-trip', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final date = ImportantDate(
        id: 'date-303',
        title: 'My Event',
        date: '2026-10-15',
        time: '10:00',
        category: 'Event',
        notes: 'Celebration date',
        reminder: '1d',
        createdAt: now,
        updatedAt: now,
      );

      final map = date.toMap();
      final restored = ImportantDate.fromMap(map);

      expect(restored.id, 'date-303');
      expect(restored.title, 'My Event');
      expect(restored.date, '2026-10-15');
      expect(restored.reminder, '1d');
    });

    test('MonthlyTask and Recurring models serialization', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final mTask = MonthlyTask(
        id: 'm-404',
        title: 'Save ₹10,000 this month',
        monthYear: '2026-09',
        priority: 'high',
        notes: 'Monthly savings goal',
        completed: false,
        createdAt: now,
        updatedAt: now,
      );
      final restoredMTask = MonthlyTask.fromMap(mTask.toMap());
      expect(restoredMTask.title, 'Save ₹10,000 this month');
      expect(restoredMTask.monthYear, '2026-09');

      final rExp = RecurringExpense(
        id: 'rec-505',
        title: 'WiFi Fiber Bill',
        amount: 999.0,
        category: 'Bills',
        frequency: 'monthly',
        startDate: '2026-09-01',
        nextDueDate: '2026-10-01',
        paymentMethod: 'UPI',
        autoLogExpense: true,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      final restoredRExp = RecurringExpense.fromMap(rExp.toMap());
      expect(restoredRExp.title, 'WiFi Fiber Bill');
      expect(restoredRExp.amount, 999.0);
      expect(restoredRExp.frequency, 'monthly');

      final rTask = RecurringTask(
        id: 'rec-task-606',
        title: 'Morning Run & Workout',
        category: 'Health',
        frequency: 'daily',
        priority: 'high',
        startDate: '2026-09-01',
        nextDueDate: '2026-09-26',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      final restoredRTask = RecurringTask.fromMap(rTask.toMap());
      expect(restoredRTask.title, 'Morning Run & Workout');
      expect(restoredRTask.frequency, 'daily');
    });

    test('Budget and AppSettings serialization', () {
      final budget = MonthlyBudget(
        monthYear: '2026-09',
        amount: 35000.0,
        notes: 'Festival month allocation',
        updatedAt: 1234567,
      );
      final restoredBudget = MonthlyBudget.fromMap(budget.toMap());
      expect(restoredBudget.monthYear, '2026-09');
      expect(restoredBudget.amount, 35000.0);

      final settings = AppSettings(
        currencySymbol: '₹',
        defaultMonthlyBudget: 40000.0,
        notificationsEnabled: true,
        soundEnabled: true,
        reducedMotion: false,
      );
      final restoredSettings = AppSettings.fromMap(settings.toMap());
      expect(restoredSettings.currencySymbol, '₹');
      expect(restoredSettings.defaultMonthlyBudget, 40000.0);
    });
  });
}
