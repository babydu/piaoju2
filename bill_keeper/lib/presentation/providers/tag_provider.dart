import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/domain/models/tag.dart';

final tagListProvider = FutureProvider<List<Tag>>((ref) async {
  // TODO: Replace with actual database query
  await Future.delayed(const Duration(milliseconds: 300));
  return [];
});
