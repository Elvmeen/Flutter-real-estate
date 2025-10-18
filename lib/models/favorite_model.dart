// Data class for Favorite Properties
class FavoriteProperty {
  final int propertyId;
  final DateTime savedAt;

  FavoriteProperty({
    required this.propertyId,
    required this.savedAt,
  });

  factory FavoriteProperty.fromJson(Map<String, dynamic> json) {
    return FavoriteProperty(
      propertyId: json['propertyId'] ?? 0,
      savedAt: json['savedAt'] != null 
          ? DateTime.parse(json['savedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}
