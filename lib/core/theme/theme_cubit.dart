import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;
  static const String key = 'theme_mode';

  ThemeCubit({required this.prefs})
    : super(
        ThemeState(
          prefs.getBool(key) ?? true ? ThemeMode.light : ThemeMode.dark,
        ),
      );

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    prefs.setBool(key, newMode == ThemeMode.light);
    emit(ThemeState(newMode));
  }
}
