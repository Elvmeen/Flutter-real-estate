// Data class for Real Estate Agents
class AgentData {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String photo;
  final String specialty;
  final double rating;
  final int propertiesSold;
  final String bio;
  final String agency;

  AgentData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.photo,
    required this.specialty,
    required this.rating,
    required this.propertiesSold,
    required this.bio,
    required this.agency,
  });

  factory AgentData.fromJson(Map<String, dynamic> json) {
    return AgentData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photo: json['photo'] ?? '',
      specialty: json['specialty'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      propertiesSold: json['propertiesSold'] ?? 0,
      bio: json['bio'] ?? '',
      agency: json['agency'] ?? '',
    );
  }
}
