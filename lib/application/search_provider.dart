import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_filters.dart';
import '../models/house_model.dart';
import 'list_houses_provider.dart';

// Provider for search filters
final searchFiltersProvider = StateProvider<SearchFilters>((ref) => SearchFilters());

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for filtered properties based on search filters and query
final filteredPropertiesProvider = FutureProvider<List<PropertyData>>((ref) async {
  final allPropertiesAsync = ref.watch(listHousesProvider);
  final filters = ref.watch(searchFiltersProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return allPropertiesAsync.when(
    data: (properties) {
      // Convert HouseData to PropertyData for compatibility
      var filteredProperties = properties.map((house) => PropertyData(
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
        isFavorite: house.isFavorite,
        yearBuilt: house.yearBuilt,
        lotSize: house.lotSize,
        parkingType: house.parkingType,
        garageSpaces: house.garageSpaces,
      )).toList();

      // Apply text search
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filteredProperties = filteredProperties.where((property) {
          return property.city.toLowerCase().contains(query) ||
                 property.address.toLowerCase().contains(query) ||
                 property.description.toLowerCase().contains(query) ||
                 property.zip.toLowerCase().contains(query);
        }).toList();
      }

      // Apply filters
      if (filters.hasActiveFilters) {
        filteredProperties = filteredProperties.where((property) {
          // Location filter
          if (filters.location != null && filters.location!.isNotEmpty) {
            final location = filters.location!.toLowerCase();
            if (!property.city.toLowerCase().contains(location) &&
                !property.address.toLowerCase().contains(location) &&
                !property.zip.toLowerCase().contains(location)) {
              return false;
            }
          }

          // Price filters
          if (filters.minPrice != null && property.price < filters.minPrice!) {
            return false;
          }
          if (filters.maxPrice != null && property.price > filters.maxPrice!) {
            return false;
          }

          // Property type filter
          if (filters.propertyType != null && property.propertyType != filters.propertyType) {
            return false;
          }

          // Listing type filter
          if (filters.listingType != null && property.listingType != filters.listingType) {
            return false;
          }

          // Bedroom filters
          if (filters.minBedrooms != null && property.bedrooms < filters.minBedrooms!) {
            return false;
          }
          if (filters.maxBedrooms != null && property.bedrooms > filters.maxBedrooms!) {
            return false;
          }

          // Bathroom filters
          if (filters.minBathrooms != null && property.bathrooms < filters.minBathrooms!) {
            return false;
          }
          if (filters.maxBathrooms != null && property.bathrooms > filters.maxBathrooms!) {
            return false;
          }

          // Size filters
          if (filters.minSize != null && property.size < filters.minSize!) {
            return false;
          }
          if (filters.maxSize != null && property.size > filters.maxSize!) {
            return false;
          }

          // Distance filter
          if (filters.maxDistance != null && property.distance > filters.maxDistance!) {
            return false;
          }

          // Year built filters
          if (filters.minYearBuilt != null && property.yearBuilt < filters.minYearBuilt!) {
            return false;
          }
          if (filters.maxYearBuilt != null && property.yearBuilt > filters.maxYearBuilt!) {
            return false;
          }

          // Amenities filter
          if (filters.amenities.isNotEmpty) {
            final hasAllAmenities = filters.amenities.every((amenity) =>
                property.amenities.any((propertyAmenity) =>
                    propertyAmenity.toLowerCase().contains(amenity.toLowerCase())));
            if (!hasAllAmenities) {
              return false;
            }
          }

          return true;
        }).toList();
      }

      return filteredProperties;
    },
    loading: () => <PropertyData>[],
    error: (error, stack) => <PropertyData>[],
  );
});

// Provider for search suggestions
final searchSuggestionsProvider = Provider<List<String>>((ref) {
  // In a real app, this would come from a search API or database
  return [
    'Downtown',
    'Suburban',
    'Waterfront',
    'City Center',
    'Beachside',
    'Mountain View',
    'Historic District',
    'New Development',
  ];
});

// Provider for popular searches
final popularSearchesProvider = Provider<List<String>>((ref) {
  return [
    'Houses under \$500K',
    '3+ bedroom homes',
    'Condos with pool',
    'Pet-friendly apartments',
    'Homes with garage',
    'Recently built properties',
  ];
});

// Provider for saved searches (would be persisted in real app)
final savedSearchesProvider = StateProvider<List<SearchFilters>>((ref) => []);