import 'package:flutter/material.dart';

class FloatingActionSpeedDial extends StatefulWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onAddTask;
  final VoidCallback onAddMonthlyTask;
  final VoidCallback onAddImportantDate;
  final VoidCallback onAddRecurring;

  const FloatingActionSpeedDial({
    super.key,
    required this.onAddExpense,
    required this.onAddTask,
    required this.onAddMonthlyTask,
    required this.onAddImportantDate,
    required this.onAddRecurring,
  });

  @override
  State<FloatingActionSpeedDial> createState() => _FloatingActionSpeedDialState();
}

class _FloatingActionSpeedDialState extends State<FloatingActionSpeedDial> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _handleItem(VoidCallback action) {
    _toggle();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Backdrop overlay when speed dial is open
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withValues(alpha: 0.50),
              ),
            ),
          ),

        Positioned(
          bottom: 96.0,
          right: 20.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isOpen) ...[
                _buildMenuItem(
                  icon: Icons.repeat_rounded,
                  label: 'Recurring Item',
                  color: const Color(0xFFFF1053),
                  onTap: () => _handleItem(widget.onAddRecurring),
                ),
                const SizedBox(height: 12.0),
                _buildMenuItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Important Date',
                  color: const Color(0xFF4CC9F0),
                  onTap: () => _handleItem(widget.onAddImportantDate),
                ),
                const SizedBox(height: 12.0),
                _buildMenuItem(
                  icon: Icons.flag_rounded,
                  label: 'Monthly Goal',
                  color: const Color(0xFFA06CD5),
                  onTap: () => _handleItem(widget.onAddMonthlyTask),
                ),
                const SizedBox(height: 12.0),
                _buildMenuItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Daily Task',
                  color: const Color(0xFF06D6A0),
                  onTap: () => _handleItem(widget.onAddTask),
                ),
                const SizedBox(height: 12.0),
                _buildMenuItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Expense',
                  color: const Color(0xFFFFD166),
                  onTap: () => _handleItem(widget.onAddExpense),
                ),
                const SizedBox(height: 16.0),
              ],

              // Main Trigger Button
              FloatingActionButton(
                onPressed: _toggle,
                backgroundColor: const Color(0xFFFF1053),
                foregroundColor: Colors.white,
                elevation: 8,
                shape: const CircleBorder(),
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.125).animate(_controller),
                  child: const Icon(Icons.add_rounded, size: 30),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xEE161822),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        FloatingActionButton.small(
          onPressed: onTap,
          backgroundColor: color,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: const CircleBorder(),
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }
}
