import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final alertsProvider = StateNotifierProvider<AlertsNotifier, bool>((ref) {
  return AlertsNotifier();
});

class AlertsNotifier extends StateNotifier<bool> {
  static const storageKey = 'alerts_enabled_v1';
  AlertsNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(storageKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKey, state);
  }
}
