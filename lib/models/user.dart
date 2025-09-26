class User {
  final int? id;
  final String email;
  final String displayName;
  final String timezone;
  final String? password; // only for signup
  final DateTime? createdAt;

  User({
    this.id,
    required this.email,
    required this.displayName,
    this.password,
    this.timezone = 'Europe/Rome',

    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['display_name'],
      timezone: json['timezone'] ?? 'Europe/Rome',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'display_name': displayName,
      'timezone': timezone,
      'password': password,
    };
  }
}
