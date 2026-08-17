import 'package:flutter/material.dart';

/// Centralized color palette for SpendTime.
///
/// Keep all raw color values here. Widgets and other theme files
/// should reference these constants instead of hardcoding hex codes,
/// so the app's palette can be updated from a single place.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2D5DF0);
  static const Color secondary = Color(0xFF00B894);

  // Neutrals
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);

  // Status
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF2ECC71);
}