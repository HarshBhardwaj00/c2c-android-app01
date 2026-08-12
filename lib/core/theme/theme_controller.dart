import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide theme mode controller.
///
/// Persists the selected [ThemeMode] (light / dark / system) locally via
/// [SharedPreferences] so the choice survives restarts and applies globally
/// (Settings screen proxies the value to the backend as well).
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const String _prefsKey = 'app_theme_mode';

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  String get modeKey => _modeKeyFor(_mode);

  /// Restores the persisted theme mode. Safe to call once at startup.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      if (stored != null) {
        _mode = _modeFor(stored);
        notifyListeners();
      }
    } catch (_) {
      // Non-fatal: fall back to light when storage is unavailable.
    }
  }

  /// Applies and persists a new theme mode.
  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _modeKeyFor(mode));
    } catch (_) {
      // Non-fatal: theme still applies for the current session.
    }
  }

  static String _modeKeyFor(ThemeMode mode) => switch (mode) {
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
    ThemeMode.light => 'light',
  };

  static ThemeMode _modeFor(String key) => switch (key) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };
}
