import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bill_keeper/presentation/providers/search_provider.dart';
import 'package:bill_keeper/presentation/providers/collection_provider.dart';
import 'package:bill_keeper/presentation/providers/tag_provider.dart';
import 'package:bill_keeper/presentation/widgets/bill/bill_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _search() {
    final keyword = _searchController.text.trim();
    ref.read(searchQueryProvider.notifier).state = keyword;
    if (keyword.isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).addSearch(keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchHistory = ref.watch(searchHistoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final filter = ref.watch(searchFilterProvider);
    final collectionsAsync = ref.watch(collectionListProvider);
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: '搜索票据标题或内容',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (_) => _search(),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: filter.tagId != null ? '标签筛选' : '标签',
                        selected: filter.tagId != null,
                        onPressed: () => _showTagFilter(tagsAsync),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: filter.collectionId != null ? '合集筛选' : '合集',
                        selected: filter.collectionId != null,
                        onPressed: () => _showCollectionFilter(collectionsAsync),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: _getDateRangeLabel(filter),
                        selected: filter.startDate != null || filter.endDate != null,
                        onPressed: () => _showDateRangePicker(filter),
                      ),
                      if (filter.tagId != null || filter.collectionId != null || filter.startDate != null)
                        TextButton(
                          onPressed: () {
                            ref.read(searchFilterProvider.notifier).clear();
                          },
                          child: const Text('清除筛选'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (searchQuery.isEmpty && filter.tagId == null && filter.collectionId == null)
            Expanded(
              child: _buildSearchHistory(searchHistory),
            )
          else if (searchQuery.isEmpty && filter.tagId == null && filter.collectionId == null)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('输入关键词搜索票据', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('搜索: $searchQuery', style: const TextStyle(color: Colors.grey)),
                    if (filter.tagId != null)
                      Text('标签筛选: ${filter.tagId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPressed(),
    );
  }

  String _getDateRangeLabel(SearchFilter filter) {
    if (filter.startDate == null && filter.endDate == null) {
      return '日期';
    }
    if (filter.startDate != null && filter.endDate != null) {
      return '${filter.startDate!.month}/${filter.startDate!.day} - ${filter.endDate!.month}/${filter.endDate!.day}';
    }
    if (filter.startDate != null) {
      return '从 ${filter.startDate!.month}/${filter.startDate!.day}';
    }
    return '至 ${filter.endDate!.month}/${filter.endDate!.day}';
  }

  Widget _buildSearchHistory(List<String> history) {
    if (history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无搜索历史', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('搜索历史', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                ref.read(searchHistoryProvider.notifier).clearHistory();
              },
              child: const Text('清除'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: history.map((keyword) {
            return Chip(
              label: Text(keyword),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                ref.read(searchHistoryProvider.notifier).removeSearch(keyword);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showTagFilter(AsyncValue<List<dynamic>> tagsAsync) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('选择标签', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              tagsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('加载失败'),
                data: (tags) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: tags.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: const Icon(Icons.clear),
                        title: const Text('不限标签'),
                        onTap: () {
                          ref.read(searchFilterProvider.notifier).setTag(null);
                          Navigator.pop(context);
                        },
                      );
                    }
                    final tag = tags[index - 1];
                    return ListTile(
                      leading: const Icon(Icons.label),
                      title: Text(tag.name),
                      onTap: () {
                        ref.read(searchFilterProvider.notifier).setTag(tag.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCollectionFilter(AsyncValue<List<dynamic>> collectionsAsync) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('选择合集', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              collectionsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('加载失败'),
                data: (collections) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: collections.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: const Icon(Icons.clear),
                        title: const Text('不限合集'),
                        onTap: () {
                          ref.read(searchFilterProvider.notifier).setCollection(null);
                          Navigator.pop(context);
                        },
                      );
                    }
                    final collection = collections[index - 1];
                    return ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(collection.name),
                      onTap: () {
                        ref.read(searchFilterProvider.notifier).setCollection(collection.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDateRangePicker(SearchFilter filter) async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: filter.startDate != null && filter.endDate != null
          ? DateTimeRange(start: filter.startDate!, end: filter.endDate!)
          : null,
    );

    if (range != null) {
      ref.read(searchFilterProvider.notifier).setDateRange(range.start, range.end);
    }
  }
}
