class Tag {
  final String id;
  final String name;
  final String userPhone;
  final DateTime createdAt;
  final int billCount;

  const Tag({
    required this.id,
    required this.name,
    required this.userPhone,
    required this.createdAt,
    this.billCount = 0,
  });

  Tag copyWith({
    String? id,
    String? name,
    String? userPhone,
    DateTime? createdAt,
    int? billCount,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      userPhone: userPhone ?? this.userPhone,
      createdAt: createdAt ?? this.createdAt,
      billCount: billCount ?? this.billCount,
    );
  }
}
