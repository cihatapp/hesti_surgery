import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import 'color_scheme_light.dart';
import 'text_theme_light.dart';

final class LightTheme extends AppTheme {
  LightTheme._init();
  static LightTheme? _instance;
  static LightTheme get instance {
    _instance ??= LightTheme._init();
    return _instance!;
  }

  final _colors = ColorSchemeLight.instance;
  final _textTheme = TextThemeLight.instance;

  @override
  ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // Colors
        primaryColor: _colors.primary,
        scaffoldBackgroundColor: _colors.background,
        dividerColor: _colors.divider,

        colorScheme: ColorScheme.light(
          primary: _colors.primary,
          onPrimary: _colors.onPrimary,
          secondary: _colors.secondary,
          onSecondary: _colors.onSecondary,
          surface: _colors.surface,
          onSurface: _colors.onSurface,
          error: _colors.error,
          onError: _colors.onError,
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge:
              _textTheme.displayLarge.copyWith(color: _colors.textPrimary),
          displayMedium:
              _textTheme.displayMedium.copyWith(color: _colors.textPrimary),
          displaySmall:
              _textTheme.displaySmall.copyWith(color: _colors.textPrimary),
          headlineLarge:
              _textTheme.headlineLarge.copyWith(color: _colors.textPrimary),
          headlineMedium:
              _textTheme.headlineMedium.copyWith(color: _colors.textPrimary),
          headlineSmall:
              _textTheme.headlineSmall.copyWith(color: _colors.textPrimary),
          titleLarge:
              _textTheme.titleLarge.copyWith(color: _colors.textPrimary),
          titleMedium:
              _textTheme.titleMedium.copyWith(color: _colors.textPrimary),
          titleSmall:
              _textTheme.titleSmall.copyWith(color: _colors.textSecondary),
          bodyLarge: _textTheme.bodyLarge.copyWith(color: _colors.textPrimary),
          bodyMedium:
              _textTheme.bodyMedium.copyWith(color: _colors.textSecondary),
          bodySmall:
              _textTheme.bodySmall.copyWith(color: _colors.textSecondary),
          labelLarge:
              _textTheme.labelLarge.copyWith(color: _colors.textPrimary),
          labelMedium:
              _textTheme.labelMedium.copyWith(color: _colors.textSecondary),
          labelSmall: _textTheme.labelSmall.copyWith(color: _colors.textHint),
        ),

        // AppBar
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: _colors.surface,
          foregroundColor: _colors.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle:
              _textTheme.titleLarge.copyWith(color: _colors.textPrimary),
        ),

        // Card
        cardTheme: CardThemeData(
          elevation: 0,
          color: _colors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _colors.primary,
            foregroundColor: _colors.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: _textTheme.labelLarge,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _colors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: _colors.primary),
            textStyle: _textTheme.labelLarge,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _colors.primary,
            textStyle: _textTheme.labelLarge,
          ),
        ),

        // Input
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _colors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _colors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _colors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _colors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: _textTheme.bodyMedium.copyWith(color: _colors.textHint),
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: _colors.surface,
          selectedItemColor: _colors.primary,
          unselectedItemColor: _colors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _colors.onSurface,
          contentTextStyle:
              _textTheme.bodyMedium.copyWith(color: _colors.surface),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: _colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Floating Action Button
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _colors.primary,
          foregroundColor: _colors.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Divider
        dividerTheme: DividerThemeData(
          color: _colors.divider,
          thickness: 1,
          space: 1,
        ),
      );
}
