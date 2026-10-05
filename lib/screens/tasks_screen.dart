import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_provider.dart';
import '../models/task.dart';
import '../widgets/glass_card.dart';
import '../widgets/dialogs/add_task_dialog.dart';
import '../widgets/dialogs/add_monthly_task_dialog.dart';
import '../widgets/dialogs/add_recurring_dialog.dart';
import '../widgets/dialogs/confirm_dialog.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Section: Title & Tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TASK MANAGEMENT',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Focus & Productivity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Three Distinct Tabs: Daily Tasks, Monthly Tasks, Routines
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF14141E).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Daily Tasks'),
                        Tab(text: 'Monthly Goals'),
                        Tab(text: 'Routines'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyTasksTab(provider),
                  _buildMonthlyTasksTab(provider),
                  _buildRoutinesTab(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: DAILY TASKS ---
  Widget _buildDailyTasksTab(AppProvider provider) {
    final tasks = provider.tasks;
    final categories = ['All', ...provider.taskCategories];

    final filtered = tasks.where((t) {
      final matchesCat = _selectedCategory == 'All' || t.category == _selectedCategory;
      final q = _searchController.text.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          (t.description != null && t.description!.toLowerCase().contains(q));
      return matchesCat && matchesSearch;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => provider.loadFromDatabase(),
      color: const Color(0xFF6366F1),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          // Search & Category Chips
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
              hintText: 'Search tasks...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF14141E).withValues(alpha: 0.8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
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
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Text(
                      tasks.isEmpty ? 'No tasks yet. Create your first task!' : 'No tasks match current search/filter',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => AddTaskDialog.show(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Task'),
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
            ...filtered.map((task) => _buildTaskItem(task, provider)),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskItem task, AppProvider provider) {
    final priorityColor = task.priority == 'high'
        ? const Color(0xFFEF4444)
        : task.priority == 'low'
            ? const Color(0xFF10B981)
            : const Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.completed ? const Color(0xFF10B981) : Colors.white38,
                    size: 24,
                  ),
                  onPressed: () => provider.toggleTaskCompleted(task.id),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: task.completed ? Colors.white38 : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          task.description!,
                          style: TextStyle(
                            color: task.completed ? Colors.white24 : Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
                  color: const Color(0xFF1E1E2C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onSelected: (val) async {
                    if (val == 'edit') {
                      AddTaskDialog.show(context, existingTask: task);
                    } else if (val == 'delete') {
                      final confirm = await ConfirmDialog.show(
                        context: context,
                        title: 'Delete Task',
                        message: 'Are you sure you want to delete "${task.title}"?',
                      );
                      if (confirm) await provider.deleteTask(task.id);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                          SizedBox(width: 10),
                          Text('Edit', style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom Meta Row: Priority, Category, Date/Time, Reminder
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${task.priority.toUpperCase()} PRIORITY',
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.category,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                  ),
                ),
                const Spacer(),
                Icon(Icons.schedule, color: Colors.white.withValues(alpha: 0.4), size: 14),
                const SizedBox(width: 4),
                Text(
                  task.time != null ? '${task.date} • ${task.time}' : task.date,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: MONTHLY GOALS ---
  Widget _buildMonthlyTasksTab(AppProvider provider) {
    final currentMonthYear = DateFormat('yyyy-MM').format(DateTime.now());
    final monthlyTasks = provider.monthlyTasks;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Goals for ${DateFormat('MMMM yyyy').format(DateTime.now())}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => AddMonthlyTaskDialog.show(context, initialMonthYear: currentMonthYear),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (monthlyTasks.isEmpty)
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.flag_outlined, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text(
                    'No monthly goals set yet.\nDefine big milestones to track throughout the month!',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...monthlyTasks.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        m.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: m.completed ? const Color(0xFF10B981) : Colors.white38,
                        size: 24,
                      ),
                      onPressed: () => provider.toggleMonthlyTaskCompleted(m.id),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: TextStyle(
                              color: m.completed ? Colors.white38 : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: m.completed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (m.notes != null && m.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              m.notes!,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            'Target Month: ${m.monthYear}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                      onPressed: () async {
                        final confirm = await ConfirmDialog.show(
                          context: context,
                          title: 'Delete Monthly Goal',
                          message: 'Are you sure you want to delete "${m.title}"?',
                        );
                        if (confirm) await provider.deleteMonthlyTask(m.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 80),
      ],
    );
  }

  // --- TAB 3: ROUTINES ---
  Widget _buildRoutinesTab(AppProvider provider) {
    final routines = provider.recurringTasks;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Habits & Recurring Routines',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => AddRecurringDialog.show(context, initialType: 1),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Routine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (routines.isEmpty)
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.repeat, size: 48, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text(
                    'No recurring routines configured yet.\nSet up habits like daily workouts, weekly reading, etc.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...routines.map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fitness_center, color: Color(0xFFA5B4FC), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${r.category} • ${r.frequency} • Next: ${r.nextDueDate}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => provider.completeRecurringTask(r.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Check In', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final confirm = await ConfirmDialog.show(
                              context: context,
                              title: 'Delete Routine',
                              message: 'Are you sure you want to delete "${r.title}"?',
                            );
                            if (confirm) await provider.deleteRecurringTask(r.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 80),
      ],
    );
  }
}
