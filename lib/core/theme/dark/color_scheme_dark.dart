import 'package:flutter/material.dart';

class ColorSchemeDark {
  ColorSchemeDark._init();
  static ColorSchemeDark? _instance;
  static ColorSchemeDark get instance {
    _instance ??= ColorSchemeDark._init();
    return _instance!;
  }

  // Primary
  final Color primary = const Color(0xFFBB86FC);
  final Color primaryVariant = const Color(0xFF3700B3);
  final Color onPrimary = const Color(0xFF000000);

  // Secondary
  final Color secondary = const Color(0xFF03DAC6);
  final Color secondaryVariant = const Color(0xFF03DAC6);
  final Color onSecondary = const Color(0xFF000000);

  // Background
  final Color background = const Color(0xFF121212);
  final Color surface = const Color(0xFF1E1E1E);
  final Color onBackground = const Color(0xFFFFFFFF);
  final Color onSurface = const Color(0xFFFFFFFF);

  // Error
  final Color error = const Color(0xFFCF6679);
  final Color onError = const Color(0xFF000000);

  // Custom colors
  final Color cardBackground = const Color(0xFF1E1E1E);
  final Color divider = const Color(0xFF2C2C2C);
  final Color shimmerBase = const Color(0xFF2C2C2C);
  final Color shimmerHighlight = const Color(0xFF3C3C3C);

  // Text colors
  final Color textPrimary = const Color(0xFFFFFFFF);
  final Color textSecondary = const Color(0xFFB3B3B3);
  final Color textHint = const Color(0xFF757575);

  // Status colors
  final Color success = const Color(0xFF81C784);
  final Color warning = const Color(0xFFFFB74D);
  final Color info = const Color(0xFF64B5F6);
}
