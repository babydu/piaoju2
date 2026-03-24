import 'package:flutter/material.dart';
import 'package:bill_keeper/domain/models/tag.dart';

class TagSelectDialog extends StatefulWidget {
  final List<Tag> availableTags;
  final List<Tag> selectedTags;
  final Function(List<Tag>) onConfirm;

  const TagSelectDialog({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onConfirm,
  });

  @override
  State<TagSelectDialog> createState() => _TagSelectDialogState();
}

class _TagSelectDialogState extends State<TagSelectDialog> {
  late List<Tag> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择标签'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.availableTags.length,
          itemBuilder: (context, index) {
            final tag = widget.availableTags[index];
            final isSelected = _selectedTags.any((t) => t.id == tag.id);

            return CheckboxListTile(
              title: Text(tag.name),
              value: isSelected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.removeWhere((t) => t.id == tag.id);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(_selectedTags);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
