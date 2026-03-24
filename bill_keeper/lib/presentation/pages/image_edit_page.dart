import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageEditPage extends StatelessWidget {
  const ImageEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑票据'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('保存功能开发中')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('图片编辑页面', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('第二阶段功能', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
