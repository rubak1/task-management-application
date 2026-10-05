import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import '../services/export_import_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _categoryController = TextEditingController();
  String _categoryType = 'expense';

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context, AppProvider provider) {
    _categoryController.clear();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF14141E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Custom Category',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Expense'),
                        selected: _categoryType == 'expense',
                        onSelected: (val) {
                          if (val) setDialogState(() => _categoryType = 'expense');
                        },
                        selectedColor: const Color(0xFF6366F1),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Task'),
                        selected: _categoryType == 'task',
                        onSelected: (val) {
                          if (val) setDialogState(() => _categoryType = 'task');
                        },
                        selectedColor: const Color(0xFF6366F1),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _categoryController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. College Expenses, Fitness',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final name = _categoryController.text.trim();
                        if (name.isNotEmpty) {
                          await provider.addCustomCategory(name, _categoryType);
                          if (context.mounted) Navigator.of(ctx).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add Category'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final settings = provider.settings;

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
              // Header
              Text(
                'PREFERENCES & SYSTEM',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Currency & Default Budget Card
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Preferences',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.currency_exchange, color: Color(0xFFA5B4FC), size: 20),
                      ),
                      title: const Text('Currency Symbol', style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text('Current: ${settings.currencySymbol}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                      trailing: DropdownButton<String>(
                        value: settings.currencySymbol,
                        dropdownColor: const Color(0xFF1E1E2C),
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        items: ['₹', '\$', '€', '£', '¥', '₩'].map((sym) {
                          return DropdownMenuItem(value: sym, child: Text(sym));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            provider.updateSettings(settings.copyWith(currencySymbol: val));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Custom Categories Management
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddCategoryDialog(context, provider),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Custom'),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF818CF8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expense Categories',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.expenseCategories.map((c) {
                        return Chip(
                          label: Text(c, style: const TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                          deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white38),
                          onDeleted: () => provider.removeCustomCategory(c, 'expense'),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Task Categories',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.taskCategories.map((c) {
                        return Chip(
                          label: Text(c, style: const TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                          deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white38),
                          onDeleted: () => provider.removeCustomCategory(c, 'task'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Performance & Animation Options
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Display & Performance',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Battery Saver / Reduced Motion', style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(
                        'Simplifies background particle physics to save battery on low-end devices',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                      ),
                      value: settings.reducedMotion,
                      activeThumbColor: const Color(0xFF6366F1),
                      onChanged: (val) {
                        provider.updateSettings(settings.copyWith(reducedMotion: val));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 4. Notifications & Testing
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF34D399), size: 20),
                      ),
                      title: const Text('Test Notification Alert', style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(
                        'Send a real-time notification to verify phone sound and vibration',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          NotificationService.instance.showInstantNotification(
                            id: 9999,
                            title: 'Aether Notification Active',
                            body: 'Your local notifications are enabled and functioning properly.',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Test notification dispatched')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Test', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 5. Data Backup & Export / Import
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Backup & Portability',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await ExportImportService.instance.exportAndShareJson();
                            },
                            icon: const Icon(Icons.file_download_outlined, size: 18),
                            label: const Text('Backup JSON'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await ExportImportService.instance.exportAndShareExpensesCsv();
                            },
                            icon: const Icon(Icons.table_chart_outlined, size: 18),
                            label: const Text('Export CSV'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24), // Section spacing

              // 6. Danger Zone (Explicit Deletion Confirmation)
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Danger Zone',
                          style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Permanently erase all stored records (expenses, tasks, dates, budgets) from the SQLite database.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await ConfirmDialog.show(
                          context: context,
                          title: 'Reset All Data',
                          message:
                              'Are you absolutely sure you want to delete all stored expenses, tasks, budgets, and dates? This action cannot be reversed.',
                          confirmLabel: 'Erase Everything',
                          confirmColor: const Color(0xFFDC2626),
                        );
                        if (confirmed) {
                          await provider.resetAllData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All data has been cleared')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Erase All Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
