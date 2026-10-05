import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/important_date.dart';
import '../../state/app_provider.dart';

class AddImportantDateDialog extends StatefulWidget {
  final ImportantDate? initialDate;
  final String? defaultDate;

  const AddImportantDateDialog({super.key, this.initialDate, this.defaultDate});

  static Future<void> show(BuildContext context, {ImportantDate? existingDate, String? initialDate}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddImportantDateDialog(initialDate: existingDate, defaultDate: initialDate),
    );
  }

  @override
  State<AddImportantDateDialog> createState() => _AddImportantDateDialogState();
}

class _AddImportantDateDialogState extends State<AddImportantDateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late String _category;
  late String _reminder;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _categories = [
    'Birthday',
    'Anniversary',
    'Exam',
    'Interview',
    'Project Deadline',
    'Appointment',
    'Payment Due',
    'Event',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialDate;
    _titleController = TextEditingController(text: d?.title ?? '');
    _notesController = TextEditingController(text: d?.notes ?? '');
    _category = d?.category ?? 'Event';
    _reminder = d?.reminder ?? '1d';

    if (d != null) {
      _selectedDate = DateTime.tryParse(d.date) ?? DateTime.now();
      if (d.time != null && d.time!.contains(':')) {
        final parts = d.time!.split(':');
        _selectedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    } else if (widget.defaultDate != null) {
      _selectedDate = DateTime.tryParse(widget.defaultDate!) ?? DateTime.now();
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    }
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
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : null;

    if (widget.initialDate != null) {
      final updated = widget.initialDate!.copyWith(
        title: _titleController.text.trim(),
        date: dateStr,
        time: timeStr,
        category: _category,
        notes: _notesController.text.trim(),
        reminder: _reminder,
      );
      await provider.updateImportantDate(updated);
    } else {
      await provider.addImportantDate(
        title: _titleController.text.trim(),
        date: dateStr,
        time: timeStr,
        category: _category,
        notes: _notesController.text.trim(),
        reminder: _reminder,
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
                widget.initialDate != null ? 'Edit Important Date' : 'Add Important Date',
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 18.0),

              // Title (Custom user-controlled)
              TextFormField(
                controller: _titleController,
                autofocus: widget.initialDate == null,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Event / Milestone Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter title (e.g. Birthday, Exam, Meeting)',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a title';
                  return null;
                },
              ),
              const SizedBox(height: 14.0),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: const Color(0xFF1E2130),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
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

              // Reminder
              DropdownButtonFormField<String>(
                value: _reminder,
                dropdownColor: const Color(0xFF1E2130),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Reminder Notice',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('No reminder')),
                  DropdownMenuItem(value: 'at_time', child: Text('At time of event')),
                  DropdownMenuItem(value: '1h', child: Text('1 hour before')),
                  DropdownMenuItem(value: '1d', child: Text('1 day before')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _reminder = val);
                },
              ),
              const SizedBox(height: 14.0),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Notes / Location / Preparation',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter notes or details',
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
                        backgroundColor: const Color(0xFF4CC9F0),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: Text(
                        widget.initialDate != null ? 'Save Changes' : 'SAVE',
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
