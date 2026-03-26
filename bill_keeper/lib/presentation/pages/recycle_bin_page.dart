import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bill_keeper/data/providers/database_providers.dart';
import 'package:bill_keeper/data/database/daos/recycle_bin_dao.dart';

final recycleBinListProvider = FutureProvider<List<RecycledBill>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.recycleBinDao.getAllItems();
});

class RecycleBinPage extends ConsumerWidget {
  const RecycleBinPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(recycleBinListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('回收站'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('回收站为空', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('删除的票据将在此保留30天', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(item.title.isEmpty ? '未命名票据' : item.title),
                subtitle: Text('剩余 $item.remainingDays 天'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _restoreItem(context, ref, item),
                      child: const Text('恢复'),
                    ),
                    TextButton(
                      onPressed: () => _showDeleteDialog(context, ref, item),
                      child: const Text('彻底删除', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _restoreItem(BuildContext context, WidgetRef ref, RecycledBill item) async {
    try {
      final db = ref.read(appDatabaseProvider);
      await db.recycleBinDao.restoreItem(item.billId);
      ref.invalidate(recycleBinListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已恢复')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, RecycledBill item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('彻底删除'),
        content: const Text('确定要彻底删除吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _permanentlyDelete(context, ref, item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _permanentlyDelete(BuildContext context, WidgetRef ref, RecycledBill item) async {
    try {
      final db = ref.read(appDatabaseProvider);
      await db.recycleBinDao.permanentlyDelete(item.billId);
      ref.invalidate(recycleBinListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已彻底删除')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }
}
