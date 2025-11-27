/// 사용자 모델
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool isGuest;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.isGuest = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    bool? isGuest,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

/// 인증 상태
enum AuthStatus {
  unauthenticated,
  authenticated,
  guest,
}

