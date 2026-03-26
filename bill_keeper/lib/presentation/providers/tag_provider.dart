import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/domain/models/tag.dart';
import 'package:bill_keeper/data/providers/database_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

final tagListProvider = FutureProvider<List<Tag>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final phone = await db.usersDao.getCurrentPhone();
  if (phone == null) return [];

  final tags = await db.tagsDao.getAllTags(phone);
  return tags.map((t) => Tag(
    id: t.id,
    name: t.name,
    phone: t.phone,
    createdAt: t.createdAt,
  )).toList();
});

class TagNotifier extends StateNotifier<AsyncValue<List<Tag>>> {
  final Ref _ref;

  TagNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      _ref.invalidate(tagListProvider);
      final tags = await _ref.read(tagListProvider.future);
      state = AsyncValue.data(tags);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> createTag(String name) async {
    try {
      final db = _ref.read(appDatabaseProvider);
      final phone = await db.usersDao.getCurrentPhone();
      if (phone == null) return null;

      final existing = await db.tagsDao.getTagByName(phone, name);
      if (existing != null) return existing.id;

      final id = const Uuid().v4();
      await db.tagsDao.createTag(TagsCompanion.insert(
        id: id,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      ));

      await _load();
      _ref.invalidate(tagListProvider);
      return id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateTag(String id, String name) async {
    try {
      final db = _ref.read(appDatabaseProvider);
      final existing = await db.tagsDao.getTagById(id);
      if (existing == null) return false;

      await db.tagsDao.updateTag(existing.copyWith(name: name));
      await _load();
      _ref.invalidate(tagListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTag(String id) async {
    try {
      final db = _ref.read(appDatabaseProvider);
      await db.tagsDao.deleteTag(id);
      await _load();
      _ref.invalidate(tagListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> mergeTags(String sourceTagId, String targetTagId) async {
    try {
      final db = _ref.read(appDatabaseProvider);
      await db.tagsDao.mergeTags(sourceTagId, targetTagId);
      await _load();
      _ref.invalidate(tagListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  void refresh() {
    _load();
    _ref.invalidate(tagListProvider);
  }
}

final tagNotifierProvider = StateNotifierProvider<TagNotifier, AsyncValue<List<Tag>>>((ref) {
  return TagNotifier(ref);
});
