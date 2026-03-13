import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;
  static const String key = 'theme_mode_index';

  ThemeCubit({required this.prefs})
    : super(
        ThemeState(ThemeMode.values[prefs.getInt(key) ?? ThemeMode.dark.index]),
      );

  void setTheme(ThemeMode mode) {
    prefs.setInt(key, mode.index);
    emit(ThemeState(mode));
  }

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    setTheme(newMode);
  }
}
