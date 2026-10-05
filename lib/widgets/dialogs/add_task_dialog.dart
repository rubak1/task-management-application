import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../state/app_provider.dart';

class AddTaskDialog extends StatefulWidget {
  final TaskItem? initialTask;
  final String? defaultDate;

  const AddTaskDialog({super.key, this.initialTask, this.defaultDate});

  static Future<void> show(BuildContext context, {TaskItem? existingTask, String? initialDate}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddTaskDialog(initialTask: existingTask, defaultDate: initialDate),
    );
  }

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _customCategoryController;

  late String _priority;
  late String _category;
  late String _reminder;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isAddingCustomCategory = false;

  final List<String> _priorities = ['low', 'medium', 'high', 'urgent'];
  final List<Map<String, String>> _reminders = [
    {'value': 'none', 'label': 'No reminder'},
    {'value': 'at_time', 'label': 'At time of task'},
    {'value': '5m', 'label': '5 minutes before'},
    {'value': '15m', 'label': '15 minutes before'},
    {'value': '30m', 'label': '30 minutes before'},
    {'value': '1h', 'label': '1 hour before'},
    {'value': '1d', 'label': '1 day before'},
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.initialTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _customCategoryController = TextEditingController();

    _priority = t?.priority ?? 'medium';
    _category = t?.category ?? 'Work';
    _reminder = t?.reminder ?? 'none';

    if (t != null) {
      _selectedDate = DateTime.tryParse(t.date) ?? DateTime.now();
      if (t.time != null && t.time!.contains(':')) {
        final parts = t.time!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 10,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    } else if (widget.defaultDate != null) {
      _selectedDate = DateTime.tryParse(widget.defaultDate!) ?? DateTime.now();
      _selectedTime = const TimeOfDay(hour: 10, minute: 0);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AppProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : null;

    String finalCategory = _category;
    if (_isAddingCustomCategory && _customCategoryController.text.trim().isNotEmpty) {
      finalCategory = _customCategoryController.text.trim();
      await provider.addCustomCategory(finalCategory, 'task');
    }

    if (widget.initialTask != null) {
      final updated = widget.initialTask!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: dateStr,
        time: timeStr,
        priority: _priority,
        category: finalCategory,
        reminder: _reminder,
      );
      await provider.updateTask(updated);
    } else {
      await provider.addTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: dateStr,
        time: timeStr,
        priority: _priority,
        category: finalCategory,
        reminder: _reminder,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final categories = provider.taskCategories;

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
                widget.initialTask != null ? 'Edit Task' : 'Create Task',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18.0),

              // Title (Custom user-controlled)
              TextFormField(
                controller: _titleController,
                autofocus: widget.initialTask == null,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter your task title',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a task title';
                  return null;
                },
              ),
              const SizedBox(height: 14.0),

              // Priority Selector Chips
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority Level', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6.0),
                  Row(
                    children: _priorities.map((p) {
                      final isSelected = _priority == p;
                      Color pColor = Colors.amber;
                      if (p == 'urgent') pColor = const Color(0xFFFF1053);
                      if (p == 'high') pColor = Colors.orange;
                      if (p == 'low') pColor = Colors.blue;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: InkWell(
                            onTap: () => setState(() => _priority = p),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? pColor.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? pColor : Colors.white12,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                p.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? pColor : Colors.white60,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),

              // Category with custom add option
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: categories.contains(_category) ? _category : (categories.isNotEmpty ? categories.first : 'Work'),
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
                            _category = val;
                            _isAddingCustomCategory = false;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    onPressed: () {
                      setState(() => _isAddingCustomCategory = !_isAddingCustomCategory);
                    },
                    icon: Icon(
                      _isAddingCustomCategory ? Icons.close_rounded : Icons.add_circle_outline_rounded,
                      color: const Color(0xFF06D6A0),
                    ),
                    tooltip: 'Add Custom Category',
                  ),
                ],
              ),

              if (_isAddingCustomCategory) ...[
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _customCategoryController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'New Category Name',
                    labelStyle: const TextStyle(color: Color(0xFF06D6A0)),
                    hintText: 'e.g. Thesis, Coding, Fitness',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF06D6A0).withValues(alpha: 0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ],
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
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _selectedTime = picked);
                      },
                      icon: const Icon(Icons.access_time_rounded, size: 16),
                      label: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Time'),
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

              // Reminder Selector
              DropdownButtonFormField<String>(
                value: _reminder,
                dropdownColor: const Color(0xFF1E2130),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Reminder Alert',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: _reminders
                    .map((r) => DropdownMenuItem(value: r['value']!, child: Text(r['label']!)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _reminder = val);
                },
              ),
              const SizedBox(height: 14.0),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter details or steps',
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
                        backgroundColor: const Color(0xFF06D6A0),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: Text(
                        widget.initialTask != null ? 'Save Changes' : 'SAVE',
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
