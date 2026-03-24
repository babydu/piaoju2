class User {
  final String phone;
  final int storageUsed;
  final int storageTotal;
  final DateTime createdAt;
  final String? nickname;

  const User({
    required this.phone,
    required this.storageUsed,
    required this.storageTotal,
    required this.createdAt,
    this.nickname,
  });

  static const int defaultStorageTotal = 1024 * 1024 * 1024; // 1GB

  User copyWith({
    String? phone,
    int? storageUsed,
    int? storageTotal,
    DateTime? createdAt,
    String? nickname,
  }) {
    return User(
      phone: phone ?? this.phone,
      storageUsed: storageUsed ?? this.storageUsed,
      storageTotal: storageTotal ?? this.storageTotal,
      createdAt: createdAt ?? this.createdAt,
      nickname: nickname ?? this.nickname,
    );
  }
}
