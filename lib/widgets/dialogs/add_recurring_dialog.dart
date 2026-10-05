import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_provider.dart';

class AddRecurringDialog extends StatefulWidget {
  final int initialType; // 0 = Expense, 1 = Routine Task

  const AddRecurringDialog({super.key, this.initialType = 0});

  static Future<void> show(BuildContext context, {int initialType = 0}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddRecurringDialog(initialType: initialType),
    );
  }

  @override
  State<AddRecurringDialog> createState() => _AddRecurringDialogState();
}

class _AddRecurringDialogState extends State<AddRecurringDialog> {
  late int _type; // 0: Expense, 1: Task
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String _frequency = 'monthly';
  String _category = 'Bills';
  String _priority = 'medium';
  String _paymentMethod = 'UPI';
  DateTime _startDate = DateTime.now();
  bool _isCustomCategory = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    if (_type == 1) {
      _category = 'Personal';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final provider = context.read<AppProvider>();
    String finalCategory = _category;
    if (_isCustomCategory) {
      final customName = _customCategoryController.text.trim();
      if (customName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter custom category name')),
        );
        return;
      }
      finalCategory = customName;
      await provider.addCustomCategory(customName, _type == 0 ? 'expense' : 'task');
    }

    setState(() => _isSaving = true);
    final startDateStr = _startDate.toIso8601String().split('T')[0];

    if (_type == 0) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      if (amount <= 0) {
        setState(() => _isSaving = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
        return;
      }

      await provider.addRecurringExpense(
        title: title,
        amount: amount,
        category: finalCategory,
        frequency: _frequency,
        startDate: startDateStr,
        nextDueDate: startDateStr,
        paymentMethod: _paymentMethod,
      );
    } else {
      await provider.addRecurringTask(
        title: title,
        category: finalCategory,
        frequency: _frequency,
        priority: _priority,
        startDate: startDateStr,
        nextDueDate: startDateStr,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final categories = _type == 0 ? provider.expenseCategories : provider.taskCategories;
    final symbol = provider.settings.currencySymbol;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF14141E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _type == 0 ? 'Add Recurring Expense' : 'Add Recurring Routine',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Type Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _type = 0;
                          _category = 'Bills';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 0 ? const Color(0xFF6366F1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Bill / Subscription',
                            style: TextStyle(
                              color: _type == 0 ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _type = 1;
                          _category = 'Personal';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 1 ? const Color(0xFF6366F1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Routine Habit',
                            style: TextStyle(
                              color: _type == 1 ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Title
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  labelText: _type == 0 ? 'Name (e.g. WiFi Bill, Rent)' : 'Routine Name (e.g. Weekly Workout)',
                  hintText: 'Enter title',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              // Amount (if Expense)
              if (_type == 0) ...[
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: '$symbol ',
                    prefixStyle: const TextStyle(color: Colors.white70, fontSize: 18),
                    labelText: 'Amount',
                    hintText: '0.00',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Frequency
              Text(
                'Frequency',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_type == 1) 'daily',
                  'weekly',
                  'monthly',
                  'yearly',
                ].map((f) {
                  final isSelected = _frequency == f;
                  return ChoiceChip(
                    label: Text(f[0].toUpperCase() + f.substring(1)),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _frequency = f);
                    },
                    selectedColor: const Color(0xFF6366F1),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 12),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Category Selector
              Text(
                'Category',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...categories.map((cat) {
                    final isSel = !_isCustomCategory && _category == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          _isCustomCategory = false;
                          _category = cat;
                        });
                      },
                      selectedColor: const Color(0xFF6366F1),
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      labelStyle: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 12),
                    );
                  }),
                  ChoiceChip(
                    label: const Text('+ Custom'),
                    selected: _isCustomCategory,
                    onSelected: (val) {
                      setState(() => _isCustomCategory = true);
                    },
                    selectedColor: const Color(0xFF6366F1),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    labelStyle: TextStyle(color: _isCustomCategory ? Colors.white : Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              if (_isCustomCategory) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _customCategoryController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Custom Category Name',
                    hintText: 'e.g. Gym Membership, Coaching',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Date Selector
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                tileColor: Colors.white.withValues(alpha: 0.04),
                leading: const Icon(Icons.calendar_today, color: Color(0xFF6366F1), size: 20),
                title: Text(
                  'Starting Date: ${_startDate.toIso8601String().split('T')[0]}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Item', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
