import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/house_model.dart';
import '../models/favorites_model.dart';
import 'list_houses_provider.dart';

// Provider for managing favorites
class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    final favoriteIds = favoritesJson.map((id) => int.parse(id)).toSet();
    state = favoriteIds;
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = state.map((id) => id.toString()).toList();
    await prefs.setStringList('favorites', favoritesJson);
  }

  void addFavorite(int propertyId) {
    state = {...state, propertyId};
    _saveFavorites();
  }

  void removeFavorite(int propertyId) {
    state = state.where((id) => id != propertyId).toSet();
    _saveFavorites();
  }

  bool isFavorite(int propertyId) {
    return state.contains(propertyId);
  }

  void toggleFavorite(int propertyId) {
    if (isFavorite(propertyId)) {
      removeFavorite(propertyId);
    } else {
      addFavorite(propertyId);
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier();
});

// Provider for getting favorite properties
final favoritePropertiesProvider = FutureProvider<List<PropertyData>>((ref) async {
  final favoriteIds = ref.watch(favoritesProvider);
  final allPropertiesAsync = ref.watch(listHousesProvider);
  
  return allPropertiesAsync.when(
    data: (properties) {
      return properties
          .where((property) => favoriteIds.contains(property.id))
          .map((house) => PropertyData(
                id: house.id,
                price: house.price,
                images: house.images,
                zip: house.zip,
                bathrooms: house.bathrooms,
                bedrooms: house.bedrooms,
                size: house.size,
                city: house.city,
                address: house.address,
                description: house.description,
                latitude: house.latitude,
                longitude: house.longitude,
                distance: house.distance,
                propertyType: house.propertyType,
                listingType: house.listingType,
                amenities: house.amenities,
                agent: house.agent,
                dateAdded: house.dateAdded,
                isFavorite: true,
                yearBuilt: house.yearBuilt,
                lotSize: house.lotSize,
                parkingType: house.parkingType,
                garageSpaces: house.garageSpaces,
              ))
          .toList();
    },
    loading: () => <PropertyData>[],
    error: (error, stack) => <PropertyData>[],
  );
});

// Provider for sorting favorites
final favoritesSortProvider = StateProvider<String>((ref) => 'date_added');

// Provider for property alerts
class PropertyAlertsNotifier extends StateNotifier<List<PropertyAlert>> {
  PropertyAlertsNotifier() : super([]) {
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsJson = prefs.getStringList('property_alerts') ?? [];
    final alerts = alertsJson
        .map((json) => PropertyAlert.fromJson(jsonDecode(json)))
        .toList();
    state = alerts;
  }

  Future<void> _saveAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsJson = state
        .map((alert) => jsonEncode(alert.toJson()))
        .toList();
    await prefs.setStringList('property_alerts', alertsJson);
  }

  void addAlert(PropertyAlert alert) {
    state = [...state, alert];
    _saveAlerts();
  }

  void removeAlert(String alertId) {
    state = state.where((alert) => alert.id != alertId).toList();
    _saveAlerts();
  }

  void updateAlert(PropertyAlert updatedAlert) {
    state = state.map((alert) {
      return alert.id == updatedAlert.id ? updatedAlert : alert;
    }).toList();
    _saveAlerts();
  }

  void toggleAlert(String alertId) {
    state = state.map((alert) {
      if (alert.id == alertId) {
        return PropertyAlert(
          id: alert.id,
          userId: alert.userId,
          name: alert.name,
          filters: alert.filters,
          isActive: !alert.isActive,
          createdAt: alert.createdAt,
          lastNotified: alert.lastNotified,
          frequency: alert.frequency,
        );
      }
      return alert;
    }).toList();
    _saveAlerts();
  }
}

final propertyAlertsProvider = StateNotifierProvider<PropertyAlertsNotifier, List<PropertyAlert>>((ref) {
  return PropertyAlertsNotifier();
});