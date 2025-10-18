// Enhanced data class for DreamHome properties
class PropertyData {
  final int id;
  final int price;
  final List<String> images;
  final String? videoUrl;
  final String? virtualTourUrl;
  final String zip;
  final int bathrooms;
  final int bedrooms;
  final int size;
  final String city;
  final String address;
  final String description;
  final double latitude;
  final double longitude;
  final double distance;
  final PropertyType propertyType;
  final ListingType listingType;
  final List<String> amenities;
  final AgentData agent;
  final DateTime dateAdded;
  final bool isFavorite;
  final int yearBuilt;
  final double? lotSize;
  final String? parkingType;
  final int? garageSpaces;

  PropertyData({
    required this.id,
    required this.price,
    required this.images,
    this.videoUrl,
    this.virtualTourUrl,
    required this.zip,
    required this.bathrooms,
    required this.bedrooms,
    required this.size,
    required this.city,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.propertyType,
    required this.listingType,
    required this.amenities,
    required this.agent,
    required this.dateAdded,
    this.isFavorite = false,
    required this.yearBuilt,
    this.lotSize,
    this.parkingType,
    this.garageSpaces,
  });

  factory PropertyData.fromJson(Map<String, dynamic> json) {
    return PropertyData(
      id: json['id'],
      price: json['price'],
      images: json['images'] != null ? List<String>.from(json['images']) : [json['image'] ?? ''],
      videoUrl: json['videoUrl'],
      virtualTourUrl: json['virtualTourUrl'],
      zip: json['zip'] ?? '',
      bathrooms: json['bathrooms'] ?? 0,
      bedrooms: json['bedrooms'] ?? 0,
      size: json['size'] ?? 0,
      city: json['city'] ?? '',
      address: json['address'] ?? '${json['city'] ?? ''}, ${json['zip'] ?? ''}',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      distance: 0.0,
      propertyType: PropertyType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['propertyType'] ?? 'house'),
        orElse: () => PropertyType.house,
      ),
      listingType: ListingType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['listingType'] ?? 'sale'),
        orElse: () => ListingType.sale,
      ),
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : [],
      agent: json['agent'] != null ? AgentData.fromJson(json['agent']) : AgentData.defaultAgent(),
      dateAdded: json['dateAdded'] != null ? DateTime.parse(json['dateAdded']) : DateTime.now(),
      isFavorite: json['isFavorite'] ?? false,
      yearBuilt: json['yearBuilt'] ?? DateTime.now().year,
      lotSize: json['lotSize']?.toDouble(),
      parkingType: json['parkingType'],
      garageSpaces: json['garageSpaces'],
    );
  }

  PropertyData copyWith({
    bool? isFavorite,
    double? distance,
  }) {
    return PropertyData(
      id: id,
      price: price,
      images: images,
      videoUrl: videoUrl,
      virtualTourUrl: virtualTourUrl,
      zip: zip,
      bathrooms: bathrooms,
      bedrooms: bedrooms,
      size: size,
      city: city,
      address: address,
      description: description,
      latitude: latitude,
      longitude: longitude,
      distance: distance ?? this.distance,
      propertyType: propertyType,
      listingType: listingType,
      amenities: amenities,
      agent: agent,
      dateAdded: dateAdded,
      isFavorite: isFavorite ?? this.isFavorite,
      yearBuilt: yearBuilt,
      lotSize: lotSize,
      parkingType: parkingType,
      garageSpaces: garageSpaces,
    );
  }
}

// Legacy compatibility - maps old HouseData to new PropertyData
class HouseData extends PropertyData {
  HouseData({
    required int id,
    required int price,
    required String image,
    required String zip,
    required int bathrooms,
    required int bedrooms,
    required int size,
    required String city,
    required String description,
    required int latitude,
    required int longitude,
    required double distance,
  }) : super(
          id: id,
          price: price,
          images: [image],
          zip: zip,
          bathrooms: bathrooms,
          bedrooms: bedrooms,
          size: size,
          city: city,
          address: '$city, $zip',
          description: description,
          latitude: latitude.toDouble(),
          longitude: longitude.toDouble(),
          distance: distance,
          propertyType: PropertyType.house,
          listingType: ListingType.sale,
          amenities: [],
          agent: AgentData.defaultAgent(),
          dateAdded: DateTime.now(),
          yearBuilt: DateTime.now().year,
        );

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
    );
  }
}

enum PropertyType {
  house,
  apartment,
  condo,
  townhouse,
  villa,
  studio,
  duplex,
  land,
}

enum ListingType {
  sale,
  rent,
}

class AgentData {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String company;
  final double rating;
  final int reviewCount;
  final String bio;
  final List<String> specializations;

  AgentData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.company,
    required this.rating,
    required this.reviewCount,
    required this.bio,
    required this.specializations,
  });

  factory AgentData.fromJson(Map<String, dynamic> json) {
    return AgentData(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Agent',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'],
      company: json['company'] ?? 'DreamHome Realty',
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      bio: json['bio'] ?? 'Professional real estate agent',
      specializations: json['specializations'] != null 
          ? List<String>.from(json['specializations']) 
          : ['Residential Sales'],
    );
  }

  factory AgentData.defaultAgent() {
    return AgentData(
      id: 1,
      name: 'DreamHome Agent',
      email: 'agent@dreamhome.com',
      phone: '+1-555-0123',
      company: 'DreamHome Realty',
      rating: 4.5,
      reviewCount: 150,
      bio: 'Experienced real estate professional dedicated to helping you find your dream home.',
      specializations: ['Residential Sales', 'First-time Buyers'],
    );
  }
}
