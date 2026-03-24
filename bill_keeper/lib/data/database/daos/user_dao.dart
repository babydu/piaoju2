import 'package:drift/drift.dart';
import '../app_database.dart';

class UserDao {
  final AppDatabase _db;

  UserDao(this._db);

  Future<User?> getUserByPhone(String phone) async {
    return (_db.select(_db.users)..where((t) => t.phone.equals(phone))).getSingleOrNull();
  }

  Future<User> createUser(String phone) async {
    final user = UsersCompanion.insert(
      phone: phone,
      createdAt: DateTime.now(),
    );
    await _db.into(_db.users).insert(user);
    return (await getUserByPhone(phone))!;
  }

  Future<void> updateNickname(String phone, String? nickname) async {
    await (_db.update(_db.users)..where((t) => t.phone.equals(phone)))
        .write(UsersCompanion(nickname: Value(nickname)));
  }

  Future<void> updateStorageUsed(String phone, int used) async {
    await (_db.update(_db.users)..where((t) => t.phone.equals(phone)))
        .write(UsersCompanion(storageUsed: Value(used)));
  }

  Stream<User?> watchUser(String phone) {
    return (_db.select(_db.users)..where((t) => t.phone.equals(phone)))
        .watchSingleOrNull();
  }
}
