import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/domain/models/collection.dart';

final collectionListProvider = FutureProvider<List<Collection>>((ref) async {
  // TODO: Replace with actual database query
  await Future.delayed(const Duration(milliseconds: 300));
  return [];
});
