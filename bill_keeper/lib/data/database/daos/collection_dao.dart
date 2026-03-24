import 'package:drift/drift.dart';
import '../app_database.dart';

class CollectionDao {
  final AppDatabase _db;

  CollectionDao(this._db);

  Future<List<Collection>> getAllCollections(String phone) async {
    return (_db.select(_db.collections)
          ..where((t) => t.phone.equals(phone))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<Collection?> getCollectionById(String id) async {
    return (_db.select(_db.collections)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<String> createCollection(CollectionsCompanion collection) async {
    await _db.into(_db.collections).insert(collection);
    return collection.id.value;
  }

  Future<void> updateCollection(Collection collection) async {
    await _db.update(_db.collections).replace(collection);
  }

  Future<void> deleteCollection(String id) async {
    await (_db.update(_db.bills)..where((t) => t.collectionId.equals(id)))
        .write(const BillsCompanion(collectionId: Value(null)));
    await (_db.delete(_db.collections)..where((t) => t.id.equals(id))).go();
  }

  Future<int> getBillCountInCollection(String collectionId) async {
    final count = _db.bills.id.count();
    final query = _db.selectOnly(_db.bills)
      ..addColumns([count])
      ..where(_db.bills.collectionId.equals(collectionId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Stream<List<Collection>> watchAllCollections(String phone) {
    return (_db.select(_db.collections)
          ..where((t) => t.phone.equals(phone))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }
}
