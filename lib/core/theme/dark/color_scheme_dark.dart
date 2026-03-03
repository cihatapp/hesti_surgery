import 'package:flutter/material.dart';

class ColorSchemeDark {
  ColorSchemeDark._init();
  static ColorSchemeDark? _instance;
  static ColorSchemeDark get instance {
    _instance ??= ColorSchemeDark._init();
    return _instance!;
  }

  // Primary
  final Color primary = const Color(0xFF60A5FA);
  final Color primaryVariant = const Color(0xFF3B82F6);
  final Color onPrimary = const Color(0xFF0F172A);
  final Color primaryLight = const Color(0xFF1E3A5F);

  // Secondary
  final Color secondary = const Color(0xFF2DD4BF);
  final Color secondaryVariant = const Color(0xFF14B8A6);
  final Color onSecondary = const Color(0xFF0F172A);

  // Background
  final Color background = const Color(0xFF0F172A);
  final Color surface = const Color(0xFF1E293B);
  final Color onBackground = const Color(0xFFF1F5F9);
  final Color onSurface = const Color(0xFFF1F5F9);

  // Error
  final Color error = const Color(0xFFFCA5A5);
  final Color onError = const Color(0xFF0F172A);

  // Custom colors
  final Color cardBackground = const Color(0xFF1E293B);
  final Color divider = const Color(0xFF334155);
  final Color shimmerBase = const Color(0xFF334155);
  final Color shimmerHighlight = const Color(0xFF475569);

  // Text colors
  final Color textPrimary = const Color(0xFFF1F5F9);
  final Color textSecondary = const Color(0xFF94A3B8);
  final Color textHint = const Color(0xFF64748B);

  // Status colors
  final Color success = const Color(0xFF34D399);
  final Color warning = const Color(0xFFFBBF24);
  final Color info = const Color(0xFF60A5FA);
}
