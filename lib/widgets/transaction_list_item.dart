import 'transaction_detail_sheet.dart';
import 'glass_container.dart';

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
    final date = DateTime.parse(transaction.createdAt);
    
    return Dismissible(
      key: Key('txn_${transaction.id}'),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => EditTransactionDialog(bookId: bookId, transaction: transaction),
          );
          return false; // Don't dismiss
        } else {
          // Delete
          final confirm = await _confirmDelete(context);
          if (confirm == true) {
            onDelete();
            return true;
          }
          return false;
        }
      },
      background: _buildSwipeBackground(
        Alignment.centerLeft,
        Colors.blue,
        Icons.edit_outlined,
        'EDIT',
      ),
      secondaryBackground: _buildSwipeBackground(
        Alignment.centerRight,
        Colors.red,
        Icons.delete_outline,
        'DELETE',
      ),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TransactionDetailSheet(transaction: transaction),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(0),
            opacity: 0.05,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: isDeposit ? Colors.green : Colors.red,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isDeposit ? Colors.green : Colors.red).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDeposit ? Icons.add : Icons.remove,
                              color: isDeposit ? Colors.green : Colors.red,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  transaction.note.isEmpty ? (isDeposit ? 'Deposit' : 'Withdrawal') : transaction.note,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM, yyyy').format(date),
                                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isDeposit ? '+' : '-'}৳${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDeposit ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(Alignment alignment, Color color, IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ] else ...[
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(width: 8),
            Icon(icon, color: color, size: 20),
          ],
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Entry?', style: TextStyle(color: Colors.white)),
        content: const Text('This will permanently remove this transaction from the records.', style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
            child: const Text('DELETE', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }
}
