import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  bool _isNotificationsEnabled = true;
  bool _isHapticFeedbackEnabled = true;

  SettingsProvider(this._prefs) {
    _loadSettings();
  }

  bool get isNotificationsEnabled => _isNotificationsEnabled;
  bool get isHapticFeedbackEnabled => _isHapticFeedbackEnabled;

  ThemeMode get themeMode => ThemeMode.light; // Fixed to light mode

  void _loadSettings() {
    _isNotificationsEnabled = _prefs.getBool('isNotificationsEnabled') ?? true;
    _isHapticFeedbackEnabled = _prefs.getBool('isHapticFeedbackEnabled') ?? true;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _isNotificationsEnabled = value;
    await _prefs.setBool('isNotificationsEnabled', value);
    _triggerHaptic();
    notifyListeners();
  }

  Future<void> toggleHapticFeedback(bool value) async {
    _isHapticFeedbackEnabled = value;
    await _prefs.setBool('isHapticFeedbackEnabled', value);
    _triggerHaptic();
    notifyListeners();
  }

  void _triggerHaptic() {
    if (_isHapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void triggerFeedback() {
    _triggerHaptic();
  }
}
