import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bill_keeper/presentation/providers/bill_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final List<String> _searchHistory = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      if (!_searchHistory.contains(keyword)) {
        _searchHistory.insert(0, keyword);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      }
    });

    ref.read(billFilterProvider.notifier).state = BillFilter(keyword: keyword);
  }

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '搜索票据标题或内容',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('搜索'),
                ),
              ],
            ),
          ),
          if (_searchHistory.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('搜索历史', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchHistory.clear();
                      });
                    },
                    child: const Text('清除'),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              children: _searchHistory.map((keyword) {
                return Chip(
                  label: Text(keyword),
                  onDeleted: () {
                    setState(() {
                      _searchHistory.remove(keyword);
                    });
                  },
                );
              }).toList(),
            ),
          ],
          const Expanded(
            child: Center(
              child: Text('第三阶段功能', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}
