import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bill_keeper/presentation/providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('清除缓存'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearCacheDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('主题切换'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('浅')),
                ButtonSegment(value: ThemeMode.system, label: Text('系统')),
                ButtonSegment(value: ThemeMode.dark, label: Text('深')),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) {
                ref.read(themeModeProvider.notifier).setThemeMode(selection.first);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于我们'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicy(context),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('数据备份'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBackupDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('数据恢复'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRestoreDialog(context),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清理缓存吗？这将删除缩略图等临时文件，保留原始图片。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清理')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '票夹管家',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.receipt_long, size: 48),
      children: [
        const Text('票夹管家是一款个人票据收藏应用。'),
        const Text(''),
        const Text('用于拍照存档证件、门票、车票、发票等各类票据。'),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '票夹管家尊重并保护用户隐私。\n\n'
            '数据收集：我们仅收集您主动上传的票据图片和信息。\n\n'
            '数据存储：所有数据默认存储在您的设备本地，我们不会自动上传您的数据。\n\n'
            'OCR 识别：OCR 识别由用户手动触发，我们不会自动识别您的图片内容。\n\n'
            '数据共享：我们不会与任何第三方共享您的个人数据。',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据备份'),
        content: const Text('确定要备份所有数据吗？这将创建一个包含所有票据和图片的压缩文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('备份功能开发中')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据恢复'),
        content: const Text('选择备份文件恢复数据。注意：这将覆盖当前数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('恢复功能开发中')),
              );
            },
            child: const Text('选择文件'),
          ),
        ],
      ),
    );
  }
}
