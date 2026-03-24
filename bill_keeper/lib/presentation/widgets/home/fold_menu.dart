import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FoldMenu extends StatelessWidget {
  final VoidCallback onClose;

  const FoldMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      width: 280,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '菜单',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _MenuItem(
                icon: Icons.delete_outline,
                title: '回收站',
                onTap: () {
                  onClose();
                  context.push('/recycle-bin');
                },
              ),
              _MenuItem(
                icon: Icons.label_outline,
                title: '标签管理',
                onTap: () {
                  onClose();
                  context.push('/tag-management');
                },
              ),
              _MenuItem(
                icon: Icons.folder_outlined,
                title: '合集管理',
                onTap: () {
                  onClose();
                  context.push('/collection-management');
                },
              ),
              _MenuItem(
                icon: Icons.settings_outlined,
                title: '设置',
                onTap: () {
                  onClose();
                  context.push('/settings');
                },
              ),
              _MenuItem(
                icon: Icons.help_outline,
                title: '帮助反馈',
                onTap: () {
                  onClose();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
