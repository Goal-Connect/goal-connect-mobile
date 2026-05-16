import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleState extends Equatable {
  final Locale? locale;

  const LocaleState(this.locale);

  bool get followSystem => locale == null;

  @override
  List<Object?> get props => [locale];
}
