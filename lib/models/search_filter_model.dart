// Advanced search filter model
class SearchFilter {
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final List<PropertyType> propertyTypes;
  final List<String> amenities;
  final int? minBedrooms;
  final int? maxBedrooms;
  final int? minBathrooms;
  final int? maxBathrooms;
  final int? minSize;
  final int? maxSize;
  final PropertyStatus? status;
  final double? maxDistance;
  final int? yearBuiltFrom;
  final int? yearBuiltTo;
  final bool? hasPool;
  final bool? hasGarden;
  final bool? hasGarage;
  final String? propertyStyle;
  final double? minLotSize;
  final double? maxLotSize;

  SearchFilter({
    this.location,
    this.minPrice,
    this.maxPrice,
    this.propertyTypes = const [],
    this.amenities = const [],
    this.minBedrooms,
    this.maxBedrooms,
    this.minBathrooms,
    this.maxBathrooms,
    this.minSize,
    this.maxSize,
    this.status,
    this.maxDistance,
    this.yearBuiltFrom,
    this.yearBuiltTo,
    this.hasPool,
    this.hasGarden,
    this.hasGarage,
    this.propertyStyle,
    this.minLotSize,
    this.maxLotSize,
  });

  // Check if a property matches this filter
  bool matches(HouseData property) {
    // Location filter
    if (location != null && location!.isNotEmpty) {
      final searchLocation = location!.toLowerCase();
      final propertyLocation = '${property.city} ${property.zip}'.toLowerCase();
      if (!propertyLocation.contains(searchLocation)) {
        return false;
      }
    }

    // Price range filter
    if (minPrice != null && property.price < minPrice!) return false;
    if (maxPrice != null && property.price > maxPrice!) return false;

    // Property type filter
    if (propertyTypes.isNotEmpty && !propertyTypes.contains(property.propertyType)) {
      return false;
    }

    // Amenities filter
    if (amenities.isNotEmpty) {
      for (final amenity in amenities) {
        if (!property.amenities.contains(amenity)) {
          return false;
        }
      }
    }

    // Bedrooms filter
    if (minBedrooms != null && property.bedrooms < minBedrooms!) return false;
    if (maxBedrooms != null && property.bedrooms > maxBedrooms!) return false;

    // Bathrooms filter
    if (minBathrooms != null && property.bathrooms < minBathrooms!) return false;
    if (maxBathrooms != null && property.bathrooms > maxBathrooms!) return false;

    // Size filter
    if (minSize != null && property.size < minSize!) return false;
    if (maxSize != null && property.size > maxSize!) return false;

    // Status filter
    if (status != null && property.status != status!) return false;

    // Distance filter
    if (maxDistance != null && property.distance > maxDistance!) return false;

    // Year built filter
    if (yearBuiltFrom != null && (property.yearBuilt ?? 0) < yearBuiltFrom!) return false;
    if (yearBuiltTo != null && (property.yearBuilt ?? 9999) > yearBuiltTo!) return false;

    // Specific features filter
    if (hasPool != null && property.hasPool != hasPool!) return false;
    if (hasGarden != null && property.hasGarden != hasGarden!) return false;
    if (hasGarage != null && property.hasGarage != hasGarage!) return false;

    // Property style filter
    if (propertyStyle != null && property.propertyStyle != propertyStyle!) return false;

    // Lot size filter
    if (minLotSize != null && (property.lotSize ?? 0) < minLotSize!) return false;
    if (maxLotSize != null && (property.lotSize ?? 0) > maxLotSize!) return false;

    return true;
  }

  // Create a copy with updated values
  SearchFilter copyWith({
    String? location,
    double? minPrice,
    double? maxPrice,
    List<PropertyType>? propertyTypes,
    List<String>? amenities,
    int? minBedrooms,
    int? maxBedrooms,
    int? minBathrooms,
    int? maxBathrooms,
    int? minSize,
    int? maxSize,
    PropertyStatus? status,
    double? maxDistance,
    int? yearBuiltFrom,
    int? yearBuiltTo,
    bool? hasPool,
    bool? hasGarden,
    bool? hasGarage,
    String? propertyStyle,
    double? minLotSize,
    double? maxLotSize,
  }) {
    return SearchFilter(
      location: location ?? this.location,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      amenities: amenities ?? this.amenities,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      maxBathrooms: maxBathrooms ?? this.maxBathrooms,
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,
      status: status ?? this.status,
      maxDistance: maxDistance ?? this.maxDistance,
      yearBuiltFrom: yearBuiltFrom ?? this.yearBuiltFrom,
      yearBuiltTo: yearBuiltTo ?? this.yearBuiltTo,
      hasPool: hasPool ?? this.hasPool,
      hasGarden: hasGarden ?? this.hasGarden,
      hasGarage: hasGarage ?? this.hasGarage,
      propertyStyle: propertyStyle ?? this.propertyStyle,
      minLotSize: minLotSize ?? this.minLotSize,
      maxLotSize: maxLotSize ?? this.maxLotSize,
    );
  }

  // Clear all filters
  SearchFilter clear() {
    return SearchFilter();
  }

  // Check if any filters are applied
  bool get hasActiveFilters {
    return location != null ||
        minPrice != null ||
        maxPrice != null ||
        propertyTypes.isNotEmpty ||
        amenities.isNotEmpty ||
        minBedrooms != null ||
        maxBedrooms != null ||
        minBathrooms != null ||
        maxBathrooms != null ||
        minSize != null ||
        maxSize != null ||
        status != null ||
        maxDistance != null ||
        yearBuiltFrom != null ||
        yearBuiltTo != null ||
        hasPool != null ||
        hasGarden != null ||
        hasGarage != null ||
        propertyStyle != null ||
        minLotSize != null ||
        maxLotSize != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'propertyTypes': propertyTypes.map((e) => e.name).toList(),
      'amenities': amenities,
      'minBedrooms': minBedrooms,
      'maxBedrooms': maxBedrooms,
      'minBathrooms': minBathrooms,
      'maxBathrooms': maxBathrooms,
      'minSize': minSize,
      'maxSize': maxSize,
      'status': status?.name,
      'maxDistance': maxDistance,
      'yearBuiltFrom': yearBuiltFrom,
      'yearBuiltTo': yearBuiltTo,
      'hasPool': hasPool,
      'hasGarden': hasGarden,
      'hasGarage': hasGarage,
      'propertyStyle': propertyStyle,
      'minLotSize': minLotSize,
      'maxLotSize': maxLotSize,
    };
  }

  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      location: json['location'],
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      propertyTypes: (json['propertyTypes'] as List<dynamic>?)
          ?.map((e) => PropertyType.values.firstWhere(
                (type) => type.name == e,
                orElse: () => PropertyType.house,
              ))
          .toList() ?? [],
      amenities: List<String>.from(json['amenities'] ?? []),
      minBedrooms: json['minBedrooms'],
      maxBedrooms: json['maxBedrooms'],
      minBathrooms: json['minBathrooms'],
      maxBathrooms: json['maxBathrooms'],
      minSize: json['minSize'],
      maxSize: json['maxSize'],
      status: json['status'] != null 
          ? PropertyStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => PropertyStatus.forSale,
            )
          : null,
      maxDistance: json['maxDistance']?.toDouble(),
      yearBuiltFrom: json['yearBuiltFrom'],
      yearBuiltTo: json['yearBuiltTo'],
      hasPool: json['hasPool'],
      hasGarden: json['hasGarden'],
      hasGarage: json['hasGarage'],
      propertyStyle: json['propertyStyle'],
      minLotSize: json['minLotSize']?.toDouble(),
      maxLotSize: json['maxLotSize']?.toDouble(),
    );
  }
}