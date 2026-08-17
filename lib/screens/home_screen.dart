import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Placeholder home screen.
///
/// Confirms the SpendTime theme is wired up correctly. Will be
/// replaced/expanded once real features (tracking, budgets, etc.)
/// are added.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SpendTime')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timelapse_rounded,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text('Welcome to SpendTime', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              Text(
                'Your theme is set up and ready to go.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}