import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/house_model.dart';

// StateNotifier to manage the list of favorite properties
class FavoritesNotifier extends StateNotifier<List<HouseData>> {
  FavoritesNotifier() : super([]);

  // Add a property to favorites
  void addFavorite(HouseData house) {
    if (!state.any((h) => h.id == house.id)) {
      state = [...state, house];
    }
  }

  // Remove a property from favorites
  void removeFavorite(int houseId) {
    state = state.where((house) => house.id != houseId).toList();
  }

  // Check if a property is in favorites
  bool isFavorite(int houseId) {
    return state.any((house) => house.id == houseId);
  }

  // Toggle favorite status
  void toggleFavorite(HouseData house) {
    if (isFavorite(house.id)) {
      removeFavorite(house.id);
    } else {
      addFavorite(house);
    }
  }
}

// Provider for favorites
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<HouseData>>((ref) {
  return FavoritesNotifier();
});
