import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextThemeLight {
  TextThemeLight._init();
  static TextThemeLight? _instance;
  static TextThemeLight get instance {
    _instance ??= TextThemeLight._init();
    return _instance!;
  }

  String get _fontFamily =>
      GoogleFonts.plusJakartaSans().fontFamily ?? 'Roboto';

  // Display
  TextStyle get displayLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      );

  TextStyle get displayMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
      );

  TextStyle get displaySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
      );

  // Headlines
  TextStyle get headlineLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
      );

  TextStyle get headlineMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.29,
      );

  TextStyle get headlineSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.33,
      );

  // Title
  TextStyle get titleLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.27,
      );

  TextStyle get titleMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.5,
      );

  TextStyle get titleSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.43,
      );

  // Body
  TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
      );

  TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.43,
      );

  TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.33,
      );

  // Label
  TextStyle get labelLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.43,
      );

  TextStyle get labelMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.33,
      );

  TextStyle get labelSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.45,
      );
}
