import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_provider.dart';
import '../../models/expense.dart';
import '../../models/task.dart';
import '../../models/important_date.dart';
import '../../models/recurring_expense.dart';
import 'add_expense_dialog.dart';
import 'add_task_dialog.dart';
import 'add_important_date_dialog.dart';

class GlobalSearchDialog extends StatefulWidget {
  const GlobalSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const GlobalSearchDialog(),
    );
  }

  @override
  State<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<GlobalSearchDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final q = _query.trim().toLowerCase();

    // Query actual stored SQLite user data
    final matchedExpenses = q.isEmpty
        ? <Expense>[]
        : provider.expenses.where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q) ||
            (e.notes != null && e.notes!.toLowerCase().contains(q))).toList();

    final matchedTasks = q.isEmpty
        ? <TaskItem>[]
        : provider.tasks.where((t) =>
            t.title.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q) ||
            (t.description != null && t.description!.toLowerCase().contains(q))).toList();

    final matchedDates = q.isEmpty
        ? <ImportantDate>[]
        : provider.importantDates.where((d) =>
            d.title.toLowerCase().contains(q) ||
            d.category.toLowerCase().contains(q) ||
            (d.notes != null && d.notes!.toLowerCase().contains(q))).toList();

    final matchedRecurring = q.isEmpty
        ? <RecurringExpense>[]
        : provider.recurringExpenses.where((r) =>
            r.title.toLowerCase().contains(q) ||
            r.category.toLowerCase().contains(q)).toList();

    final totalMatches = matchedExpenses.length + matchedTasks.length + matchedDates.length + matchedRecurring.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 650),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF14141E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.75),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (val) => setState(() => _query = val),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      hintText: 'Search tasks, expenses, dates, categories...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 14),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content / Results
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded, size: 48, color: Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(height: 12),
                          Text(
                            'Type to search across all your saved records',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : totalMatches == 0
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: Colors.white.withValues(alpha: 0.15)),
                              const SizedBox(height: 12),
                              Text(
                                'No saved records found for "$_query"',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: [
                            if (matchedExpenses.isNotEmpty) ...[
                              _buildSectionHeader('Expenses (${matchedExpenses.length})'),
                              ...matchedExpenses.map((exp) => _buildExpenseItem(context, exp, provider)),
                            ],
                            if (matchedTasks.isNotEmpty) ...[
                              _buildSectionHeader('Tasks (${matchedTasks.length})'),
                              ...matchedTasks.map((t) => _buildTaskItem(context, t, provider)),
                            ],
                            if (matchedDates.isNotEmpty) ...[
                              _buildSectionHeader('Important Dates (${matchedDates.length})'),
                              ...matchedDates.map((d) => _buildDateItem(context, d, provider)),
                            ],
                            if (matchedRecurring.isNotEmpty) ...[
                              _buildSectionHeader('Recurring Items (${matchedRecurring.length})'),
                              ...matchedRecurring.map((r) => _buildRecurringItem(r, provider)),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF6366F1).withValues(alpha: 0.9),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildExpenseItem(BuildContext context, Expense exp, AppProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).pop();
          AddExpenseDialog.show(context, existingExpense: exp);
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_downward, color: Color(0xFFEF4444), size: 16),
        ),
        title: Text(exp.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text('${exp.category} • ${exp.date}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: Text(
          provider.formatCurrency(exp.amount),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskItem t, AppProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).pop();
          AddTaskDialog.show(context, existingTask: t);
        },
        leading: IconButton(
          icon: Icon(
            t.completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: t.completed ? const Color(0xFF10B981) : Colors.white38,
            size: 20,
          ),
          onPressed: () => provider.toggleTaskCompleted(t.id),
        ),
        title: Text(
          t.title,
          style: TextStyle(
            color: t.completed ? Colors.white38 : Colors.white,
            fontSize: 14,
            decoration: t.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${t.category} • ${t.date}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ),
    );
  }

  Widget _buildDateItem(BuildContext context, ImportantDate d, AppProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).pop();
          AddImportantDateDialog.show(context, existingDate: d);
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.event, color: Color(0xFF8B5CF6), size: 16),
        ),
        title: Text(d.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text('${d.category} • ${d.date}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ),
    );
  }

  Widget _buildRecurringItem(RecurringExpense r, AppProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.repeat, color: Color(0xFF3B82F6), size: 16),
        ),
        title: Text(r.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text('${r.category} • ${r.frequency} • Due: ${r.nextDueDate}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: Text(
          provider.formatCurrency(r.amount),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
