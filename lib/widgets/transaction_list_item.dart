import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionListItem({super.key, required this.transaction, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == 'deposit';
    
    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Entry?'),
            content: const Text('This will permanently remove this transaction.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDeposit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          child: Icon(
            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isDeposit ? Colors.green : Colors.red,
            size: 18,
          ),
        ),
        title: Text(
          transaction.note.isEmpty ? (isDeposit ? 'Income' : 'Expense') : transaction.note,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          DateFormat('dd MMM, yyyy').format(DateTime.parse(transaction.createdAt)),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          '${isDeposit ? '+' : '-'}৳${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDeposit ? Colors.green : Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
