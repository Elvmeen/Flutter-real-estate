class Agent {
  final int id;
  final String name;
  final String city;
  final String email;
  final String phone;
  final String bio;
  final String? avatarUrl;

  Agent({
    required this.id,
    required this.name,
    required this.city,
    required this.email,
    required this.phone,
    required this.bio,
    this.avatarUrl,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
