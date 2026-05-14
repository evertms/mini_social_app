import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/preferences/prefs_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PrefsService _prefsService;

  ThemeCubit(this._prefsService) 
      : super(_prefsService.getTheme() ? ThemeMode.dark : ThemeMode.light);

  Future<void> toggleTheme() async {
    final isDark = state == ThemeMode.dark;
    await _prefsService.setTheme(!isDark);
    emit(!isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
