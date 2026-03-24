import 'package:flutter/material.dart';

class InputDialog extends StatelessWidget {
  final String title;
  final String? hintText;
  final String? initialValue;
  final String confirmText;
  final String cancelText;
  final Function(String) onConfirm;
  final TextInputType? keyboardType;
  final int? maxLength;

  const InputDialog({
    super.key,
    required this.title,
    this.hintText,
    this.initialValue,
    this.confirmText = '确定',
    this.cancelText = '取消',
    required this.onConfirm,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm(controller.text);
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
