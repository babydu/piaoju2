import 'package:drift/drift.dart';
import '../app_database.dart';

class BillImageDao {
  final AppDatabase _db;

  BillImageDao(this._db);

  Future<List<BillImage>> getImagesByBillId(String billId) async {
    return (_db.select(_db.billImages)
          ..where((t) => t.billId.equals(billId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<BillImage?> getFirstImageByBillId(String billId) async {
    return (_db.select(_db.billImages)
          ..where((t) => t.billId.equals(billId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<String> createImage(BillImagesCompanion image) async {
    await _db.into(_db.billImages).insert(image);
    return image.id.value;
  }

  Future<void> updateImage(BillImage image) async {
    await _db.update(_db.billImages).replace(image);
  }

  Future<void> deleteImage(String id) async {
    await (_db.delete(_db.billImages)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteImagesByBillId(String billId) async {
    await (_db.delete(_db.billImages)..where((t) => t.billId.equals(billId))).go();
  }

  Stream<List<BillImage>> watchImagesByBillId(String billId) {
    return (_db.select(_db.billImages)
          ..where((t) => t.billId.equals(billId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }
}
