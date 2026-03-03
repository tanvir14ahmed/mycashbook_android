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
import 'package:intl/intl.dart';
import '../../widgets/pdf_download_overlay.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  late AnimationController _headerAnimController;
  late Animation<double> _headerScaleAnim;
  late Animation<double> _headerFadeAnim;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerScaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutCubic),
    );
    _headerFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );

    Future.microtask(() async {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactions(widget.bookId);
      _headerAnimController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final book = bookProvider.books.firstWhere((b) => b.id == widget.bookId);
    final isPositive = book.balance >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: book.name));
            Fluttertoast.showToast(msg: "Book name copied");
          },
          child: Text(book.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.orange))
                : const Icon(Icons.picture_as_pdf_outlined,
                    color: Colors.orange),
            onPressed: () async {
              setState(() => _isDownloading = true);
              final error =
                  await txProvider.downloadReport(widget.bookId, book.name);
              if (error != null && mounted) {
                setState(() => _isDownloading = false);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error)));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () =>
                _confirmDeleteBook(context, bookProvider, book.name),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ─── Unified Header Card ───
              AnimatedBuilder(
                animation: _headerAnimController,
                builder: (context, child) => FadeTransition(
                  opacity: _headerFadeAnim,
                  child: ScaleTransition(
                    scale: _headerScaleAnim,
                    child: child,
                  ),
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF9800).withOpacity(0.75),
                        const Color(0xFFE65100).withOpacity(0.85),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        // Subtle inner glow texture
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.07),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          left: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Row 1: Balance + BID ──
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Balance',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 13,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '৳${NumberFormat('#,##0.00').format(book.balance)}',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            color: isPositive
                                                ? Colors.white
                                                : Colors.red[100],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // BID Badge
                                  GestureDetector(
                                    onLongPress: () {
                                      Clipboard.setData(
                                          ClipboardData(text: book.bid));
                                      Fluttertoast.showToast(
                                          msg: "BID copied!");
                                    },
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: book.bid));
                                      Fluttertoast.showToast(
                                          msg: "BID copied!");
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.15)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'BOOK ID',
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontSize: 9,
                                                letterSpacing: 1.5),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '#${book.bid}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.copy,
                                                  size: 9,
                                                  color: Colors.white
                                                      .withOpacity(0.5)),
                                              const SizedBox(width: 2),
                                              Text('tap to copy',
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      fontSize: 8)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Transaction count
                              Text(
                                '${txProvider.transactions.length} transaction${txProvider.transactions.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ── Row 2: Action Buttons ──
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.add_rounded,
                                      label: 'Add Entry',
                                      onTap: () => showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => AddTransactionDialog(
                                            bookId: widget.bookId),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.send_rounded,
                                      label: 'Send Money',
                                      onTap: () => showDialog(
                                        context: context,
                                        barrierColor: Colors.black87,
                                        builder: (_) => SendMoneyModal(
                                            senderBookId: widget.bookId),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Transaction List Header ───
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (txProvider.isLoading)
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.orange)),
                  ],
                ),
              ),

              // ─── Transaction List ───
              Expanded(
                child: RefreshIndicator(
                  color: Colors.orange,
                  onRefresh: () async {
                    await Provider.of<BookProvider>(context, listen: false).fetchBooks();
                    await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions(widget.bookId);
                  },
                  child: txProvider.transactions.isEmpty && !txProvider.isLoading
                      ? LayoutBuilder(
                          builder: (context, constraints) => ListView(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            children: [
                              Container(
                                height: constraints.maxHeight,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long_outlined,
                                        color: Colors.white.withOpacity(0.1), size: 64),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No transactions yet',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap "Add Entry" to get started',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.2),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: txProvider.transactions.length,
                          itemBuilder: (context, index) {
                            return TransactionListItem(
                              bookId: widget.bookId,
                              transaction: txProvider.transactions[index],
                              onDelete: () => txProvider.deleteTransaction(
                                  widget.bookId,
                                  txProvider.transactions[index].id),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),

          // PDF Overlay
          if (_isDownloading)
            PDFDownloadOverlay(
              onComplete: () => setState(() => _isDownloading = false),
            ),
        ],
      ),
      floatingActionButton: _isDownloading
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTransactionDialog(bookId: widget.bookId),
              ),
              backgroundColor: const Color(0xFFFF9800),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Entry',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
    );
  }

  Future<void> _confirmDeleteBook(
      BuildContext context, BookProvider provider, String bookName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete "$bookName"?',
            style: const TextStyle(color: Colors.white)),
        content: const Text(
          'This cannot be undone. All transactions in this book will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('DELETE',
                style: TextStyle(color: Colors.white)),
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

/// Compact glass action button used inside the header card
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
