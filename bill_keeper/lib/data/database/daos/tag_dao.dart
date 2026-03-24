import 'package:drift/drift.dart';
import '../app_database.dart';

class TagDao {
  final AppDatabase _db;

  TagDao(this._db);

  Future<List<Tag>> getAllTags(String phone) async {
    return (_db.select(_db.tags)
          ..where((t) => t.phone.equals(phone))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<Tag?> getTagById(String id) async {
    return (_db.select(_db.tags)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Tag?> getTagByName(String phone, String name) async {
    return (_db.select(_db.tags)
          ..where((t) => t.phone.equals(phone) & t.name.equals(name)))
        .getSingleOrNull();
  }

  Future<String> createTag(TagsCompanion tag) async {
    await _db.into(_db.tags).insert(tag);
    return tag.id.value;
  }

  Future<void> updateTag(Tag tag) async {
    await _db.update(_db.tags).replace(tag);
  }

  Future<void> deleteTag(String id) async {
    await (_db.delete(_db.billTags)..where((t) => t.tagId.equals(id))).go();
    await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  }

  Future<void> mergeTags(String sourceTagId, String targetTagId) async {
    final billsWithSourceTag = await (_db.select(_db.billTags)
          ..where((t) => t.tagId.equals(sourceTagId)))
        .get();
    
    for (final billTag in billsWithSourceTag) {
      final exists = await (_db.select(_db.billTags)
            ..where((t) => t.billId.equals(billTag.billId) & t.tagId.equals(targetTagId)))
          .getSingleOrNull();
      
      if (exists == null) {
        await _db.into(_db.billTags).insert(BillTagsCompanion.insert(
          billId: billTag.billId,
          tagId: targetTagId,
        ));
      }
    }
    
    await deleteTag(sourceTagId);
  }

  Future<int> getBillCountForTag(String tagId) async {
    final count = _db.billTags.billId.count();
    final query = _db.selectOnly(_db.billTags)
      ..addColumns([count])
      ..where(_db.billTags.tagId.equals(tagId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<List<Tag>> getTagsForBill(String billId) async {
    final query = '''
      SELECT tags.* FROM tags
      INNER JOIN bill_tags ON tags.id = bill_tags.tag_id
      WHERE bill_tags.bill_id = ?
    ''';
    final result = await _db.customSelect(query, variables: [
      Variable.withString(billId),
    ]).get();
    return result.map((row) => Tag(
      id: row.read<String>('id'),
      name: row.read<String>('name'),
      phone: row.read<String>('phone'),
      createdAt: row.read<DateTime>('created_at'),
    )).toList();
  }

  Stream<List<Tag>> watchAllTags(String phone) {
    return (_db.select(_db.tags)
          ..where((t) => t.phone.equals(phone))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }
}
