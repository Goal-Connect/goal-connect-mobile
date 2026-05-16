import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  final SharedPreferences prefs;
  static const String key = 'app_locale_code';
  static const String systemSentinel = 'system';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('am'),
    Locale('om'),
  ];

  LocaleCubit({required this.prefs}) : super(_load(prefs));

  static LocaleState _load(SharedPreferences prefs) {
    final code = prefs.getString(key);
    if (code == null || code == systemSentinel) {
      return const LocaleState(null);
    }
    final match = supportedLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => const Locale('en'),
    );
    return LocaleState(match);
  }

  void setLocale(Locale? locale) {
    if (locale == null) {
      prefs.setString(key, systemSentinel);
    } else {
      prefs.setString(key, locale.languageCode);
    }
    emit(LocaleState(locale));
  }
}
