import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteHousesNotifier extends StateNotifier<Set<int>> {
  FavoriteHousesNotifier() : super(<int>{});

  static const String _prefsKey = 'favorite_house_ids_v1';

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      state = <int>{};
      return;
    }
    try {
      final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
      state = decoded.map((e) => e as int).toSet();
    } catch (_) {
      state = <int>{};
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(state.toList()));
  }

  bool isFavorite(int houseId) => state.contains(houseId);

  Future<void> toggleFavorite(int houseId) async {
    final next = Set<int>.from(state);
    if (next.contains(houseId)) {
      next.remove(houseId);
    } else {
      next.add(houseId);
    }
    state = next;
    await _persist();
  }
}

final favoriteHousesProvider =
    StateNotifierProvider<FavoriteHousesNotifier, Set<int>>((ref) {
  final notifier = FavoriteHousesNotifier();
  notifier.loadFavorites();
  return notifier;
});
