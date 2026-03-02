import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'edit_transaction_dialog.dart';

class TransactionListItem extends StatelessWidget {
  final int bookId;
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionListItem({
    super.key, 
    required this.bookId,
    required this.transaction, 
    required this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == 'deposit';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Indicator Bar
              Container(
                width: 6,
                color: isDeposit ? Colors.green : Colors.red,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isDeposit ? Colors.green : Colors.red).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDeposit ? Icons.add : Icons.remove,
                          color: isDeposit ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              transaction.note.isEmpty ? (isDeposit ? 'Deposit' : 'Withdrawal') : transaction.note,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM, yyyy').format(DateTime.parse(transaction.createdAt)),
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Amount & Actions
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${isDeposit ? '+' : '-'}৳${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDeposit ? Colors.green : Colors.red,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blueGrey),
                                onPressed: () => showDialog(
                                  context: context, 
                                  builder: (_) => EditTransactionDialog(bookId: bookId, transaction: transaction)
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.blueGrey),
                                onPressed: _confirmDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This will permanently remove this transaction.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              onDelete();
              Navigator.pop(ctx);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red), 
            child: const Text('Delete')
          ),
        ],
      ),
    );
  }
}
