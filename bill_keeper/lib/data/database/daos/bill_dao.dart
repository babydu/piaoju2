import 'package:drift/drift.dart';
import '../app_database.dart';

class BillDao {
  final AppDatabase _db;

  BillDao(this._db);

  Future<List<Bill>> getAllBills(String phone, {int? limit, int? offset}) async {
    final query = _db.select(_db.bills)
      ..where((t) => t.phone.equals(phone))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }

  Future<List<Bill>> getBillsByCollection(String phone, String collectionId) async {
    return (_db.select(_db.bills)
          ..where((t) => t.phone.equals(phone) & t.collectionId.equals(collectionId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<Bill>> getBillsByTag(String phone, String tagId) async {
    final query = '''
      SELECT bills.* FROM bills
      INNER JOIN bill_tags ON bills.id = bill_tags.bill_id
      WHERE bills.phone = ? AND bill_tags.tag_id = ?
      ORDER BY bills.created_at DESC
    ''';
    final result = await _db.customSelect(query, variables: [
      Variable.withString(phone),
      Variable.withString(tagId),
    ]).get();
    return result.map((row) => Bill(
      id: row.read<String>('id'),
      title: row.read<String>('title'),
      ocrContent: row.read<String>('ocr_content'),
      location: row.readNullable<String>('location'),
      remark: row.readNullable<String>('remark'),
      collectionId: row.readNullable<String>('collection_id'),
      phone: row.read<String>('phone'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime>('updated_at'),
    )).toList();
  }

  Future<List<Bill>> searchBills(String phone, String keyword) async {
    final pattern = '%$keyword%';
    return (_db.select(_db.bills)
          ..where((t) => t.phone.equals(phone) &
              (t.title.like(pattern) | t.ocrContent.like(pattern)))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Bill?> getBillById(String id) async {
    return (_db.select(_db.bills)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<String> createBill(BillsCompanion bill) async {
    await _db.into(_db.bills).insert(bill);
    return bill.id.value;
  }

  Future<void> updateBill(Bill bill) async {
    await _db.update(_db.bills).replace(bill);
  }

  Future<void> deleteBill(String id) async {
    await (_db.delete(_db.bills)..where((t) => t.id.equals(id))).go();
  }

  Future<int> getBillCount(String phone) async {
    final count = _db.bills.id.count();
    final query = _db.selectOnly(_db.bills)
      ..addColumns([count])
      ..where(_db.bills.phone.equals(phone));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Stream<List<Bill>> watchAllBills(String phone) {
    return (_db.select(_db.bills)
          ..where((t) => t.phone.equals(phone))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}
