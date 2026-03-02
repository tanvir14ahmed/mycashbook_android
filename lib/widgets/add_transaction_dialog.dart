import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/book_provider.dart';
import 'package:intl/intl.dart';

class AddTransactionDialog extends StatefulWidget {
  final int bookId;
  const AddTransactionDialog({super.key, required this.bookId});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'withdraw';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (৳)', prefixIcon: Icon(Icons.money)),
            ),
            const SizedBox(height: 16),
            
            // Type
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Out', style: TextStyle(fontSize: 12)),
                    value: 'withdraw',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('In', style: TextStyle(fontSize: 12)),
                    value: 'deposit',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
              ],
            ),
            
            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('dd MMM, yyyy').format(_selectedDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            
            // Note
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Note (Optional)', prefixIcon: Icon(Icons.notes)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;
    
    final amount = double.tryParse(amountText);
    if (amount == null) return;

    setState(() => _isLoading = true);
    final success = await Provider.of<TransactionProvider>(context, listen: false).addTransaction(
      bookId: widget.bookId,
      amount: amount,
      type: _type,
      note: _noteController.text.trim(),
      createdAt: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );
    
    if (success && mounted) {
      await Provider.of<BookProvider>(context, listen: false).fetchBooks();
      Navigator.pop(context);
    }
    setState(() => _isLoading = false);
  }
}
