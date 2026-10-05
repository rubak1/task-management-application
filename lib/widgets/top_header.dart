import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSearchTap;

  const TopHeader({
    super.key,
    required this.title,
    required this.onSearchTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Color(0xFFFF1053),
                  ),
                ),
                const SizedBox(height: 6.0), // 6-10 dp spacing
                Text(
                  title.isNotEmpty ? title : dateStr,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSearchTap,
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              ),
              padding: const EdgeInsets.all(12.0),
            ),
          ),
        ],
      ),
    );
  }
}
