// Data class for real estate agents
class AgentData {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String photo;
  final String specialty;
  final double rating;
  final int propertiesListed;

  AgentData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.photo,
    required this.specialty,
    required this.rating,
    required this.propertiesListed,
  });

  factory AgentData.fromJson(Map<String, dynamic> json) {
    return AgentData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      photo: json['photo'],
      specialty: json['specialty'],
      rating: json['rating'].toDouble(),
      propertiesListed: json['propertiesListed'],
    );
  }
}
