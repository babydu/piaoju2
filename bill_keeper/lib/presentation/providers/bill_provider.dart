import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/domain/models/bill.dart';

final billListProvider = FutureProvider<List<Bill>>((ref) async {
  // TODO: Replace with actual database query
  await Future.delayed(const Duration(milliseconds: 500));
  return [];
});

final billDetailProvider = FutureProvider.family<Bill?, String>((ref, id) async {
  // TODO: Replace with actual database query
  await Future.delayed(const Duration(milliseconds: 300));
  return null;
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
