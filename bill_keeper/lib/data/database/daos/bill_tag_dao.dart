import 'package:drift/drift.dart';
import '../app_database.dart';

class BillTagDao {
  final AppDatabase _db;

  BillTagDao(this._db);

  Future<void> addTagToBill(String billId, String tagId) async {
    final existing = await (_db.select(_db.billTags)
          ..where((t) => t.billId.equals(billId) & t.tagId.equals(tagId)))
        .getSingleOrNull();
    
    if (existing == null) {
      await _db.into(_db.billTags).insert(BillTagsCompanion.insert(
        billId: billId,
        tagId: tagId,
      ));
    }
  }

  Future<void> removeTagFromBill(String billId, String tagId) async {
    await (_db.delete(_db.billTags)
          ..where((t) => t.billId.equals(billId) & t.tagId.equals(tagId)))
        .go();
  }

  Future<void> removeAllTagsFromBill(String billId) async {
    await (_db.delete(_db.billTags)..where((t) => t.billId.equals(billId))).go();
  }

  Future<void> setTagsForBill(String billId, List<String> tagIds) async {
    await removeAllTagsFromBill(billId);
    for (final tagId in tagIds) {
      await addTagToBill(billId, tagId);
    }
  }

  Future<List<String>> getTagIdsForBill(String billId) async {
    final results = await (_db.select(_db.billTags)
          ..where((t) => t.billId.equals(billId)))
        .get();
    return results.map((r) => r.tagId).toList();
  }
}
