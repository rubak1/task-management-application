import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'state/app_provider.dart';
import 'database/app_database.dart';
import 'services/notification_service.dart';
import 'animations/background_controller.dart';

import 'widgets/top_header.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/floating_action_speed_dial.dart';
import 'widgets/dialogs/global_search_dialog.dart';
import 'widgets/dialogs/add_expense_dialog.dart';
import 'widgets/dialogs/add_task_dialog.dart';
import 'widgets/dialogs/add_monthly_task_dialog.dart';
import 'widgets/dialogs/add_important_date_dialog.dart';
import 'widgets/dialogs/add_recurring_dialog.dart';

import 'screens/home_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark cinematic immersion
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF07070A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SQLite database
  await AppDatabase.instance.database;

  // Initialize local notifications
  await NotificationService.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const AetherApp(),
    ),
  );
}

class AetherApp extends StatelessWidget {
  const AetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07070A),
        primaryColor: const Color(0xFF6366F1),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFFFF1053),
          surface: Color(0xFF14141E),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return ''; // Home will display dynamic greeting and date
      case 1:
        return 'Expenses & Budget';
      case 2:
        return 'Tasks & Habits';
      case 3:
        return 'Calendar & Agenda';
      case 4:
        return 'Financial Telemetry';
      case 5:
        return 'Settings & Data';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (!provider.isLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF07070A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    final currentIndex = provider.selectedTabIndex;

    final screens = const [
      HomeScreen(),
      ExpensesScreen(),
      TasksScreen(),
      CalendarScreen(),
      AnalyticsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF07070A),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Dynamic Cinematic Animated Background
          BackgroundController(
            activeTabIndex: currentIndex,
            reducedMotion: provider.settings.reducedMotion,
          ),

          // 2. Foreground User Interface
          SafeArea(
            child: Column(
              children: [
                // Top Global Header
                TopHeader(
                  title: _getScreenTitle(currentIndex),
                  onSearchTap: () => GlobalSearchDialog.show(context),
                ),

                // Main Content Screen
                Expanded(
                  child: screens[currentIndex],
                ),
              ],
            ),
          ),

          // 3. Floating Action Speed Dial
          FloatingActionSpeedDial(
            onAddExpense: () => AddExpenseDialog.show(context),
            onAddTask: () => AddTaskDialog.show(context),
            onAddMonthlyTask: () => AddMonthlyTaskDialog.show(context),
            onAddImportantDate: () => AddImportantDateDialog.show(context),
            onAddRecurring: () => AddRecurringDialog.show(context),
          ),

          // 4. Custom Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNav(
              currentIndex: currentIndex,
              onTap: (index) => provider.setTabIndex(index),
            ),
          ),
        ],
      ),
    );
  }
}
