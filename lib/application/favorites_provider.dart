import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorite_model.dart';

// State notifier for managing favorite properties
class FavoritesNotifier extends StateNotifier<List<FavoriteProperty>> {
  FavoritesNotifier() : super([]);

  // Add a property to favorites
  void addFavorite(int propertyId) {
    if (!isFavorite(propertyId)) {
      state = [
        ...state,
        FavoriteProperty(
          propertyId: propertyId,
          savedAt: DateTime.now(),
        )
      ];
    }
  }

  // Remove a property from favorites
  void removeFavorite(int propertyId) {
    state = state.where((fav) => fav.propertyId != propertyId).toList();
  }

  // Toggle favorite status
  void toggleFavorite(int propertyId) {
    if (isFavorite(propertyId)) {
      removeFavorite(propertyId);
    } else {
      addFavorite(propertyId);
    }
  }

  // Check if a property is in favorites
  bool isFavorite(int propertyId) {
    return state.any((fav) => fav.propertyId == propertyId);
  }

  // Get all favorite property IDs
  List<int> getFavoriteIds() {
    return state.map((fav) => fav.propertyId).toList();
  }

  // Clear all favorites
  void clearAllFavorites() {
    state = [];
  }
}

// Provider for favorites
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<FavoriteProperty>>((ref) {
  return FavoritesNotifier();
});
