import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/add_transaction_dialog.dart';
import '../../widgets/send_money_modal.dart';
import '../../widgets/transaction_list_item.dart';
import '../../widgets/glass_container.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/pdf_download_overlay.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isDownloading = false;

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
        title: GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: book.name));
            Fluttertoast.showToast(msg: "Copied Name");
          },
          child: Text(book.name),
        ),
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                : const Icon(Icons.picture_as_pdf, color: Colors.orange),
            onPressed: () async {
              setState(() => _isDownloading = true);
              final error = await txProvider.downloadReport(widget.bookId, book.name);
              if (error != null && mounted) {
                setState(() => _isDownloading = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.blueGrey),
            onPressed: () => _confirmDeleteBook(context, bookProvider, book.name),
          ),
        ],
      ),
      floatingActionButton: _isDownloading
          ? null
          : FloatingActionButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTransactionDialog(bookId: widget.bookId),
              ),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: Stack(
        children: [
          // Main scrollable content
          Column(
            children: [
              // Balance Card with orange gradient
              Container(
                margin: const EdgeInsets.all(16),
                child: GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(20),
                  opacity: 0.65,
                  gradientColors: const [
                    Color(0xFFFF9800),
                    Color(0xFFFF5722),
                  ],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Balance',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(
                            '৳${book.balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: book.bid));
                          Fluttertoast.showToast(msg: "BID Copied");
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Text(
                            'BID: ${book.bid}',
                            style: const TextStyle(
                                color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFF5722)]),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddTransactionDialog(bookId: widget.bookId),
                          ),
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          label: const Text('Add Entry',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                          builder: (_) => SendMoneyModal(senderBookId: widget.bookId),
                        ),
                        icon: const Icon(Icons.send, color: Colors.orange),
                        label: const Text('Send Money',
                            style: TextStyle(color: Colors.orange)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Transaction History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Icon(Icons.history, color: Colors.grey, size: 20),
                  ],
                ),
              ),

              // Transaction List
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
                                onDelete: () => txProvider.deleteTransaction(
                                    widget.bookId, txProvider.transactions[index].id),
                              );
                            },
                          ),
              ),
            ],
          ),

          // PDF Download Overlay
          if (_isDownloading)
            PDFDownloadOverlay(
              onComplete: () => setState(() => _isDownloading = false),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteBook(
      BuildContext context, BookProvider provider, String bookName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete "$bookName"?',
            style: const TextStyle(color: Colors.white)),
        content: const Text(
          'This action cannot be undone. All transactions associated with this book will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.deleteBook(widget.bookId);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }
}
