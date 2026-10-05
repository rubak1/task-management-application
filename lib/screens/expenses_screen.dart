import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_provider.dart';
import '../models/expense.dart';
import '../widgets/glass_card.dart';
import '../widgets/dialogs/add_expense_dialog.dart';
import '../widgets/dialogs/confirm_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc
  DateTime _currentMonth = DateTime.now();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final monthKey = DateFormat('yyyy-MM').format(_currentMonth);
    final monthLabel = DateFormat('MMMM yyyy').format(_currentMonth);
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    // Compute Metrics
    final allExpenses = provider.expenses;
    final totalAllTime = allExpenses.fold<double>(0.0, (acc, e) => acc + e.amount);

    final currentMonthExpenses = allExpenses.where((e) => e.date.startsWith(monthKey)).toList();
    final totalMonth = currentMonthExpenses.fold<double>(0.0, (acc, e) => acc + e.amount);

    final todayExpenses = allExpenses.where((e) => e.date == todayStr).toList();
    final totalToday = todayExpenses.fold<double>(0.0, (acc, e) => acc + e.amount);

    // Apply Filter & Search & Sort
    final query = _searchController.text.trim().toLowerCase();
    var filtered = currentMonthExpenses.where((e) {
      final matchesCat = _selectedCategory == 'All' || e.category == _selectedCategory;
      final matchesSearch = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          e.category.toLowerCase().contains(query) ||
          (e.notes != null && e.notes!.toLowerCase().contains(query));
      return matchesCat && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'date_desc') return b.date.compareTo(a.date);
      if (_sortBy == 'date_asc') return a.date.compareTo(b.date);
      if (_sortBy == 'amount_desc') return b.amount.compareTo(a.amount);
      if (_sortBy == 'amount_asc') return a.amount.compareTo(b.amount);
      return 0;
    });

    final categories = ['All', ...provider.expenseCategories];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => provider.loadFromDatabase(),
        color: const Color(0xFF6366F1),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Month Selector & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPENSES',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        monthLabel,
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
              const SizedBox(height: 18),

              // 2. Main Month Total Hero Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SPENT THIS MONTH',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.formatCurrency(totalMonth),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Daily, Monthly, Till Now Statistics Strip
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Today', provider.formatCurrency(totalToday)),
                          Container(width: 1, height: 26, color: Colors.white12),
                          _buildStatItem('This Month', provider.formatCurrency(totalMonth)),
                          Container(width: 1, height: 26, color: Colors.white12),
                          _buildStatItem('Till Now', provider.formatCurrency(totalAllTime)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Search Bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  hintText: 'Search expenses...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF14141E).withValues(alpha: 0.8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),

              // 4. Categories Filter Chips & Sort
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) setState(() => _selectedCategory = cat);
                              },
                              selectedColor: const Color(0xFF6366F1),
                              backgroundColor: const Color(0xFF14141E),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: isSelected ? const Color(0xFF6366F1) : Colors.white.withValues(alpha: 0.08)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14141E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: const Icon(Icons.sort, color: Colors.white70, size: 18),
                    ),
                    color: const Color(0xFF1E1E2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onSelected: (val) => setState(() => _sortBy = val),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'date_desc', child: Text('Date: Newest First', style: TextStyle(color: Colors.white, fontSize: 13))),
                      const PopupMenuItem(value: 'date_asc', child: Text('Date: Oldest First', style: TextStyle(color: Colors.white, fontSize: 13))),
                      const PopupMenuItem(value: 'amount_desc', child: Text('Amount: High to Low', style: TextStyle(color: Colors.white, fontSize: 13))),
                      const PopupMenuItem(value: 'amount_asc', child: Text('Amount: Low to High', style: TextStyle(color: Colors.white, fontSize: 13))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 5. Expense List
              if (filtered.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text(
                          currentMonthExpenses.isEmpty
                              ? 'No expenses recorded for $monthLabel'
                              : 'No expenses match your search or filter',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => AddExpenseDialog.show(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Expense'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final expense = filtered[idx];
                  return _buildExpenseCard(context, expense, provider);
                },
              ),

              const SizedBox(height: 80), // Ample bottom space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense, AppProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _showExpenseDetailsSheet(context, expense, provider),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.arrow_downward, color: Color(0xFFEF4444), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        expense.category,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${expense.date} • ${expense.time}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                provider.formatCurrency(expense.amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                expense.paymentMethod,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExpenseDetailsSheet(BuildContext context, Expense expense, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF14141E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      expense.title,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    provider.formatCurrency(expense.amount),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Category', expense.category),
              _buildDetailRow('Date & Time', '${expense.date} at ${expense.time}'),
              _buildDetailRow('Payment Method', expense.paymentMethod),
              if (expense.notes != null && expense.notes!.isNotEmpty)
                _buildDetailRow('Notes', expense.notes!),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final confirm = await ConfirmDialog.show(
                          context: context,
                          title: 'Delete Expense',
                          message: 'Are you sure you want to delete "${expense.title}"? This action cannot be undone.',
                        );
                        if (confirm) {
                          await provider.deleteExpense(expense.id);
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                      label: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        AddExpenseDialog.show(context, existingExpense: expense);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
