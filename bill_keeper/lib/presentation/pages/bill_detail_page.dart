import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bill_keeper/presentation/providers/bill_provider.dart';
import 'package:bill_keeper/presentation/providers/collection_provider.dart';
import 'package:bill_keeper/domain/models/bill.dart';
import 'package:share_plus/share_plus.dart';

class BillDetailPage extends ConsumerStatefulWidget {
  final String id;

  const BillDetailPage({super.key, required this.id});

  @override
  ConsumerState<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends ConsumerState<BillDetailPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billAsync = ref.watch(billDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('票据详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/bill/${widget.id}/edit'),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'share', child: Text('分享')),
              const PopupMenuItem(value: 'delete', child: Text('删除')),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(context);
              } else if (value == 'share') {
                _shareBill(billAsync.valueOrNull);
              }
            },
          ),
        ],
      ),
      body: billAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
        data: (bill) {
          if (bill == null) {
            return const Center(child: Text('票据不存在'));
          }
          return _buildContent(bill);
        },
      ),
    );
  }

  Widget _buildContent(Bill bill) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bill.images.isNotEmpty) _buildImageCarousel(bill),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.title.isEmpty ? '未命名票据' : bill.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '创建于 ${_formatDate(bill.createdAt)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 16),
                if (bill.tags.isNotEmpty) _buildTagsSection(bill),
                if (bill.collectionId != null) _buildCollectionSection(bill),
                if (bill.location != null && bill.location!.isNotEmpty)
                  _buildInfoCard('位置', bill.location!),
                if (bill.remark != null && bill.remark!.isNotEmpty)
                  _buildInfoCard('备注', bill.remark!),
                if (bill.ocrContent.isNotEmpty) _buildOcrSection(bill),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(Bill bill) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bill.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final image = bill.images[index];
              return GestureDetector(
                onTap: () => _showFullScreenImage(image.localPath),
                onLongPress: () => _showImageOptions(bill, index),
                child: Image.file(
                  File(image.localPath),
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),
        if (bill.images.length > 1)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bill.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? Colors.blue
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTagsSection(Bill bill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('标签', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bill.tags.map((tag) {
              return Chip(
                label: Text(tag.name),
                backgroundColor: Colors.blue.shade50,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionSection(Bill bill) {
    final collectionsAsync = ref.watch(collectionListProvider);
    
    return collectionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (collections) {
        final collection = collections.where((c) => c.id == bill.collectionId).firstOrNull;
        if (collection == null) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('合集', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.folder, size: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(collection.name),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(content),
          ),
        ],
      ),
    );
  }

  Widget _buildOcrSection(Bill bill) {
    final isLong = bill.ocrContent.length > 200;
    final displayText = isLong 
        ? '${bill.ocrContent.substring(0, 200)}...' 
        : bill.ocrContent;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.text_fields, size: 20),
              SizedBox(width: 8),
              Text('识别文字', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayText),
                if (isLong)
                  TextButton(
                    onPressed: () => _showFullOcrText(bill.ocrContent),
                    child: const Text('展开全部'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(File(path)),
            ),
          ),
        ),
      ),
    );
  }

  void _showImageOptions(Bill bill, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除'),
              onTap: () {
                Navigator.pop(context);
                _deleteImage(bill, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteImage(Bill bill, int index) async {
    if (bill.images.length == 1) {
      _showDeleteDialog(context);
      return;
    }
    
    final success = await ref.read(billNotifierProvider.notifier).deleteBill(bill.id);
    if (success && mounted) {
      ref.invalidate(billDetailProvider(widget.id));
    }
  }

  void _showFullOcrText(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('识别文字'),
        content: SingleChildScrollView(
          child: Text(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _shareBill(Bill? bill) {
    if (bill == null) return;
    
    final shareText = StringBuffer();
    shareText.writeln(bill.title.isEmpty ? '未命名票据' : bill.title);
    if (bill.ocrContent.isNotEmpty) {
      shareText.writeln('\n识别内容:\n${bill.ocrContent}');
    }
    if (bill.location != null && bill.location!.isNotEmpty) {
      shareText.writeln('\n位置: ${bill.location}');
    }
    
    Share.share(shareText.toString());
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除票据'),
        content: const Text('确定要删除这个票据吗？删除后可在回收站中恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(billNotifierProvider.notifier).deleteBill(widget.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已移入回收站')),
                );
                context.pop();
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
