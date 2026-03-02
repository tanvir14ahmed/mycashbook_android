import 'package:flutter/material.dart';
import '../models/book_model.dart';

class BookCard extends StatefulWidget {
  final BookModel book;
  final VoidCallback onTap;

  const BookCard({super.key, required this.book, required this.onTap});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Circle Avatar for Initial
              CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: Text(
                  widget.book.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              
              // Book Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.book.transactionsCount} transactions',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              
              // Balance and Glowing BID
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${widget.book.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.book.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Glowing BID Badge
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5 * _controller.value),
                              blurRadius: 10 * _controller.value,
                              spreadRadius: 2 * _controller.value,
                            ),
                          ],
                        ),
                        child: Text(
                          'BID:${widget.book.bid}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
