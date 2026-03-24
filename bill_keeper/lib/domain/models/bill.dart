import 'package:bill_keeper/domain/models/bill_image.dart';
import 'package:bill_keeper/domain/models/tag.dart';

class Bill {
  final String id;
  final String title;
  final String ocrContent;
  final String? location;
  final String? remark;
  final String? collectionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BillImage> images;
  final List<Tag> tags;

  const Bill({
    required this.id,
    required this.title,
    required this.ocrContent,
    this.location,
    this.remark,
    this.collectionId,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.tags = const [],
  });

  Bill copyWith({
    String? id,
    String? title,
    String? ocrContent,
    String? location,
    String? remark,
    String? collectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BillImage>? images,
    List<Tag>? tags,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      ocrContent: ocrContent ?? this.ocrContent,
      location: location ?? this.location,
      remark: remark ?? this.remark,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      tags: tags ?? this.tags,
    );
  }
}
