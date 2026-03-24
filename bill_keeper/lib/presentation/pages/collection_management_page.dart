import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:bill_keeper/data/database/app_database.dart' show CollectionsCompanion;
import 'package:bill_keeper/data/database/daos/collection_dao.dart';
import 'package:uuid/uuid.dart';

final collectionDaoProvider = Provider<CollectionDao>((ref) {
  throw UnimplementedError('collectionDaoProvider must be overridden');
});

class CollectionManagementPage extends ConsumerStatefulWidget {
  const CollectionManagementPage({super.key});

  @override
  ConsumerState<CollectionManagementPage> createState() => _CollectionManagementPageState();
}

class _CollectionManagementPageState extends ConsumerState<CollectionManagementPage> {
  List<dynamic> _collections = [];
  Map<String, int> _billCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    try {
      final dao = ref.read(collectionDaoProvider);
      final phone = await _getCurrentPhone();
      if (phone != null) {
        _collections = await dao.getAllCollections(phone);
        
        _billCounts = {};
        for (final collection in _collections) {
          _billCounts[collection.id] = await dao.getBillCountInCollection(collection.id);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _getCurrentPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_phone');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('合集管理'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _collections.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('暂无合集', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Text(
                        '点击右下角按钮创建合集',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _collections.length,
                  itemBuilder: (context, index) {
                    final collection = _collections[index];
                    final billCount = _billCounts[collection.id] ?? 0;
                    return ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(collection.name),
                      subtitle: Text('$billCount 个票据'),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('编辑')),
                          const PopupMenuItem(value: 'delete', child: Text('删除')),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(collection);
                          } else if (value == 'delete') {
                            _showDeleteDialog(collection);
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建合集'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '合集名称',
            hintText: '请输入合集名称',
          ),
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              
              Navigator.pop(context);
              await _createCollection(name);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCollection(String name) async {
    try {
      final dao = ref.read(collectionDaoProvider);
      final phone = await _getCurrentPhone();
      if (phone == null) return;

      final id = const Uuid().v4();
      await dao.createCollection(
        CollectionsCompanion.insert(
          id: id,
          name: name,
          phone: phone,
          createdAt: DateTime.now(),
        ),
      );

      await _loadCollections();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('合集创建成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }

  void _showEditDialog(dynamic collection) {
    final controller = TextEditingController(text: collection.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑合集'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '合集名称',
          ),
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              
              Navigator.pop(context);
              await _updateCollection(collection.id, name);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCollection(String id, String name) async {
    try {
      final dao = ref.read(collectionDaoProvider);
      final existing = await dao.getCollectionById(id);
      if (existing == null) return;

      await dao.updateCollection(existing.copyWith(name: name));

      await _loadCollections();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('合集已更新')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(dynamic collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除合集'),
        content: Text('确定要删除合集 "${collection.name}" 吗？票据将保留但移出此合集。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCollection(collection.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCollection(String id) async {
    try {
      final dao = ref.read(collectionDaoProvider);
      await dao.deleteCollection(id);

      await _loadCollections();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('合集已删除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }
}
