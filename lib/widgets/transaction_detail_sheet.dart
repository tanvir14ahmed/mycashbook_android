import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'glass_container.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == 'deposit';
    final date = DateTime.parse(transaction.createdAt);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: GlassContainer(
        opacity: 0.1,
        borderRadius: 32,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Icon & Type
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isDeposit ? Colors.green : Colors.red).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isDeposit ? Colors.green : Colors.red).withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isDeposit ? Colors.green : Colors.red,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isDeposit ? 'Deposit Received' : 'Withdrawal Made',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '৳${NumberFormat('#,##0.00').format(transaction.amount)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            // Detail List
            _buildDetailRow('Date', DateFormat('dd MMMM, yyyy').format(date)),
            const Divider(color: Colors.white10, height: 32),
            _buildDetailRow('Transaction ID', '#TXN${transaction.id.toString().padLeft(6, '0')}'),
            const Divider(color: Colors.white10, height: 32),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  transaction.note.isEmpty ? 'No note provided' : transaction.note,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Close Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
