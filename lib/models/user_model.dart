class UserModel {
  final int id;
  final String username;
  final String email;
  final String displayName;
  final String timezone;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.timezone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      displayName: profile != null ? (profile['display_name'] ?? '') : '',
      timezone: profile != null ? (profile['timezone'] ?? 'UTC') : 'UTC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile': {
        'display_name': displayName,
        'timezone': timezone,
      },
    };
  }
}
