import 'package:drift/drift.dart';
import '../app_database.dart';

class RecycleBinDao {
  final AppDatabase _db;

  RecycleBinDao(this._db);

  static const int retentionDays = 30;

  Future<List<RecycledBill>> getAllItems() async {
    final query = _db.select(_db.recycleBin).join([
      innerJoin(_db.bills, _db.bills.id.equalsExp(_db.recycleBin.billId)),
    ])..orderBy([OrderingTerm.desc(_db.recycleBin.deletedAt)]);

    final results = await query.get();
    return results.map((row) {
      final binItem = row.readTable(_db.recycleBin);
      final bill = row.readTable(_db.bills);
      final daysSinceDeleted = DateTime.now().difference(binItem.deletedAt).inDays;
      final remainingDays = retentionDays - daysSinceDeleted;
      
      return RecycledBill(
        id: binItem.id,
        billId: binItem.billId,
        deletedAt: binItem.deletedAt,
        title: bill.title,
        remainingDays: remainingDays > 0 ? remainingDays : 0,
      );
    }).toList();
  }

  Future<void> addItem(String billId) async {
    final existing = await (_db.select(_db.recycleBin)
          ..where((t) => t.billId.equals(billId)))
        .getSingleOrNull();
    
    if (existing == null) {
      await _db.into(_db.recycleBin).insert(RecycleBinCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        billId: billId,
        deletedAt: DateTime.now(),
      ));
    }
  }

  Future<void> removeItem(String billId) async {
    await (_db.delete(_db.recycleBin)..where((t) => t.billId.equals(billId))).go();
  }

  Future<void> permanentlyDelete(String billId) async {
    await (_db.delete(_db.billImages)..where((t) => t.billId.equals(billId))).go();
    await (_db.delete(_db.billTags)..where((t) => t.billId.equals(billId))).go();
    await (_db.delete(_db.bills)..where((t) => t.id.equals(billId))).go();
    await removeItem(billId);
  }

  Future<void> restoreItem(String billId) async {
    await removeItem(billId);
  }

  Future<void> cleanupExpiredItems() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: retentionDays));
    final expiredItems = await (_db.select(_db.recycleBin)
          ..where((t) => t.deletedAt.isSmallerThanValue(cutoffDate)))
        .get();
    
    for (final item in expiredItems) {
      await permanentlyDelete(item.billId);
    }
  }

  Stream<List<RecycledBill>> watchAllItems() {
    return (_db.select(_db.recycleBin).join([
      innerJoin(_db.bills, _db.bills.id.equalsExp(_db.recycleBin.billId)),
    ])..orderBy([OrderingTerm.desc(_db.recycleBin.deletedAt)]))
        .watch()
        .map((results) => results.map((row) {
      final binItem = row.readTable(_db.recycleBin);
      final bill = row.readTable(_db.bills);
      final daysSinceDeleted = DateTime.now().difference(binItem.deletedAt).inDays;
      final remainingDays = retentionDays - daysSinceDeleted;
      
      return RecycledBill(
        id: binItem.id,
        billId: binItem.billId,
        deletedAt: binItem.deletedAt,
        title: bill.title,
        remainingDays: remainingDays > 0 ? remainingDays : 0,
      );
    }).toList());
  }
}

class RecycledBill {
  final String id;
  final String billId;
  final DateTime deletedAt;
  final String title;
  final int remainingDays;

  RecycledBill({
    required this.id,
    required this.billId,
    required this.deletedAt,
    required this.title,
    required this.remainingDays,
  });
}
