import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider = StateNotifierProvider<FavoriteIdsController, Set<int>>((ref) {
  return FavoriteIdsController()..load();
});

class FavoriteIdsController extends StateNotifier<Set<int>> {
  FavoriteIdsController() : super(<int>{});

  static const String _prefsKey = 'favorite_ids';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null && stored.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(stored) as List<dynamic>;
      state = decoded.map((e) => e as int).toSet();
    }
  }

  Future<void> toggle(int id) async {
    final next = Set<int>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(state.toList()));
  }
}
