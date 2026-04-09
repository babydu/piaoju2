import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/data/database/app_database.dart';
import 'package:bill_keeper/data/database/daos/user_dao.dart';
import 'package:bill_keeper/data/database/daos/bill_dao.dart';
import 'package:bill_keeper/data/database/daos/bill_image_dao.dart';
import 'package:bill_keeper/data/database/daos/tag_dao.dart';
import 'package:bill_keeper/data/database/daos/collection_dao.dart';
import 'package:bill_keeper/data/database/daos/recycle_bin_dao.dart';
import 'package:bill_keeper/data/database/daos/bill_tag_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

final userDaoProvider = Provider<UserDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserDao(db);
});

final billDaoProvider = Provider<BillDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BillDao(db);
});

final billImageDaoProvider = Provider<BillImageDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BillImageDao(db);
});

final tagDaoProvider = Provider<TagDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TagDao(db);
});

final collectionDaoProvider = Provider<CollectionDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CollectionDao(db);
});

final recycleBinDaoProvider = Provider<RecycleBinDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RecycleBinDao(db);
});

final billTagDaoProvider = Provider<BillTagDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BillTagDao(db);
});
