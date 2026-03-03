import 'package:flutter/material.dart';

class ColorSchemeLight {
  ColorSchemeLight._init();
  static ColorSchemeLight? _instance;
  static ColorSchemeLight get instance {
    _instance ??= ColorSchemeLight._init();
    return _instance!;
  }

  // Primary
  final Color primary = const Color(0xFF6200EE);
  final Color primaryVariant = const Color(0xFF3700B3);
  final Color onPrimary = const Color(0xFFFFFFFF);

  // Secondary
  final Color secondary = const Color(0xFF03DAC6);
  final Color secondaryVariant = const Color(0xFF018786);
  final Color onSecondary = const Color(0xFF000000);

  // Background
  final Color background = const Color(0xFFF5F5F5);
  final Color surface = const Color(0xFFFFFFFF);
  final Color onBackground = const Color(0xFF121212);
  final Color onSurface = const Color(0xFF121212);

  // Error
  final Color error = const Color(0xFFB00020);
  final Color onError = const Color(0xFFFFFFFF);

  // Custom colors
  final Color cardBackground = const Color(0xFFFFFFFF);
  final Color divider = const Color(0xFFE0E0E0);
  final Color shimmerBase = const Color(0xFFE0E0E0);
  final Color shimmerHighlight = const Color(0xFFF5F5F5);

  // Text colors
  final Color textPrimary = const Color(0xFF212121);
  final Color textSecondary = const Color(0xFF757575);
  final Color textHint = const Color(0xFFBDBDBD);

  // Status colors
  final Color success = const Color(0xFF4CAF50);
  final Color warning = const Color(0xFFFF9800);
  final Color info = const Color(0xFF2196F3);
}
