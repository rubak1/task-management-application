import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/dialogs/add_task_dialog.dart';
import '../widgets/dialogs/add_important_date_dialog.dart';
import '../widgets/dialogs/edit_budget_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final currentMonthYear = DateFormat('yyyy-MM').format(DateTime.now());
    final displayDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    // 1. Calculations from actual SQLite user data
    final todayTasks = provider.tasks.where((t) => t.date == todayStr).toList();
    final todayTasksDone = todayTasks.where((t) => t.completed).length;

    final todayExpenses = provider.expenses.where((e) => e.date == todayStr).toList();
    final todaySpending = todayExpenses.fold<double>(0.0, (acc, e) => acc + e.amount);

    final monthExpenses = provider.expenses.where((e) => e.date.startsWith(currentMonthYear)).toList();
    final monthSpending = monthExpenses.fold<double>(0.0, (acc, e) => acc + e.amount);
    final monthBudget = provider.getBudgetForMonth(currentMonthYear);
    final budgetPercent = monthBudget > 0 ? (monthSpending / monthBudget).clamp(0.0, 1.0) : 0.0;

    // Upcoming important dates (next 30 days)
    final upcomingDates = provider.importantDates.where((d) => d.date.compareTo(todayStr) >= 0).take(3).toList();

    // Upcoming recurring expenses
    final upcomingRecurring = provider.recurringExpenses.where((r) => r.isActive).take(3).toList();

    return RefreshIndicator(
      onRefresh: () => provider.loadFromDatabase(),
      color: const Color(0xFF6366F1),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Greeting & Date
            Text(
              _getGreeting(),
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              displayDate,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24), // Section spacing

            // 2. Today's Summary Overview (Dual Metric Cards)
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(18),
                    onTap: () => provider.setTabIndex(2), // Jump to Tasks
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TODAY'S TASKS",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Icon(Icons.check_circle_outline, color: const Color(0xFF10B981), size: 18),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          todayTasks.isEmpty ? '0 tasks' : '$todayTasksDone / ${todayTasks.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayTasks.isEmpty
                              ? 'No tasks today'
                              : todayTasksDone == todayTasks.length
                                  ? 'All completed!'
                                  : '${todayTasks.length - todayTasksDone} remaining',
                          style: TextStyle(
                            color: todayTasksDone == todayTasks.length && todayTasks.isNotEmpty
                                ? const Color(0xFF10B981)
                                : Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(18),
                    onTap: () => provider.setTabIndex(1), // Jump to Expenses
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TODAY'S SPENT",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Icon(Icons.arrow_outward, color: const Color(0xFFEF4444), size: 18),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.formatCurrency(todaySpending),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${todayExpenses.length} transactions',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. Monthly Budget Progress Card
            GlassCard(
              padding: const EdgeInsets.all(18),
              onTap: () => EditBudgetDialog.show(context, currentMonthYear, monthBudget),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF818CF8), size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Monthly Budget',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(DateTime.now()),
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined, color: Colors.white.withValues(alpha: 0.4), size: 14),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        provider.formatCurrency(monthSpending),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'of ${provider.formatCurrency(monthBudget)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: budgetPercent,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budgetPercent > 0.9
                            ? const Color(0xFFEF4444)
                            : budgetPercent > 0.75
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(budgetPercent * 100).toStringAsFixed(1)}% utilized',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                      ),
                      Text(
                        monthBudget > monthSpending
                            ? '${provider.formatCurrency(monthBudget - monthSpending)} remaining'
                            : 'Exceeded budget',
                        style: TextStyle(
                          color: monthBudget >= monthSpending ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24), // Section spacing

            // 4. Today's Priority Tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Priority Tasks",
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => provider.setTabIndex(2),
                  child: const Text('View All', style: TextStyle(color: Color(0xFF818CF8), fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (todayTasks.isEmpty)
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.task_alt, color: Colors.white.withValues(alpha: 0.2), size: 36),
                      const SizedBox(height: 10),
                      Text(
                        'No tasks scheduled for today',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => AddTaskDialog.show(context, initialDate: todayStr),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Task'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF818CF8),
                          side: BorderSide(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todayTasks.take(4).map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: task.completed ? const Color(0xFF10B981) : Colors.white38,
                            size: 22,
                          ),
                          onPressed: () => provider.toggleTaskCompleted(task.id),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  color: task.completed ? Colors.white38 : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: task.completed ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: task.priority == 'high'
                                          ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                                          : const Color(0xFF6366F1).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      task.priority.toUpperCase(),
                                      style: TextStyle(
                                        color: task.priority == 'high' ? const Color(0xFFFCA5A5) : const Color(0xFFA5B4FC),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    task.category,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                                  ),
                                  if (task.time != null) ...[
                                    Text(' • ', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                                    Text(
                                      task.time!,
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 16),
                          onPressed: () => AddTaskDialog.show(context, existingTask: task),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24), // Section spacing

            // 5. Upcoming Important Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Dates',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => provider.setTabIndex(3), // Jump to Calendar
                  child: const Text('Calendar', style: TextStyle(color: Color(0xFF818CF8), fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (upcomingDates.isEmpty)
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_available, color: Colors.white.withValues(alpha: 0.2), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'No upcoming important dates saved',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => AddImportantDateDialog.show(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Date'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF818CF8),
                          side: BorderSide(color: const Color(0xFF6366F1).withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...upcomingDates.map((d) {
                final dateObj = DateTime.tryParse(d.date);
                final formatted = dateObj != null ? DateFormat('MMM d, yyyy').format(dateObj) : d.date;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.cake_outlined, color: Color(0xFFA78BFA), size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.title,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${d.category} • $formatted',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 16),
                          onPressed: () => AddImportantDateDialog.show(context, existingDate: d),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24), // Section spacing

            // 6. Upcoming Recurring Expenses
            if (upcomingRecurring.isNotEmpty) ...[
              const Text(
                'Upcoming Recurring Bills',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...upcomingRecurring.map((r) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.repeat, color: Color(0xFF60A5FA), size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.title,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${r.category} • Due: ${r.nextDueDate}',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              provider.formatCurrency(r.amount),
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => provider.markRecurringExpensePaid(r.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Mark Paid',
                                  style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // 7. Productivity & Financial Insights Card
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withValues(alpha: 0.3),
                          const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.insights, color: Color(0xFFA5B4FC), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Perspective',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          monthSpending > monthBudget && monthBudget > 0
                              ? 'Your spending has exceeded your monthly limit. Review and optimize discretionary expenses.'
                              : todayTasks.isNotEmpty && todayTasksDone == todayTasks.length
                                  ? 'Outstanding focus! All scheduled tasks for today are completed.'
                                  : 'Maintain balance by tracking your expenses right as they happen.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // Ample bottom breathing room above nav bar
          ],
        ),
      ),
    );
  }
}
