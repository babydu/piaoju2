import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/domain/models/bill.dart';
import 'package:bill_keeper/domain/models/bill_image.dart';
import 'package:bill_keeper/domain/models/tag.dart';
import 'package:bill_keeper/data/providers/database_providers.dart';
import 'package:bill_keeper/data/database/app_database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

final billListProvider = FutureProvider<List<Bill>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final phone = await _getCurrentPhone(ref);
  if (phone == null) return [];

  final bills = await db.billsDao.getAllBills(phone);
  return Future.wait(bills.map((b) => _mapBillWithRelations(db, b)));
});

final billDetailProvider = FutureProvider.family<Bill?, String>((ref, id) async {
  final db = ref.watch(appDatabaseProvider);
  final bill = await db.billsDao.getBillById(id);
  if (bill == null) return null;
  return _mapBillWithRelations(db, bill);
});

final billFilterProvider = StateProvider<BillFilter?>((ref) => null);

class BillFilter {
  final String? collectionId;
  final String? tagId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? keyword;

  const BillFilter({
    this.collectionId,
    this.tagId,
    this.startDate,
    this.endDate,
    this.keyword,
  });
}

Future<String?> _getCurrentPhone(WidgetRef ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.usersDao.getCurrentPhone();
}

Future<Bill> _mapBillWithRelations(AppDatabase db, Bill bill) async {
  final images = await db.billImagesDao.getImagesByBillId(bill.id);
  final tagIds = await db.billTagsDao.getTagIdsForBill(bill.id);
  
  final tags = <Tag>[];
  for (final tagId in tagIds) {
    final driftTag = await db.tagsDao.getTagById(tagId);
    if (driftTag != null) {
      tags.add(Tag(
        id: driftTag.id,
        name: driftTag.name,
        userPhone: driftTag.phone,
        createdAt: driftTag.createdAt,
      ));
    }
  }

  return bill.copyWith(
    images: images.map((i) => BillImage(
      id: i.id,
      billId: i.billId,
      localPath: i.localPath,
      thumbnailPath: i.thumbnailPath,
      sortOrder: i.sortOrder,
    )).toList(),
    tags: tags,
  );
}

class BillNotifier extends StateNotifier<AsyncValue<List<Bill>>> {
  final AppDatabase _db;
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  BillNotifier(this._db, this._ref) : super(const AsyncValue.loading()) {
    _loadBills();
  }

  Future<void> _loadBills() async {
    state = const AsyncValue.loading();
    try {
      final phone = await _db.usersDao.getCurrentPhone();
      if (phone == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final bills = await _db.billsDao.getAllBills(phone);
      final mappedBills = await Future.wait(bills.map((b) => _mapBillWithRelations(_db, b)));
      state = AsyncValue.data(mappedBills);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> createBill({
    required String title,
    required String ocrContent,
    required List<String> imagePaths,
    List<String>? tagNames,
    String? collectionId,
    String? location,
    String? remark,
  }) async {
    try {
      final phone = await _db.usersDao.getCurrentPhone();
      if (phone == null) return null;

      final billId = _uuid.v4();
      final now = DateTime.now();

      await _db.into(_db.bills).insert(BillsCompanion.insert(
        id: billId,
        title: Value(title),
        ocrContent: Value(ocrContent),
        phone: phone,
        collectionId: Value(collectionId),
        location: Value(location),
        remark: Value(remark),
        createdAt: now,
        updatedAt: now,
      ));

      for (int i = 0; i < imagePaths.length; i++) {
        final imageId = _uuid.v4();
        await _db.into(_db.billImages).insert(BillImagesCompanion.insert(
          id: imageId,
          billId: billId,
          localPath: imagePaths[i],
          thumbnailPath: imagePaths[i],
          sortOrder: Value(i),
        ));
      }

      if (tagNames != null && tagNames.isNotEmpty) {
        for (final tagName in tagNames) {
          var tag = await _db.tagsDao.getTagByName(phone, tagName);
          if (tag == null) {
            final tagId = _uuid.v4();
            await _db.into(_db.tags).insert(TagsCompanion.insert(
              id: tagId,
              name: tagName,
              phone: phone,
              createdAt: now,
            ));
            tag = await _db.tagsDao.getTagById(tagId);
          }
          if (tag != null) {
            await _db.billTagsDao.addTagToBill(billId, tag.id);
          }
        }
      }

      await _loadBills();
      _ref.invalidate(billListProvider);
      return billId;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateBill({
    required String id,
    String? title,
    String? ocrContent,
    String? collectionId,
    String? location,
    String? remark,
    List<String>? tagNames,
  }) async {
    try {
      final existingBill = await _db.billsDao.getBillById(id);
      if (existingBill == null) return false;

      await _db.billsDao.updateBill(existingBill.copyWith(
        title: title ?? existingBill.title,
        ocrContent: ocrContent ?? existingBill.ocrContent,
        collectionId: collectionId ?? existingBill.collectionId,
        location: location ?? existingBill.location,
        remark: remark ?? existingBill.remark,
        updatedAt: DateTime.now(),
      ));

      if (tagNames != null) {
        final phone = await _db.usersDao.getCurrentPhone();
        if (phone != null) {
          final now = DateTime.now();
          final tagIds = <String>[];
          
          for (final tagName in tagNames) {
            var tag = await _db.tagsDao.getTagByName(phone, tagName);
            if (tag == null) {
              final tagId = _uuid.v4();
              await _db.into(_db.tags).insert(TagsCompanion.insert(
                id: tagId,
                name: tagName,
                phone: phone,
                createdAt: now,
              ));
              tag = await _db.tagsDao.getTagById(tagId);
            }
            if (tag != null) {
              tagIds.add(tag.id);
            }
          }
          await _db.billTagsDao.setTagsForBill(id, tagIds);
        }
      }

      await _loadBills();
      _ref.invalidate(billListProvider);
      _ref.invalidate(billDetailProvider(id));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBill(String id) async {
    try {
      final phone = await _db.usersDao.getCurrentPhone();
      if (phone == null) return false;

      await _db.recycleBinDao.addItem(id);
      await _loadBills();
      _ref.invalidate(billListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBillImage(String billId, String imageId) async {
    try {
      await _db.billImagesDao.deleteImage(imageId);
      _ref.invalidate(billDetailProvider(billId));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restoreBill(String id) async {
    try {
      await _db.recycleBinDao.restoreItem(id);
      await _loadBills();
      _ref.invalidate(billListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> permanentlyDeleteBill(String id) async {
    try {
      await _db.recycleBinDao.permanentlyDelete(id);
      await _loadBills();
      _ref.invalidate(billListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  void refresh() {
    _loadBills();
    _ref.invalidate(billListProvider);
  }
}

final billNotifierProvider = StateNotifierProvider<BillNotifier, AsyncValue<List<Bill>>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BillNotifier(db, ref);
});
