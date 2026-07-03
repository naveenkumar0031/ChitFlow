class AppUser {
  final String name;
  final String phone;
  final String password;
  final String role; // "admin" or "member"

  AppUser({
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
}
