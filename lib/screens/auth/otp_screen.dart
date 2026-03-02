import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(
      widget.email,
      _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or expired OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.mark_email_unread_outlined, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'We have sent a 6-digit code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 10),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.length != 6 ? 'Enter 6-digit code' : null,
              ),
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _handleVerify,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authProvider.isLoading
                    ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                    : const Text('VERIFY & CONTINUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () {
                  // Resend OTP TODO
                },
                child: const Text('Resend Code?', style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
