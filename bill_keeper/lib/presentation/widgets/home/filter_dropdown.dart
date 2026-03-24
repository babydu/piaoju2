import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/presentation/providers/collection_provider.dart';
import 'package:bill_keeper/presentation/providers/tag_provider.dart';
import 'package:bill_keeper/presentation/providers/bill_provider.dart';

class FilterDropdown extends ConsumerWidget {
  const FilterDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionListProvider).valueOrNull ?? [];
    final tags = ref.watch(tagListProvider).valueOrNull ?? [];
    final currentFilter = ref.watch(billFilterProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String?>(
              value: currentFilter?.collectionId,
              hint: const Text('选择合集'),
              isExpanded: true,
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部合集')),
                ...collections.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                )),
              ],
              onChanged: (value) {
                ref.read(billFilterProvider.notifier).state = BillFilter(
                  collectionId: value,
                  tagId: currentFilter?.tagId,
                );
              },
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: DropdownButton<String?>(
              value: currentFilter?.tagId,
              hint: const Text('选择标签'),
              isExpanded: true,
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem(value: null, child: Text('全部标签')),
                ...tags.map((t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(t.name),
                )),
              ],
              onChanged: (value) {
                ref.read(billFilterProvider.notifier).state = BillFilter(
                  collectionId: currentFilter?.collectionId,
                  tagId: value,
                );
              },
            ),
          ),
          if (currentFilter != null)
            IconButton(
              onPressed: () {
                ref.read(billFilterProvider.notifier).state = null;
              },
              icon: const Icon(Icons.clear, size: 20),
              tooltip: '清除筛选',
            ),
        ],
      ),
    );
  }
}
