import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    final box = Hive.box('settings');
    final saved = box.get('themeMode', defaultValue: 'light');
    state = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void setMode(ThemeMode mode) {
    state = mode;
    Hive.box('settings').put('themeMode', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void toggle() => setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  return AccentColorNotifier();
});

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(const Color(0xFFE8547A)) {
    final box = Hive.box('settings');
    final savedHex = box.get('accentColor', defaultValue: 0xFFE8547A);
    state = Color(savedHex);
  }

  void setColor(Color color) {
    state = color;
    Hive.box('settings').put('accentColor', color.value);
  }

  static const presets = [
    Color(0xFFE8547A), // Pink (default)
    Color(0xFFFF6B35), // Orange
    Color(0xFF7B2FBE), // Violet
    Color(0xFF00BCD4), // Cyan
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Amber
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Purple
  ];
}

final apiSourceProvider = StateNotifierProvider<ApiSourceNotifier, String>((ref) {
  return ApiSourceNotifier();
});

class ApiSourceNotifier extends StateNotifier<String> {
  ApiSourceNotifier() : super('youtube') {
    final saved = Hive.box('settings').get('apiSource', defaultValue: 'youtube');
    state = saved;
  }

  void setSource(String source) {
    state = source;
    Hive.box('settings').put('apiSource', source);
  }

  static const sources = ['youtube', 'jiosaavn', 'deezer', 'audius'];
}
