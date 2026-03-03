import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/cache_keys.dart';
import '../../../../core/cache/cache_manager.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final bool isDark;

  const ThemeState({
    required this.themeMode,
    required this.isDark,
  });

  factory ThemeState.initial() => const ThemeState(
        themeMode: ThemeMode.system,
        isDark: false,
      );

  ThemeState copyWith({ThemeMode? themeMode, bool? isDark}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  List<Object?> get props => [themeMode, isDark];
}

class ThemeCubit extends Cubit<ThemeState> {
  final CacheManager _cacheManager;

  ThemeCubit(this._cacheManager) : super(ThemeState.initial()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = _cacheManager.getString(CacheKeys.themeMode);
    if (savedTheme != null) {
      final themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
      emit(ThemeState(
        themeMode: themeMode,
        isDark: themeMode == ThemeMode.dark,
      ));
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _cacheManager.setString(CacheKeys.themeMode, mode.name);
    emit(ThemeState(
      themeMode: mode,
      isDark: mode == ThemeMode.dark,
    ));
  }

  Future<void> toggleTheme() async {
    final newMode = state.isDark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }
}
