import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_provider.dart';
import '../models/task.dart';
import '../models/important_date.dart';
import '../models/expense.dart';
import '../widgets/glass_card.dart';
import '../widgets/dialogs/add_task_dialog.dart';
import '../widgets/dialogs/add_important_date_dialog.dart';
import '../widgets/dialogs/add_expense_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final selectedDayStr = DateFormat('yyyy-MM-dd').format(_selectedDay);

    // Selected day data from SQLite
    final dayTasks = provider.tasks.where((t) => t.date == selectedDayStr).toList();
    final dayDates = provider.importantDates.where((d) => d.date == selectedDayStr).toList();
    final dayExpenses = provider.expenses.where((e) => e.date == selectedDayStr).toList();
    final daySpending = dayExpenses.fold<double>(0.0, (acc, e) => acc + e.amount);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Month Navigator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TIME & AGENDA',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white70),
                        onPressed: _previousMonth,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white70),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar Grid Card
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Column(
                  children: [
                    // Weekday Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) {
                        return SizedBox(
                          width: 36,
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Days Matrix
                    _buildDaysMatrix(provider),
                  ],
                ),
              ),

              const SizedBox(height: 24), // Section spacing

              // Selected Date Details Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(_selectedDay),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dayTasks.length} tasks • ${dayDates.length} events • ${provider.formatCurrency(daySpending)} spent',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.add, color: Color(0xFFA5B4FC), size: 20),
                    ),
                    color: const Color(0xFF1E1E2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onSelected: (val) {
                      if (val == 'task') {
                        AddTaskDialog.show(context, initialDate: selectedDayStr);
                      } else if (val == 'date') {
                        AddImportantDateDialog.show(context, initialDate: selectedDayStr);
                      } else if (val == 'expense') {
                        AddExpenseDialog.show(context, initialDate: selectedDayStr);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'task',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                            SizedBox(width: 10),
                            Text('Add Task', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'date',
                        child: Row(
                          children: [
                            Icon(Icons.cake_outlined, color: Color(0xFF8B5CF6), size: 18),
                            SizedBox(width: 10),
                            Text('Add Important Date', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'expense',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward, color: Color(0xFFEF4444), size: 18),
                            SizedBox(width: 10),
                            Text('Add Expense', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Selected Date Items List
              if (dayTasks.isEmpty && dayDates.isEmpty && dayExpenses.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_note, size: 40, color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 10),
                        Text(
                          'No scheduled items or expenses for this date',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Important Dates / Deadlines
                if (dayDates.isNotEmpty) ...[
                  Text(
                    'IMPORTANT DATES & DEADLINES',
                    style: TextStyle(
                      color: const Color(0xFF8B5CF6),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...dayDates.map((d) => _buildDateCard(d, context)),
                  const SizedBox(height: 14),
                ],

                // Scheduled Tasks
                if (dayTasks.isNotEmpty) ...[
                  Text(
                    'SCHEDULED TASKS',
                    style: TextStyle(
                      color: const Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...dayTasks.map((t) => _buildTaskCard(t, provider)),
                  const SizedBox(height: 14),
                ],

                // Expenses Activity
                if (dayExpenses.isNotEmpty) ...[
                  Text(
                    'EXPENSES ACTIVITY',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...dayExpenses.map((e) => _buildExpenseCard(e, provider)),
                ],
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysMatrix(AppProvider provider) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    final today = DateTime.now();
    final todayFormatted = DateFormat('yyyy-MM-dd').format(today);

    final rows = <Widget>[];
    var currentDay = 1;

    for (var r = 0; r < 6; r++) {
      final weekCells = <Widget>[];

      for (var c = 0; c < 7; c++) {
        final cellIndex = r * 7 + c;

        if (cellIndex < startingWeekday || currentDay > daysInMonth) {
          weekCells.add(const SizedBox(width: 38, height: 42));
        } else {
          final day = currentDay;
          final cellDate = DateTime(year, month, day);
          final dateStr = DateFormat('yyyy-MM-dd').format(cellDate);

          final isSelected = cellDate.year == _selectedDay.year &&
              cellDate.month == _selectedDay.month &&
              cellDate.day == _selectedDay.day;
          final isToday = dateStr == todayFormatted;

          // Check if this date has tasks, important dates, or expenses
          final hasTasks = provider.tasks.any((t) => t.date == dateStr);
          final hasDates = provider.importantDates.any((d) => d.date == dateStr);
          final hasExpenses = provider.expenses.any((e) => e.date == dateStr);

          weekCells.add(
            GestureDetector(
              onTap: () {
                setState(() => _selectedDay = cellDate);
              },
              child: Container(
                width: 38,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : isToday
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected
                      ? Border.all(color: const Color(0xFF6366F1), width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? const Color(0xFFA5B4FC)
                                : Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Activity indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasDates)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              color: Color(0xFFC084FC),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasTasks)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasExpenses)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF87171),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );

          currentDay++;
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekCells,
          ),
        ),
      );

      if (currentDay > daysInMonth) break;
    }

    return Column(children: rows);
  }

  Widget _buildDateCard(ImportantDate d, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        onTap: () => AddImportantDateDialog.show(context, existingDate: d),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cake_outlined, color: Color(0xFFA78BFA), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${d.category}${d.time != null ? ' • ${d.time}' : ''}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskItem t, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                t.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: t.completed ? const Color(0xFF10B981) : Colors.white38,
                size: 20,
              ),
              onPressed: () => provider.toggleTaskCompleted(t.id),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.title,
                style: TextStyle(
                  color: t.completed ? Colors.white38 : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: t.completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (t.time != null)
              Text(
                t.time!,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense e, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_downward, color: Color(0xFFEF4444), size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(e.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Text(
              provider.formatCurrency(e.amount),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
