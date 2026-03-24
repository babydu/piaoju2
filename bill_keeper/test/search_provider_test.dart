import 'package:flutter_test/flutter_test.dart';
import 'package:bill_keeper/presentation/providers/search_provider.dart';

void main() {
  group('SearchFilter', () {
    test('默认筛选器创建正确', () {
      const filter = SearchFilter();
      expect(filter.tagId, isNull);
      expect(filter.collectionId, isNull);
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.sortBy, equals(SearchSortBy.timeDesc));
    });

    test('筛选器复制正确', () {
      const filter = SearchFilter(
        tagId: 'tag1',
        collectionId: 'collection1',
        sortBy: SearchSortBy.timeAsc,
      );
      
      final newFilter = filter.copyWith(collectionId: 'collection2');
      
      expect(newFilter.tagId, equals('tag1'));
      expect(newFilter.collectionId, equals('collection2'));
      expect(newFilter.sortBy, equals(SearchSortBy.timeAsc));
    });

    test('清除标签筛选', () {
      const filter = SearchFilter(tagId: 'tag1', collectionId: 'collection1');
      final cleared = filter.clearTag();
      
      expect(cleared.tagId, isNull);
      expect(cleared.collectionId, equals('collection1'));
    });

    test('清除合集筛选', () {
      const filter = SearchFilter(tagId: 'tag1', collectionId: 'collection1');
      final cleared = filter.clearCollection();
      
      expect(cleared.tagId, equals('tag1'));
      expect(cleared.collectionId, isNull);
    });
  });

  group('SearchSortBy', () {
    test('枚举值正确', () {
      expect(SearchSortBy.values.length, equals(3));
      expect(SearchSortBy.timeDesc.index, equals(0));
      expect(SearchSortBy.timeAsc.index, equals(1));
      expect(SearchSortBy.relevance.index, equals(2));
    });
  });
}
