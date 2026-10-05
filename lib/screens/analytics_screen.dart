import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/charts/donut_chart_widget.dart';
import '../widgets/charts/spending_trend_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final monthKey = DateFormat('yyyy-MM').format(_selectedMonth);
    final monthTitle = DateFormat('MMMM yyyy').format(_selectedMonth);

    final allExpenses = provider.expenses;
    final totalAllTime = allExpenses.fold<double>(0.0, (acc, e) => acc + e.amount);

    final monthExpenses = allExpenses.where((e) => e.date.startsWith(monthKey)).toList();
    final totalMonth = monthExpenses.fold<double>(0.0, (acc, e) => acc + e.amount);

    final txCount = monthExpenses.length;
    final avgDaily = txCount > 0 ? (totalMonth / max(1, DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day)) : 0.0;

    // Highest Spending Category
    final categoryTotals = <String, double>{};
    for (final e in monthExpenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0.0) + e.amount;
    }
    String topCategory = 'None';
    double topCategoryAmt = 0.0;
    categoryTotals.forEach((cat, amt) {
      if (amt > topCategoryAmt) {
        topCategoryAmt = amt;
        topCategory = cat;
      }
    });

    // Highest Spending Day
    final dayTotals = <String, double>{};
    for (final e in monthExpenses) {
      dayTotals[e.date] = (dayTotals[e.date] ?? 0.0) + e.amount;
    }
    String topDay = 'None';
    double topDayAmt = 0.0;
    dayTotals.forEach((day, amt) {
      if (amt > topDayAmt) {
        topDayAmt = amt;
        topDay = day;
      }
    });
    if (topDay != 'None') {
      final dt = DateTime.tryParse(topDay);
      if (dt != null) topDay = DateFormat('MMM d').format(dt);
    }

    // Donut Chart Data
    final palette = [
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFF14B8A6),
      const Color(0xFFF43F5E),
    ];
    var pIdx = 0;
    final donutData = categoryTotals.entries.map((entry) {
      final color = palette[pIdx % palette.length];
      pIdx++;
      return DonutChartData(label: entry.key, value: entry.value, color: color);
    }).toList();

    // Last 7 Days Trend Data
    final trendPoints = <TrendDataPoint>[];
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dStr = DateFormat('yyyy-MM-dd').format(d);
      final label = DateFormat('E').format(d);
      final sum = allExpenses.where((e) => e.date == dStr).fold<double>(0.0, (acc, e) => acc + e.amount);
      trendPoints.add(TrendDataPoint(label: label, amount: sum));
    }

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
              // Header & Month Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FINANCIAL ANALYTICS',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        monthTitle,
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
              const SizedBox(height: 20),

              // 1. Core Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MONTHLY SPENDING',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.formatCurrency(totalMonth),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$txCount transactions',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL ALL-TIME',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.formatCurrency(totalAllTime),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lifetime spend',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAILY AVERAGE',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.formatCurrency(avgDaily),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Per day in $monthTitle',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HIGHEST SPEND DAY',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            topDay != 'None' ? provider.formatCurrency(topDayAmt) : '₹0',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            topDay != 'None' ? topDay : 'No activity',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24), // Section spacing

              // 2. Spending Trend Chart (Last 7 Days)
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '7-Day Spending Velocity',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Daily Distribution',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SpendingTrendWidget(
                      points: trendPoints,
                      currencySymbol: provider.settings.currencySymbol,
                      height: 130,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24), // Section spacing

              // 3. Category Breakdown Donut Chart
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Category Distribution',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        if (topCategory != 'None')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Top: $topCategory',
                              style: const TextStyle(color: Color(0xFFA5B4FC), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DonutChartWidget(
                      data: donutData,
                      centerTitle: provider.formatCurrency(totalMonth),
                      centerSubtitle: 'Month Total',
                      size: 190,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24), // Section spacing

              // 4. Productivity Summary Card
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Productivity Analytics',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    _buildProductivityRow(
                      'Total Tasks Created',
                      '${provider.tasks.length}',
                      Icons.checklist,
                      const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 10),
                    _buildProductivityRow(
                      'Completed Tasks',
                      '${provider.tasks.where((t) => t.completed).length}',
                      Icons.check_circle_outline,
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 10),
                    _buildProductivityRow(
                      'Monthly Goals',
                      '${provider.monthlyTasks.where((m) => m.completed).length} / ${provider.monthlyTasks.length}',
                      Icons.flag_outlined,
                      const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 10),
                    _buildProductivityRow(
                      'Active Routines',
                      '${provider.recurringTasks.where((r) => r.isActive).length}',
                      Icons.repeat,
                      const Color(0xFF8B5CF6),
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

  Widget _buildProductivityRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
