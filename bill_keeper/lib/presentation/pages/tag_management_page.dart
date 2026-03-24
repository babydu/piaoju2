import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:bill_keeper/data/database/app_database.dart' show TagsCompanion;
import 'package:bill_keeper/data/database/daos/tag_dao.dart';
import 'package:uuid/uuid.dart';

final tagDaoProvider = Provider<TagDao>((ref) {
  throw UnimplementedError('tagDaoProvider must be overridden');
});

class TagManagementPage extends ConsumerStatefulWidget {
  const TagManagementPage({super.key});

  @override
  ConsumerState<TagManagementPage> createState() => _TagManagementPageState();
}

class _TagManagementPageState extends ConsumerState<TagManagementPage> {
  List<dynamic> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    try {
      final dao = ref.read(tagDaoProvider);
      final phone = await _getCurrentPhone();
      if (phone != null) {
        _tags = await dao.getAllTags(phone);
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
        title: const Text('标签管理'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tags.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.label_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('暂无标签', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Text(
                        '在编辑票据时可以添加标签',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _tags.length,
                  itemBuilder: (context, index) {
                    final tag = _tags[index];
                    return ListTile(
                      leading: const Icon(Icons.label),
                      title: Text(tag.name),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('编辑')),
                          const PopupMenuItem(value: 'merge', child: Text('合并')),
                          const PopupMenuItem(value: 'delete', child: Text('删除')),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(tag);
                          } else if (value == 'merge') {
                            _showMergeDialog(tag);
                          } else if (value == 'delete') {
                            _showDeleteDialog(tag);
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
        title: const Text('新建标签'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '标签名称',
            hintText: '请输入标签名称',
          ),
          maxLength: 20,
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
              await _createTag(name);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _createTag(String name) async {
    try {
      final dao = ref.read(tagDaoProvider);
      final phone = await _getCurrentPhone();
      if (phone == null) return;

      final id = const Uuid().v4();
      await dao.createTag(
        TagsCompanion.insert(
          id: id,
          name: name,
          phone: phone,
          createdAt: DateTime.now(),
        ),
      );

      await _loadTags();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('标签创建成功')),
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

  void _showEditDialog(dynamic tag) {
    final controller = TextEditingController(text: tag.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑标签'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '标签名称',
          ),
          maxLength: 20,
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
              await _updateTag(tag.id, name);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTag(String id, String name) async {
    try {
      final dao = ref.read(tagDaoProvider);
      final existingTag = await dao.getTagById(id);
      if (existingTag == null) return;

      await dao.updateTag(existingTag.copyWith(name: name));

      await _loadTags();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('标签已更新')),
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

  void _showMergeDialog(dynamic sourceTag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('合并标签'),
        content: Text('将 "${sourceTag.name}" 合并到其他标签？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            child: const Text('选择目标标签'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除标签'),
        content: Text('确定要删除标签 "${tag.name}" 吗？该标签将从所有票据中移除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTag(tag.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTag(String id) async {
    try {
      final dao = ref.read(tagDaoProvider);
      await dao.deleteTag(id);

      await _loadTags();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('标签已删除')),
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
