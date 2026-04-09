import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bill_keeper/presentation/providers/upload_provider.dart';
import 'package:bill_keeper/presentation/providers/collection_provider.dart';
import 'package:bill_keeper/presentation/providers/bill_provider.dart';

class ImageEditPage extends ConsumerStatefulWidget {
  const ImageEditPage({super.key});

  @override
  ConsumerState<ImageEditPage> createState() => _ImageEditPageState();
}

class _ImageEditPageState extends ConsumerState<ImageEditPage> {
  final _titleController = TextEditingController();
  final _ocrController = TextEditingController();
  final _remarkController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uploadNotifierProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ocrController.dispose();
    _remarkController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);
    final collectionsAsync = ref.watch(collectionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑票据'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: uploadState.isLoading ? null : _saveBill,
            child: uploadState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(uploadState),
                  const SizedBox(height: 16),
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildOcrSection(uploadState),
                  const SizedBox(height: 16),
                  _buildTagSection(uploadState),
                  const SizedBox(height: 16),
                  _buildCollectionSection(collectionsAsync),
                  const SizedBox(height: 16),
                  _buildLocationField(),
                  const SizedBox(height: 16),
                  _buildRemarkField(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(UploadState state) {
    if (state.images.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('添加图片', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ref.read(uploadNotifierProvider.notifier).pickFromCamera(),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍照'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => ref.read(uploadNotifierProvider.notifier).pickFromGallery(),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('相册'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: state.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final image = state.images[index];
                  final path = image.processedPath ?? image.originalPath;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (image.isProcessing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                    ],
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    final image = state.images[_currentPage];
                    ref.read(uploadNotifierProvider.notifier).removeImage(image.id);
                    if (_currentPage >= state.images.length - 1) {
                      _pageController.jumpToPage(
                        (state.images.length - 2).clamp(0, state.images.length - 1),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    state.images.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => ref.read(uploadNotifierProvider.notifier).pickFromGallery(),
              icon: const Icon(Icons.add),
              label: const Text('添加图片'),
            ),
            const SizedBox(width: 16),
            if (state.images.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  final image = state.images[_currentPage];
                  ref.read(uploadNotifierProvider.notifier).scanAndCorrect(image.id);
                },
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('扫描矫正'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: '标题',
        hintText: '请输入票据标题（可选）',
        prefixIcon: Icon(Icons.title),
      ),
      onChanged: (value) {
        ref.read(uploadNotifierProvider.notifier).updateTitle(value);
      },
    );
  }

  Widget _buildOcrSection(UploadState state) {
    final isOcrProcessing = state.images.any((img) => img.isOcrProcessing);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.text_fields, size: 20),
            const SizedBox(width: 8),
            const Text('文字识别', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: isOcrProcessing
                  ? null
                  : () => ref.read(uploadNotifierProvider.notifier).recognizeText(),
              icon: isOcrProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera, size: 16),
              label: Text(isOcrProcessing ? '识别中...' : '识别文字'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ocrController..text = state.ocrContent,
          decoration: const InputDecoration(
            hintText: '点击"识别文字"自动提取，或手动输入',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          onChanged: (value) {
            ref.read(uploadNotifierProvider.notifier).updateOcrContent(value);
          },
        ),
      ],
    );
  }

  Widget _buildTagSection(UploadState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.label, size: 20),
            SizedBox(width: 8),
            Text('标签', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...state.selectedTags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    ref.read(uploadNotifierProvider.notifier).removeTag(tag);
                  },
                )),
            ...state.images
                .expand((img) => img.recommendedTags)
                .where((tag) => !state.selectedTags.contains(tag))
                .toSet()
                .map((tag) => ActionChip(
                      label: Text(tag),
                      onPressed: () {
                        ref.read(uploadNotifierProvider.notifier).addTag(tag);
                      },
                    )),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: '添加自定义标签',
                  prefixIcon: Icon(Icons.add),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_tagController.text.isNotEmpty) {
                  ref.read(uploadNotifierProvider.notifier).addTag(_tagController.text.trim());
                  _tagController.clear();
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionSection(AsyncValue<List<dynamic>> collectionsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.folder, size: 20),
            SizedBox(width: 8),
            Text('合集', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        collectionsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('加载失败'),
          data: (collections) => DropdownButtonFormField<String?>(
            value: ref.read(uploadNotifierProvider).collectionId,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.folder_open),
            ),
            hint: const Text('选择合集（可选）'),
            items: [
              const DropdownMenuItem(value: null, child: Text('不加入合集')),
              ...collections.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  )),
            ],
            onChanged: (value) {
              ref.read(uploadNotifierProvider.notifier).updateCollection(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return TextField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: '位置',
        hintText: '自动从图片提取或手动输入',
        prefixIcon: Icon(Icons.location_on),
      ),
      onChanged: (value) {
        ref.read(uploadNotifierProvider.notifier).updateLocation(value);
      },
    );
  }

  Widget _buildRemarkField() {
    return TextField(
      controller: _remarkController,
      decoration: const InputDecoration(
        labelText: '备注',
        hintText: '添加备注信息（可选）',
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
      onChanged: (value) {
        ref.read(uploadNotifierProvider.notifier).updateRemark(value);
      },
    );
  }

  Future<void> _saveBill() async {
    final state = ref.read(uploadNotifierProvider);
    if (state.images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先添加图片')),
      );
      return;
    }

    final storageService = ref.read(storageServiceProvider);
    final imagePaths = <String>[];

    for (final image in state.images) {
      try {
        final sourcePath = image.processedPath ?? image.originalPath;
        final savedPath = await storageService.saveImage(
          File(sourcePath),
        );
        imagePaths.add(savedPath);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('图片保存失败: $e')),
          );
        }
        return;
      }
    }

    final billId = await ref.read(billNotifierProvider.notifier).createBill(
      title: state.title.isEmpty ? '未命名票据' : state.title,
      ocrContent: state.ocrContent,
      imagePaths: imagePaths,
      tagNames: state.selectedTags,
      collectionId: state.collectionId,
      location: state.location,
      remark: state.remark.isEmpty ? null : state.remark,
    );

    if (billId != null) {
      ref.read(uploadNotifierProvider.notifier).reset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('票据保存成功')),
        );
        context.go('/bill/$billId');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请重试')),
        );
      }
    }
  }
}
