import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../state/app_provider.dart';

class AddExpenseDialog extends StatefulWidget {
  final Expense? initialExpense;
  final String? initialDate;

  const AddExpenseDialog({super.key, this.initialExpense, this.initialDate});

  static Future<void> show(BuildContext context, {Expense? existingExpense, String? initialDate}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddExpenseDialog(initialExpense: existingExpense, initialDate: initialDate),
    );
  }

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late TextEditingController _customCategoryController;

  late String _selectedCategory;
  late String _selectedPaymentMethod;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isAddingCustomCategory = false;

  final List<String> _paymentMethods = [
    'UPI',
    'Cash',
    'Debit Card',
    'Credit Card',
    'Bank Transfer',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final exp = widget.initialExpense;
    _titleController = TextEditingController(text: exp?.title ?? '');
    _amountController = TextEditingController(text: exp != null ? exp.amount.toString() : '');
    _notesController = TextEditingController(text: exp?.notes ?? '');
    _customCategoryController = TextEditingController();

    _selectedCategory = exp?.category ?? 'Food';
    _selectedPaymentMethod = exp?.paymentMethod ?? 'UPI';

    if (exp != null) {
      _selectedDate = DateTime.tryParse(exp.date) ?? DateTime.now();
      final timeParts = exp.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 12,
        minute: int.tryParse(timeParts[1]) ?? 0,
      );
    } else {
      _selectedDate = widget.initialDate != null
          ? (DateTime.tryParse(widget.initialDate!) ?? DateTime.now())
          : DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AppProvider>(context, listen: false);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    String finalCategory = _selectedCategory;
    if (_isAddingCustomCategory && _customCategoryController.text.trim().isNotEmpty) {
      finalCategory = _customCategoryController.text.trim();
      await provider.addCustomCategory(finalCategory, 'expense');
    }

    if (widget.initialExpense != null) {
      final updated = widget.initialExpense!.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        category: finalCategory,
        date: dateStr,
        time: timeStr,
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.trim(),
      );
      await provider.updateExpense(updated);
    } else {
      await provider.addExpense(
        title: _titleController.text.trim(),
        amount: amount,
        category: finalCategory,
        date: dateStr,
        time: timeStr,
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.trim(),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final categories = provider.expenseCategories;

    return Dialog(
      backgroundColor: const Color(0xFF141620),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initialExpense != null ? 'Edit Expense' : 'Log Expense',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18.0),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: widget.initialExpense == null,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFFFD166)),
                decoration: InputDecoration(
                  prefixText: '${provider.settings.currencySymbol} ',
                  prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFFFD166)),
                  labelText: 'Amount',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter amount';
                  if (double.tryParse(val.trim()) == null || double.parse(val.trim()) <= 0) {
                    return 'Enter valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14.0),

              // Title Field (User customizable)
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Expense Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter expense name',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter expense name';
                  return null;
                },
              ),
              const SizedBox(height: 14.0),

              // Category Selector
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: categories.contains(_selectedCategory) ? _selectedCategory : (categories.isNotEmpty ? categories.first : 'Other'),
                      dropdownColor: const Color(0xFF1E2130),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                            _isAddingCustomCategory = false;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isAddingCustomCategory = !_isAddingCustomCategory;
                      });
                    },
                    icon: Icon(
                      _isAddingCustomCategory ? Icons.close_rounded : Icons.add_circle_outline_rounded,
                      color: const Color(0xFFFFD166),
                    ),
                    tooltip: 'Add Custom Category',
                  ),
                ],
              ),

              // Custom Category input field if requested
              if (_isAddingCustomCategory) ...[
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _customCategoryController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'New Category Name',
                    labelStyle: const TextStyle(color: Color(0xFFFFD166)),
                    hintText: 'e.g. College Expenses, Pet Care',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFFFFD166).withValues(alpha: 0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ],
              const SizedBox(height: 14.0),

              // Payment Method
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                dropdownColor: const Color(0xFF1E2130),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: _paymentMethods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPaymentMethod = val);
                },
              ),
              const SizedBox(height: 14.0),

              // Date & Time pickers
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                      icon: const Icon(Icons.access_time_rounded, size: 16),
                      label: Text(_selectedTime.format(context)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Add invoice notes or details',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24.0),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD166),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: Text(
                        widget.initialExpense != null ? 'Save Changes' : 'Log Expense',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
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
