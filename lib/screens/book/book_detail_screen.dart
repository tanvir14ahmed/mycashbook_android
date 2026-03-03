import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/add_transaction_dialog.dart';
import '../../widgets/send_money_modal.dart';
import '../../widgets/transaction_list_item.dart';
import 'package:intl/intl.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactions(widget.bookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    
    final book = bookProvider.books.firstWhere((b) => b.id == widget.bookId);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.name),
        actions: [
          IconButton(
            icon: txProvider.isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Icon(Icons.picture_as_pdf, color: Colors.orange),
            onPressed: () async {
              final error = await txProvider.downloadReport(widget.bookId, book.name);
              if (error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Book Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Balance', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '৳${book.balance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'BID: ${book.bid}',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddTransactionDialog(bookId: widget.bookId),
                      ),
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                      label: const Text('Add Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showModalBottomSheet(
                      context: context, 
                      isScrollControlled: true,
                      builder: (_) => SendMoneyModal(senderBookId: widget.bookId)
                    ),
                    icon: const Icon(Icons.send, color: Colors.orange),
                    label: const Text('Send Money', style: TextStyle(color: Colors.orange)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          
          // Transactions List Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(Icons.history, color: Colors.grey, size: 20),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: txProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : txProvider.transactions.isEmpty
                    ? const Center(child: Text('No transactions yet.'))
                    : ListView.builder(
                        itemCount: txProvider.transactions.length,
                        itemBuilder: (context, index) {
                          return TransactionListItem(
                            bookId: widget.bookId,
                            transaction: txProvider.transactions[index],
                            onDelete: () => txProvider.deleteTransaction(widget.bookId, txProvider.transactions[index].id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
