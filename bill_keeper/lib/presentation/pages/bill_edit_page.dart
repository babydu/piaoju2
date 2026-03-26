import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bill_keeper/presentation/providers/bill_provider.dart';
import 'package:bill_keeper/presentation/providers/collection_provider.dart';
import 'package:bill_keeper/presentation/providers/tag_provider.dart';
import 'package:bill_keeper/domain/models/bill.dart';

class BillEditPage extends ConsumerStatefulWidget {
  final String id;

  const BillEditPage({super.key, required this.id});

  @override
  ConsumerState<BillEditPage> createState() => _BillEditPageState();
}

class _BillEditPageState extends ConsumerState<BillEditPage> {
  final _titleController = TextEditingController();
  final _ocrController = TextEditingController();
  final _remarkController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();
  
  Bill? _bill;
  List<String> _selectedTags = [];
  String? _selectedCollectionId;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBill();
  }

  Future<void> _loadBill() async {
    final bill = await ref.read(billDetailProvider(widget.id).future);
    if (bill != null && mounted) {
      setState(() {
        _bill = bill;
        _titleController.text = bill.title;
        _ocrController.text = bill.ocrContent;
        _remarkController.text = bill.remark ?? '';
        _locationController.text = bill.location ?? '';
        _selectedTags = bill.tags.map((t) => t.name).toList();
        _selectedCollectionId = bill.collectionId;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ocrController.dispose();
    _remarkController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('编辑票据')),
        body: const Center(child: Text('票据不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑票据'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveBill,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_bill!.images.isNotEmpty) ...[
              _buildImageSection(),
              const SizedBox(height: 16),
            ],
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildOcrField(),
            const SizedBox(height: 16),
            _buildTagSection(),
            const SizedBox(height: 16),
            _buildCollectionSection(),
            const SizedBox(height: 16),
            _buildLocationField(),
            const SizedBox(height: 16),
            _buildRemarkField(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('图片', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _bill!.images.length,
            itemBuilder: (context, index) {
              final image = _bill!.images[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(image.localPath),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: '标题',
        prefixIcon: Icon(Icons.title),
      ),
      maxLength: 100,
    );
  }

  Widget _buildOcrField() {
    return TextField(
      controller: _ocrController,
      decoration: const InputDecoration(
        labelText: '识别文字',
        prefixIcon: Icon(Icons.text_fields),
        hintText: 'OCR识别内容',
      ),
      maxLines: 4,
    );
  }

  Widget _buildTagSection() {
    final tagsAsync = ref.watch(tagListProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('标签', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._selectedTags.map((tag) => Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _selectedTags.remove(tag);
                });
              },
            )),
          ],
        ),
        const SizedBox(height: 8),
        tagsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('加载失败'),
          data: (tags) {
            final availableTags = tags.where((t) => !_selectedTags.contains(t.name)).toList();
            if (availableTags.isEmpty) {
              return Row(
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
                        setState(() {
                          _selectedTags.add(_tagController.text.trim());
                          _tagController.clear();
                        });
                      }
                    },
                    child: const Text('添加'),
                  ),
                ],
              );
            }
            return Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableTags.map((tag) => ActionChip(
                    label: Text(tag.name),
                    onPressed: () {
                      setState(() {
                        _selectedTags.add(tag.name);
                      });
                    },
                  )).toList(),
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
                          setState(() {
                            _selectedTags.add(_tagController.text.trim());
                            _tagController.clear();
                          });
                        }
                      },
                      child: const Text('添加'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCollectionSection() {
    final collectionsAsync = ref.watch(collectionListProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('合集', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        collectionsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('加载失败'),
          data: (collections) => DropdownButtonFormField<String?>(
            value: _selectedCollectionId,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.folder),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('不加入合集')),
              ...collections.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCollectionId = value;
              });
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
        prefixIcon: Icon(Icons.location_on),
      ),
    );
  }

  Widget _buildRemarkField() {
    return TextField(
      controller: _remarkController,
      decoration: const InputDecoration(
        labelText: '备注',
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
      maxLength: 500,
    );
  }

  Future<void> _saveBill() async {
    setState(() {
      _isSaving = true;
    });

    final success = await ref.read(billNotifierProvider.notifier).updateBill(
      id: widget.id,
      title: _titleController.text.trim(),
      ocrContent: _ocrController.text.trim(),
      collectionId: _selectedCollectionId,
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
      tagNames: _selectedTags,
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        ref.invalidate(billDetailProvider(widget.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请重试')),
        );
      }
    }
  }
}
