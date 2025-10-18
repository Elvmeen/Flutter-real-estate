import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  static const String storageKey = 'favorite_house_ids_v1';

  FavoritesNotifier() : super(<int>{}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(storageKey) ?? <String>[];
    state = ids.map(int.parse).toSet();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      storageKey,
      state.map((e) => e.toString()).toList(growable: false),
    );
  }

  Future<void> toggle(int houseId) async {
    final next = Set<int>.from(state);
    if (next.contains(houseId)) {
      next.remove(houseId);
    } else {
      next.add(houseId);
    }
    state = next;
    await _persist();
  }

  bool isFavorite(int houseId) => state.contains(houseId);
}
