import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class AddBookDialog extends StatefulWidget {
  const AddBookDialog({super.key});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Book'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Book Name'),
          ),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description (Optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_nameController.text.isEmpty) return;
            setState(() => _isLoading = true);
            final success = await Provider.of<BookProvider>(context, listen: false).createBook(
              _nameController.text.trim(),
              _descController.text.trim(),
            );
            if (success && mounted) Navigator.pop(context);
            setState(() => _isLoading = false);
          },
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add'),
        ),
      ],
    );
  }
}
