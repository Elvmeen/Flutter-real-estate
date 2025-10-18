// Enhanced data class for DreamHome real estate app
class HouseData {
  final int id;
  final int price;
  final String image;
  final String zip;
  final int bathrooms;
  final int bedrooms;
  final int size;
  final String city;
  final String description;
  final int latitude;
  final int longitude;
  final double distance;
  // New properties for DreamHome features
  final PropertyType propertyType;
  final PropertyStatus status;
  final List<String> images;
  final List<String> videos;
  final List<String> virtualTours;
  final List<String> amenities;
  final AgentInfo? agent;
  final DateTime? datePosted;
  final bool isFavorite;
  final int? yearBuilt;
  final String? propertyStyle;
  final double? lotSize;
  final int? parkingSpaces;
  final bool? hasPool;
  final bool? hasGarden;
  final bool? hasGarage;
  final String? heatingType;
  final String? coolingType;

  HouseData({
    required this.id,
    required this.price,
    required this.image,
    required this.zip,
    required this.bathrooms,
    required this.bedrooms,
    required this.size,
    required this.city,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.propertyType = PropertyType.house,
    this.status = PropertyStatus.forSale,
    this.images = const [],
    this.videos = const [],
    this.virtualTours = const [],
    this.amenities = const [],
    this.agent,
    this.datePosted,
    this.isFavorite = false,
    this.yearBuilt,
    this.propertyStyle,
    this.lotSize,
    this.parkingSpaces,
    this.hasPool,
    this.hasGarden,
    this.hasGarage,
    this.heatingType,
    this.coolingType,
  });

  factory HouseData.fromJson(Map<String, dynamic> json) {
    return HouseData(
      id: json['id'],
      price: json['price'],
      image: json['image'],
      zip: json['zip'],
      bathrooms: json['bathrooms'],
      bedrooms: json['bedrooms'],
      size: json['size'],
      city: json['city'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      distance: 0.0,
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == json['propertyType'],
        orElse: () => PropertyType.house,
      ),
      status: PropertyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PropertyStatus.forSale,
      ),
      images: List<String>.from(json['images'] ?? [json['image']]),
      videos: List<String>.from(json['videos'] ?? []),
      virtualTours: List<String>.from(json['virtualTours'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      agent: json['agent'] != null ? AgentInfo.fromJson(json['agent']) : null,
      datePosted: json['datePosted'] != null ? DateTime.parse(json['datePosted']) : null,
      isFavorite: json['isFavorite'] ?? false,
      yearBuilt: json['yearBuilt'],
      propertyStyle: json['propertyStyle'],
      lotSize: json['lotSize']?.toDouble(),
      parkingSpaces: json['parkingSpaces'],
      hasPool: json['hasPool'],
      hasGarden: json['hasGarden'],
      hasGarage: json['hasGarage'],
      heatingType: json['heatingType'],
      coolingType: json['coolingType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'image': image,
      'zip': zip,
      'bathrooms': bathrooms,
      'bedrooms': bedrooms,
      'size': size,
      'city': city,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'propertyType': propertyType.name,
      'status': status.name,
      'images': images,
      'videos': videos,
      'virtualTours': virtualTours,
      'amenities': amenities,
      'agent': agent?.toJson(),
      'datePosted': datePosted?.toIso8601String(),
      'isFavorite': isFavorite,
      'yearBuilt': yearBuilt,
      'propertyStyle': propertyStyle,
      'lotSize': lotSize,
      'parkingSpaces': parkingSpaces,
      'hasPool': hasPool,
      'hasGarden': hasGarden,
      'hasGarage': hasGarage,
      'heatingType': heatingType,
      'coolingType': coolingType,
    };
  }

  HouseData copyWith({
    int? id,
    int? price,
    String? image,
    String? zip,
    int? bathrooms,
    int? bedrooms,
    int? size,
    String? city,
    String? description,
    int? latitude,
    int? longitude,
    double? distance,
    PropertyType? propertyType,
    PropertyStatus? status,
    List<String>? images,
    List<String>? videos,
    List<String>? virtualTours,
    List<String>? amenities,
    AgentInfo? agent,
    DateTime? datePosted,
    bool? isFavorite,
    int? yearBuilt,
    String? propertyStyle,
    double? lotSize,
    int? parkingSpaces,
    bool? hasPool,
    bool? hasGarden,
    bool? hasGarage,
    String? heatingType,
    String? coolingType,
  }) {
    return HouseData(
      id: id ?? this.id,
      price: price ?? this.price,
      image: image ?? this.image,
      zip: zip ?? this.zip,
      bathrooms: bathrooms ?? this.bathrooms,
      bedrooms: bedrooms ?? this.bedrooms,
      size: size ?? this.size,
      city: city ?? this.city,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      propertyType: propertyType ?? this.propertyType,
      status: status ?? this.status,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      virtualTours: virtualTours ?? this.virtualTours,
      amenities: amenities ?? this.amenities,
      agent: agent ?? this.agent,
      datePosted: datePosted ?? this.datePosted,
      isFavorite: isFavorite ?? this.isFavorite,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      propertyStyle: propertyStyle ?? this.propertyStyle,
      lotSize: lotSize ?? this.lotSize,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      hasPool: hasPool ?? this.hasPool,
      hasGarden: hasGarden ?? this.hasGarden,
      hasGarage: hasGarage ?? this.hasGarage,
      heatingType: heatingType ?? this.heatingType,
      coolingType: coolingType ?? this.coolingType,
    );
  }
}

// Enums for property types and status
enum PropertyType {
  house,
  apartment,
  condo,
  townhouse,
  villa,
  studio,
  loft,
  duplex,
  penthouse,
  land,
  commercial,
}

enum PropertyStatus {
  forSale,
  forRent,
  sold,
  rented,
  pending,
  offMarket,
}

// Agent information model
class AgentInfo {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? company;
  final double? rating;
  final int? totalSales;
  final List<String> specialties;
  final String? bio;
  final bool isOnline;

  AgentInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.company,
    this.rating,
    this.totalSales,
    this.specialties = const [],
    this.bio,
    this.isOnline = false,
  });

  factory AgentInfo.fromJson(Map<String, dynamic> json) {
    return AgentInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profileImage'],
      company: json['company'],
      rating: json['rating']?.toDouble(),
      totalSales: json['totalSales'],
      specialties: List<String>.from(json['specialties'] ?? []),
      bio: json['bio'],
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'company': company,
      'rating': rating,
      'totalSales': totalSales,
      'specialties': specialties,
      'bio': bio,
      'isOnline': isOnline,
    };
  }
}
