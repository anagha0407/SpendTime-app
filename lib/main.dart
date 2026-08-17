import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const SpendTimeApp());
}

class SpendTimeApp extends StatelessWidget {
  const SpendTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendTime',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainNavigationScreen(),
    );
  }
}