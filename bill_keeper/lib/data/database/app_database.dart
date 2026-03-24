import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get phone => text()();
  IntColumn get storageUsed => integer().withDefault(const Constant(0))();
  IntColumn get storageTotal => integer().withDefault(const Constant(1073741824))();
  TextColumn get nickname => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {phone};
}

class Bills extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get ocrContent => text().withDefault(const Constant(''))();
  TextColumn get location => text().nullable()();
  TextColumn get remark => text().nullable()();
  TextColumn get collectionId => text().nullable()();
  TextColumn get phone => text().references(Users, #phone)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BillImages extends Table {
  TextColumn get id => text()();
  TextColumn get billId => text().references(Bills, #id)();
  TextColumn get localPath => text()();
  TextColumn get thumbnailPath => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().references(Users, #phone)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().references(Users, #phone)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BillTags extends Table {
  TextColumn get billId => text().references(Bills, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {billId, tagId};
}

class RecycleBin extends Table {
  TextColumn get id => text()();
  TextColumn get billId => text().references(Bills, #id)();
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Users, Bills, BillImages, Collections, Tags, BillTags, RecycleBin])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await customStatement('CREATE INDEX IF NOT EXISTS idx_bills_phone ON bills(phone)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_bills_collection ON bills(collection_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_bills_created_at ON bills(created_at DESC)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_bill_images_bill_id ON bill_images(bill_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_collections_phone ON collections(phone)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_tags_phone ON tags(phone)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_bill_tags_bill ON bill_tags(bill_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_bill_tags_tag ON bill_tags(tag_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_recycle_bin_bill_id ON recycle_bin(bill_id)');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'bill_keeper.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
