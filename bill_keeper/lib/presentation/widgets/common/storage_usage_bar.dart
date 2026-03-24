import 'package:flutter/material.dart';

class StorageUsageBar extends StatelessWidget {
  final int usedBytes;
  final int totalBytes;

  const StorageUsageBar({
    super.key,
    required this.usedBytes,
    required this.totalBytes,
  });

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  double get _percentage => totalBytes > 0 ? usedBytes / totalBytes : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '存储空间',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              '${_formatBytes(usedBytes)} / ${_formatBytes(totalBytes)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _percentage,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            _percentage > 0.9 ? Colors.red : Colors.blue,
          ),
        ),
      ],
    );
  }
}
