import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/book_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'glass_container.dart';

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

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  late AnimationController _transferAnimController;
  late Animation<double> _bouncingAnimation;

  @override
  void initState() {
    super.initState();
    // Dialog entry animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

    // Transfer loading animation
    _transferAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _bouncingAnimation = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(parent: _transferAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _transferAnimController.dispose();
    _bidController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final bid = _bidController.text.trim();
    if (bid.length != 6) {
      _showError('Please enter a 6-digit BID');
      return;
    }

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
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }
    if (_validatedBid == null) return;

    setState(() => _isTransferring = true);
    
    // Play animation for at least 1.5 seconds minimum for visual feedback
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: child,
            ),
          );
        },
        child: _isTransferring 
          ? _buildTransferAnimation() 
          : _showSuccess 
            ? _buildSuccessOverlay() 
            : _buildTransferForm(),
      ),
    );
  }

  Widget _buildTransferForm() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Send Money',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 24),
            
            // BID Input
            if (_validatedBid == null) ...[
              Text('Recipient Book ID', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _bidController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
                decoration: InputDecoration(
                  hintText: '######',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 2),
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  suffixIcon: IconButton(
                    icon: _isValidating 
                      ? const SpinKitRing(color: Colors.orange, size: 20, lineWidth: 2)
                      : const Icon(Icons.search, color: Colors.orange),
                    onPressed: _handleVerify,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.orange.withOpacity(0.5), width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValidating ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('VERIFY BID', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ] else ...[
              // Recipient Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.2), 
                      child: Text(
                        _recipientName![0].toUpperCase(),
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_recipientName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(
                            '$_recipientBookName (#$_validatedBid)', 
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.orange),
                      onPressed: () => setState(() => _validatedBid = null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Amount Input
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.15)),
                  prefixText: '৳ ',
                  prefixStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
                  border: InputBorder.none,
                ),
              ),
              Divider(color: Colors.orange.withOpacity(0.2)),
              const SizedBox(height: 16),
              
              // Note
              TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What\'s this for?',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: const Icon(Icons.notes, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Confirm Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _handleTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'SEND MONEY',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransferAnimation() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Rotating Halo
              AnimatedBuilder(
                animation: _transferAnimController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _transferAnimController.value * 2 * 3.14,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 3),
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
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.orangeAccent, blurRadius: 10, spreadRadius: 2)
                        ]
                      ),
                      child: const Text('৳', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'Transferring...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
          ),
          const SizedBox(height: 8),
          Text(
            'Securing transaction',
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
          ),
          const SizedBox(height: 24),
          const Text(
            'Transfer Successful!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent),
          ),
          const SizedBox(height: 8),
          Text(
            'Money has been sent to $_recipientName',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
