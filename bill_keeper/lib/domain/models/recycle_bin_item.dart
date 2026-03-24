class RecycleBinItem {
  final String id;
  final String billId;
  final DateTime deletedAt;
  final int remainingDays;

  const RecycleBinItem({
    required this.id,
    required this.billId,
    required this.deletedAt,
    required this.remainingDays,
  });

  RecycleBinItem copyWith({
    String? id,
    String? billId,
    DateTime? deletedAt,
    int? remainingDays,
  }) {
    return RecycleBinItem(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      deletedAt: deletedAt ?? this.deletedAt,
      remainingDays: remainingDays ?? this.remainingDays,
    );
  }
}
