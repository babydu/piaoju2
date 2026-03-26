import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/domain/models/collection.dart';
import 'package:bill_keeper/data/providers/database_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

final collectionListProvider = FutureProvider<List<Collection>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final phone = await db.usersDao.getCurrentPhone();
  if (phone == null) return [];

  final collections = await db.collectionDao.getAllCollections(phone);
  final result = <Collection>[];
  
  for (final c in collections) {
    final count = await db.collectionDao.getBillCountInCollection(c.id);
    result.add(Collection(
      id: c.id,
      name: c.name,
      userPhone: c.userPhone,
      createdAt: c.createdAt,
      billCount: count,
    ));
  }
  
  return result;
});

class CollectionNotifier extends StateNotifier<AsyncValue<List<Collection>>> {
  final Ref _ref;

  CollectionNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      _ref.invalidate(collectionListProvider);
      final collections = await _ref.read(collectionListProvider.future);
      state = AsyncValue.data(collections);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> createCollection(String name) async {
    try {
      final db = _ref.read(appDatabaseProvider);
      final phone = await db.usersDao.getCurrentPhone();
      if (phone == null) return null;

      final id = const Uuid().v4();
      await db.collectionDao.createCollection(CollectionsCompanion.insert(
        id: id,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      ));

      await _load();
      _ref.invalidate(collectionListProvider);
      return id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateCollection(String id, String name) async {
    try {
      final db = _ref.read(appDatabaseProvider);
      final existing = await db.collectionDao.getCollectionById(id);
      if (existing == null) return false;

      await db.collectionDao.updateCollection(existing.copyWith(name: name));
      await _load();
      _ref.invalidate(collectionListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCollection(String id) async {
    try {
      final db = _ref.read(appDatabaseProvider);
      await db.collectionDao.deleteCollection(id);
      await _load();
      _ref.invalidate(collectionListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  void refresh() {
    _load();
    _ref.invalidate(collectionListProvider);
  }
}

final collectionNotifierProvider = StateNotifierProvider<CollectionNotifier, AsyncValue<List<Collection>>>((ref) {
  return CollectionNotifier(ref);
});
