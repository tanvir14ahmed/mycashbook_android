import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/book_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SendMoneyModal extends StatefulWidget {
  final int senderBookId;
  const SendMoneyModal({super.key, required this.senderBookId});

  @override
  State<SendMoneyModal> createState() => _SendMoneyModalState();
}

class _SendMoneyModalState extends State<SendMoneyModal> with TickerProviderStateMixin {
  final _bidController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isValidating = false;
  bool _isTransferring = false;
  bool _showSuccess = false;
  
  String? _recipientName;
  String? _recipientBookName;
  String? _validatedBid;

  late AnimationController _animationController;
  late Animation<double> _bouncingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _bouncingAnimation = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bidController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final bid = _bidController.text.trim();
    if (bid.length != 6) return;

    setState(() => _isValidating = true);
    final result = await Provider.of<TransactionProvider>(context, listen: false).validateBid(bid);
    
    if (mounted) {
      setState(() {
        _isValidating = false;
        if (result != null && result['success'] == true) {
          _recipientName = result['owner_name'];
          _recipientBookName = result['book_name'];
          _validatedBid = bid;
        } else {
          _recipientName = null;
          _showError('Invalid BID. Recipient not found.');
        }
      });
    }
  }

  Future<void> _handleTransfer() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _validatedBid == null) return;

    setState(() => _isTransferring = true);
    
    // Play animation for at least 1 second as requested
    await Future.delayed(const Duration(milliseconds: 1500));

    final success = await Provider.of<TransactionProvider>(context, listen: false).transferFunds(
      senderBookId: widget.senderBookId,
      recipientBid: _validatedBid!,
      amount: amount,
      note: _noteController.text.trim(),
    );

    if (mounted) {
      if (success) {
        await Provider.of<BookProvider>(context, listen: false).fetchBooks();
        await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions(widget.senderBookId);
        setState(() {
          _isTransferring = false;
          _showSuccess = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => _isTransferring = false);
        _showError('Transfer failed. Check your balance.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Send Money',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // BID Input
                if (_validatedBid == null) ...[
                  TextField(
                    controller: _bidController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Enter Recipient BID',
                      hintText: '6-digit code',
                      suffixIcon: IconButton(
                        icon: _isValidating 
                          ? const SpinKitRing(color: Colors.orange, size: 20)
                          : const Icon(Icons.check_circle_outline, color: Colors.orange),
                        onPressed: _handleVerify,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ] else ...[
                  // Recipient Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_recipientName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Book: $_recipientBookName (BID: $_validatedBid)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => setState(() => _validatedBid = null)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Amount and Note
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (৳)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: _handleTransfer,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: const Text('CONFIRM TRANSFER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
          
          // Transferring Animation Overlay
          if (_isTransferring) _buildTransferAnimation(),
          
          // Success Overlay
          if (_showSuccess) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildTransferAnimation() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Rotating Halo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * 2 * 3.14,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange.withOpacity(0.3), width: 4),
                        ),
                      ),
                    );
                  },
                ),
                // Bouncing Coin
                AnimatedBuilder(
                  animation: _bouncingAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bouncingAnimation.value),
                      child: const Icon(Icons.monetization_on, color: Colors.orange, size: 60),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Transferring Money...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.white,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              'Transfer Successful!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
