import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../widgets/liquid_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();;
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        SoothingPageTransition(page: const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        SoothingPageTransition(page: const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E1E), Colors.black],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 5),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset('assets/icon/app_icon.png',
                        fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'MyCashBook',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                'PREMIUM EXPENSE TRACKING APP',
                style: TextStyle(
                    color: Colors.grey[500], fontSize: 11, letterSpacing: 3),
              ),
              const SizedBox(height: 60),
              const SpinKitCubeGrid(color: Colors.orange, size: 40),
            ],
          ),
        ),
      ),
    );
  }
}
