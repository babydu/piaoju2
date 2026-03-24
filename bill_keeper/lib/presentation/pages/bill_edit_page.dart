import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BillEditPage extends StatelessWidget {
  final String id;

  const BillEditPage({super.key, required this.id});

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
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('保存成功')),
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
            Icon(Icons.edit_document, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('票据编辑页面', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('第二阶段功能', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
