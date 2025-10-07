class User {
  final int? id;
  final String username;
  final String email;
  final String phone;
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
