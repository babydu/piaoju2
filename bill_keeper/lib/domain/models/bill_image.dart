class BillImage {
  final String id;
  final String billId;
  final String localPath;
  final String thumbnailPath;
  final int sortOrder;

  const BillImage({
    required this.id,
    required this.billId,
    required this.localPath,
    required this.thumbnailPath,
    required this.sortOrder,
  });

  BillImage copyWith({
    String? id,
    String? billId,
    String? localPath,
    String? thumbnailPath,
    int? sortOrder,
  }) {
    return BillImage(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
