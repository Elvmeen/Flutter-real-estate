class FavoriteProperty {
  final String id;
  final int propertyId;
  final String userId;
  final DateTime dateAdded;

  FavoriteProperty({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.dateAdded,
  });

  factory FavoriteProperty.fromJson(Map<String, dynamic> json) {
    return FavoriteProperty(
      id: json['id'],
      propertyId: json['propertyId'],
      userId: json['userId'],
      dateAdded: DateTime.parse(json['dateAdded']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }
}

class PropertyAlert {
  final String id;
  final String userId;
  final String name;
  final SearchFilters filters;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastNotified;
  final AlertFrequency frequency;

  PropertyAlert({
    required this.id,
    required this.userId,
    required this.name,
    required this.filters,
    this.isActive = true,
    required this.createdAt,
    this.lastNotified,
    this.frequency = AlertFrequency.immediate,
  });

  factory PropertyAlert.fromJson(Map<String, dynamic> json) {
    return PropertyAlert(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      filters: SearchFilters.fromJson(json['filters']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastNotified: json['lastNotified'] != null 
          ? DateTime.parse(json['lastNotified']) 
          : null,
      frequency: AlertFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == json['frequency'],
        orElse: () => AlertFrequency.immediate,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'filters': filters.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastNotified': lastNotified?.toIso8601String(),
      'frequency': frequency.toString().split('.').last,
    };
  }
}

enum AlertFrequency {
  immediate,
  daily,
  weekly,
}

// Extension for SearchFilters to support JSON serialization
extension SearchFiltersJson on SearchFilters {
  static SearchFilters fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      location: json['location'],
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      propertyType: json['propertyType'] != null
          ? PropertyType.values.firstWhere(
              (e) => e.toString().split('.').last == json['propertyType'],
            )
          : null,
      listingType: json['listingType'] != null
          ? ListingType.values.firstWhere(
              (e) => e.toString().split('.').last == json['listingType'],
            )
          : null,
      minBedrooms: json['minBedrooms'],
      maxBedrooms: json['maxBedrooms'],
      minBathrooms: json['minBathrooms'],
      maxBathrooms: json['maxBathrooms'],
      minSize: json['minSize'],
      maxSize: json['maxSize'],
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities']) 
          : [],
      maxDistance: json['maxDistance']?.toDouble(),
      minYearBuilt: json['minYearBuilt'],
      maxYearBuilt: json['maxYearBuilt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'propertyType': propertyType?.toString().split('.').last,
      'listingType': listingType?.toString().split('.').last,
      'minBedrooms': minBedrooms,
      'maxBedrooms': maxBedrooms,
      'minBathrooms': minBathrooms,
      'maxBathrooms': maxBathrooms,
      'minSize': minSize,
      'maxSize': maxSize,
      'amenities': amenities,
      'maxDistance': maxDistance,
      'minYearBuilt': minYearBuilt,
      'maxYearBuilt': maxYearBuilt,
    };
  }
}

import 'house_model.dart';