import 'package:flutter/material.dart';
import '../services/tracking_service.dart';
import '../services/expense_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'home_screen.dart';

/// Hosts the bottom navigation bar and owns the shared service
/// instances (TrackingService, ExpenseService) for the app's lifetime.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final TrackingService _trackingService;
  late final ExpenseService _expenseService;

 @override
  void initState() {
    super.initState();
    _trackingService = TrackingService();
    _expenseService = ExpenseService();
    _expenseService.loadExpenses(); // load saved expenses on app start
  }

  @override
  void dispose() {
    _trackingService.dispose();
    _expenseService.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        trackingService: _trackingService,
        expenseService: _expenseService,
      ),
      const _PlaceholderScreen(label: 'Insights'),
      const _PlaceholderScreen(label: 'History'),
      const _PlaceholderScreen(label: 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Simple "coming soon" placeholder for not-yet-built sections.
class _PlaceholderScreen extends StatelessWidget {
  final String label;

  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text('$label — coming soon', style: AppTextStyles.body),
      ),
    );
  }
}