class SearchFilters {
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final PropertyType? propertyType;
  final ListingType? listingType;
  final int? minBedrooms;
  final int? maxBedrooms;
  final int? minBathrooms;
  final int? maxBathrooms;
  final int? minSize;
  final int? maxSize;
  final List<String> amenities;
  final double? maxDistance;
  final int? minYearBuilt;
  final int? maxYearBuilt;

  SearchFilters({
    this.location,
    this.minPrice,
    this.maxPrice,
    this.propertyType,
    this.listingType,
    this.minBedrooms,
    this.maxBedrooms,
    this.minBathrooms,
    this.maxBathrooms,
    this.minSize,
    this.maxSize,
    this.amenities = const [],
    this.maxDistance,
    this.minYearBuilt,
    this.maxYearBuilt,
  });

  SearchFilters copyWith({
    String? location,
    double? minPrice,
    double? maxPrice,
    PropertyType? propertyType,
    ListingType? listingType,
    int? minBedrooms,
    int? maxBedrooms,
    int? minBathrooms,
    int? maxBathrooms,
    int? minSize,
    int? maxSize,
    List<String>? amenities,
    double? maxDistance,
    int? minYearBuilt,
    int? maxYearBuilt,
  }) {
    return SearchFilters(
      location: location ?? this.location,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      propertyType: propertyType ?? this.propertyType,
      listingType: listingType ?? this.listingType,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      maxBathrooms: maxBathrooms ?? this.maxBathrooms,
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,
      amenities: amenities ?? this.amenities,
      maxDistance: maxDistance ?? this.maxDistance,
      minYearBuilt: minYearBuilt ?? this.minYearBuilt,
      maxYearBuilt: maxYearBuilt ?? this.maxYearBuilt,
    );
  }

  bool get hasActiveFilters {
    return location != null ||
        minPrice != null ||
        maxPrice != null ||
        propertyType != null ||
        listingType != null ||
        minBedrooms != null ||
        maxBedrooms != null ||
        minBathrooms != null ||
        maxBathrooms != null ||
        minSize != null ||
        maxSize != null ||
        amenities.isNotEmpty ||
        maxDistance != null ||
        minYearBuilt != null ||
        maxYearBuilt != null;
  }
}

import 'house_model.dart';