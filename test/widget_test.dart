import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aether_finance_tasks/widgets/glass_card.dart';
import 'package:aether_finance_tasks/widgets/empty_state.dart';

void main() {
  testWidgets('GlassCard and EmptyState smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            child: EmptyState(
              icon: Icons.task_alt,
              title: 'No Tasks',
              description: 'Add a new task to get started',
            ),
          ),
        ),
      ),
    );

    expect(find.text('No Tasks'), findsOneWidget);
    expect(find.text('Add a new task to get started'), findsOneWidget);
  });
}
