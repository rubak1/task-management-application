import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/monthly_task.dart';
import '../../state/app_provider.dart';

class AddMonthlyTaskDialog extends StatefulWidget {
  final MonthlyTask? initialMonthlyTask;
  final String? defaultMonthYear;

  const AddMonthlyTaskDialog({super.key, this.initialMonthlyTask, this.defaultMonthYear});

  static Future<void> show(BuildContext context, {MonthlyTask? existingMonthlyTask, String? initialMonthYear}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddMonthlyTaskDialog(initialMonthlyTask: existingMonthlyTask, defaultMonthYear: initialMonthYear),
    );
  }

  @override
  State<AddMonthlyTaskDialog> createState() => _AddMonthlyTaskDialogState();
}

class _AddMonthlyTaskDialogState extends State<AddMonthlyTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late String _priority;
  late String _monthYear;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMonthlyTask;
    _titleController = TextEditingController(text: m?.title ?? '');
    _notesController = TextEditingController(text: m?.notes ?? '');
    _priority = m?.priority ?? 'medium';
    _monthYear = m?.monthYear ??
        widget.defaultMonthYear ??
        DateFormat('yyyy-MM').format(DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AppProvider>(context, listen: false);
    if (widget.initialMonthlyTask != null) {
      final updated = widget.initialMonthlyTask!.copyWith(
        title: _titleController.text.trim(),
        monthYear: _monthYear,
        priority: _priority,
        notes: _notesController.text.trim(),
      );
      await provider.updateMonthlyTask(updated);
    } else {
      await provider.addMonthlyTask(
        title: _titleController.text.trim(),
        monthYear: _monthYear,
        priority: _priority,
        notes: _notesController.text.trim(),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                widget.initialMonthlyTask != null ? 'Edit Monthly Goal' : 'New Monthly Goal',
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 18.0),

              // Title (Custom user-controlled)
              TextFormField(
                controller: _titleController,
                autofocus: widget.initialMonthlyTask == null,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Monthly Goal / Objective',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter your monthly goal',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a goal title';
                  return null;
                },
              ),
              const SizedBox(height: 14.0),

              // Target Month
              TextFormField(
                initialValue: _monthYear,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Target Month (YYYY-MM)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: '2026-09',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                onChanged: (val) => _monthYear = val.trim(),
              ),
              const SizedBox(height: 14.0),

              // Priority
              DropdownButtonFormField<String>(
                value: _priority,
                dropdownColor: const Color(0xFF1E2130),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Priority Level',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _priority = val);
                },
              ),
              const SizedBox(height: 14.0),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Key Results / Notes (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Add deliverables or success metrics',
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
                        backgroundColor: const Color(0xFFA06CD5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: Text(
                        widget.initialMonthlyTask != null ? 'Save Changes' : 'SAVE',
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
