import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/domain/models/bill.dart';
import 'package:bill_keeper/presentation/providers/auth_provider.dart';
import 'package:bill_keeper/presentation/providers/bill_provider.dart';
import 'package:bill_keeper/data/providers/database_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  static const _key = 'search_history';
  static const _maxCount = 10;

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    state = history;
  }

  Future<void> addSearch(String keyword) async {
    if (keyword.isEmpty) return;
    
    final newHistory = [
      keyword,
      ...state.where((k) => k != keyword),
    ].take(_maxCount).toList();
    
    state = newHistory;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newHistory);
  }

  Future<void> removeSearch(String keyword) async {
    final newHistory = state.where((k) => k != keyword).toList();
    state = newHistory;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newHistory);
  }

  Future<void> clearHistory() async {
    state = [];
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchFilterProvider = StateNotifierProvider<SearchFilterNotifier, SearchFilter>((ref) {
  return SearchFilterNotifier();
});

class SearchFilter {
  final String? tagId;
  final String? collectionId;
  final DateTime? startDate;
  final DateTime? endDate;
  final SearchSortBy sortBy;

  const SearchFilter({
    this.tagId,
    this.collectionId,
    this.startDate,
    this.endDate,
    this.sortBy = SearchSortBy.timeDesc,
  });

  SearchFilter copyWith({
    String? tagId,
    String? collectionId,
    DateTime? startDate,
    DateTime? endDate,
    SearchSortBy? sortBy,
  }) {
    return SearchFilter(
      tagId: tagId ?? this.tagId,
      collectionId: collectionId ?? this.collectionId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  SearchFilter clearTag() => SearchFilter(
    tagId: null,
    collectionId: collectionId,
    startDate: startDate,
    endDate: endDate,
    sortBy: sortBy,
  );

  SearchFilter clearCollection() => SearchFilter(
    tagId: tagId,
    collectionId: null,
    startDate: startDate,
    endDate: endDate,
    sortBy: sortBy,
  );

  SearchFilter clearDateRange() => SearchFilter(
    tagId: tagId,
    collectionId: collectionId,
    startDate: null,
    endDate: null,
    sortBy: sortBy,
  );
}

enum SearchSortBy {
  timeDesc,
  timeAsc,
  relevance,
}

class SearchFilterNotifier extends StateNotifier<SearchFilter> {
  SearchFilterNotifier() : super(const SearchFilter());

  void setTag(String? tagId) {
    state = state.copyWith(tagId: tagId);
  }

  void setCollection(String? collectionId) {
    state = state.copyWith(collectionId: collectionId);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = SearchFilter(
      tagId: state.tagId,
      collectionId: state.collectionId,
      startDate: start,
      endDate: end,
      sortBy: state.sortBy,
    );
  }

  void setSortBy(SearchSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void clear() {
    state = const SearchFilter();
  }
}

final searchResultsProvider = FutureProvider<List<Bill>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  final db = ref.watch(appDatabaseProvider);
  
  if (query.isEmpty && filter.tagId == null && filter.collectionId == null) {
    return [];
  }

  final phone = await db.usersDao.getCurrentPhone();
  if (phone == null) return [];

  List<Bill> results = [];

  if (query.isNotEmpty) {
    results = await db.billsDao.searchBills(phone, query);
  } else if (filter.collectionId != null) {
    results = await db.billsDao.getBillsByCollection(phone, filter.collectionId!);
  } else if (filter.tagId != null) {
    results = await db.billsDao.getBillsByTag(phone, filter.tagId!);
  } else {
    results = await db.billsDao.getAllBills(phone);
  }

  if (filter.startDate != null) {
    results = results.where((b) => b.createdAt.isAfter(filter.startDate!)).toList();
  }
  if (filter.endDate != null) {
    results = results.where((b) => b.createdAt.isBefore(filter.endDate!.add(const Duration(days: 1)))).toList();
  }

  if (filter.sortBy == SearchSortBy.timeDesc) {
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  } else if (filter.sortBy == SearchSortBy.timeAsc) {
    results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  final billsWithRelations = <Bill>[];
  for (final bill in results) {
    final images = await db.billImagesDao.getImagesByBillId(bill.id);
    final tagIds = await db.billTagsDao.getTagIdsForBill(bill.id);
    
    final tags = <dynamic>[];
    for (final tagId in tagIds) {
      final tag = await db.tagsDao.getTagById(tagId);
      if (tag != null) {
        tags.add(tag);
      }
    }

    billsWithRelations.add(bill.copyWith(
      images: images,
      tags: tags.cast(),
    ));
  }

  return billsWithRelations;
});
