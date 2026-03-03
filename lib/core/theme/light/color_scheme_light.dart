import 'package:flutter/material.dart';

class ColorSchemeLight {
  ColorSchemeLight._init();
  static ColorSchemeLight? _instance;
  static ColorSchemeLight get instance {
    _instance ??= ColorSchemeLight._init();
    return _instance!;
  }

  // Primary
  final Color primary = const Color(0xFF2563EB);
  final Color primaryVariant = const Color(0xFF1D4ED8);
  final Color onPrimary = const Color(0xFFFFFFFF);
  final Color primaryLight = const Color(0xFFDBEAFE);

  // Secondary
  final Color secondary = const Color(0xFF0D9488);
  final Color secondaryVariant = const Color(0xFF0F766E);
  final Color onSecondary = const Color(0xFFFFFFFF);

  // Background
  final Color background = const Color(0xFFFAFBFC);
  final Color surface = const Color(0xFFFFFFFF);
  final Color onBackground = const Color(0xFF111827);
  final Color onSurface = const Color(0xFF111827);

  // Error
  final Color error = const Color(0xFFDC2626);
  final Color onError = const Color(0xFFFFFFFF);

  // Custom colors
  final Color cardBackground = const Color(0xFFFFFFFF);
  final Color divider = const Color(0xFFE5E7EB);
  final Color shimmerBase = const Color(0xFFE5E7EB);
  final Color shimmerHighlight = const Color(0xFFF3F4F6);

  // Text colors
  final Color textPrimary = const Color(0xFF111827);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color textHint = const Color(0xFF9CA3AF);

  // Status colors
  final Color success = const Color(0xFF059669);
  final Color warning = const Color(0xFFD97706);
  final Color info = const Color(0xFF2563EB);
}
