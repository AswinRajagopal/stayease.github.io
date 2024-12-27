import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String _themeKey = "themeMode";
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box('settings');
    final themeIndex = box.get(_themeKey, defaultValue: ThemeMode.light.index) as int;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Notify the app to rebuild

    final box = Hive.box('settings');
    box.put(_themeKey, mode.index); // Save the theme mode in Hive
  }
}
