import 'package:flutter/material.dart';

/// Simple data holder for a time category on the dashboard.
/// This is a plain model with no logic — later this can be backed
/// by a database or API without changing how widgets use it.
class CategoryTime {
  final String name;
  final IconData icon;
  final Duration duration;
  final double percentage; // 0.0 - 1.0, share of today's tracked time
  final Color color;

  const CategoryTime({
    required this.name,
    required this.icon,
    required this.duration,
    required this.percentage,
    required this.color,
  });
}