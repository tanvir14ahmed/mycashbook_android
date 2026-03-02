import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/book_provider.dart';
import '../models/transaction_model.dart';

class EditTransactionDialog extends StatefulWidget {
  final int bookId;
  final TransactionModel transaction;
  const EditTransactionDialog({super.key, required this.bookId, required this.transaction});

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _type;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _noteController = TextEditingController(text: widget.transaction.note);
    _type = widget.transaction.type;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (৳)', prefixIcon: Icon(Icons.money)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Withdrawal', style: TextStyle(fontSize: 12)),
                    value: 'withdraw',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Deposit', style: TextStyle(fontSize: 12)),
                    value: 'deposit',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
              ],
            ),
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
          onPressed: _isLoading ? null : _handleUpdate,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _handleUpdate() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;
    
    final amount = double.tryParse(amountText);
    if (amount == null) return;

    setState(() => _isLoading = true);
    final success = await Provider.of<TransactionProvider>(context, listen: false).updateTransaction(
      bookId: widget.bookId,
      transactionId: widget.transaction.id,
      amount: amount,
      type: _type,
      note: _noteController.text.trim(),
    );
    
    if (success && mounted) {
      await Provider.of<BookProvider>(context, listen: false).fetchBooks();
      Navigator.pop(context);
    }
    setState(() => _isLoading = false);
  }
}
