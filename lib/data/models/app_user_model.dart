class AppUser {
  final String id;
  final String email;
  final String displayName;
  final bool isGuest;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isGuest,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'isGuest': isGuest,
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      isGuest: map['isGuest'] ?? false,
    );
  }
}