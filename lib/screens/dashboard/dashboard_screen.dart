import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../book/book_detail_screen.dart';
import '../../widgets/book_card.dart';
import '../../widgets/add_book_dialog.dart';
import '../auth/profile_screen.dart';
import '../auth/login_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/liquid_transition.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = "";
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<BookProvider>(context, listen: false).fetchBooks());
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final filteredBooks = bookProvider.books.where((book) {
      return book.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          Fluttertoast.showToast(
            msg: "Press again to exit",
            backgroundColor: Colors.black87,
            textColor: Colors.white,
          );
          return;
        }
        SystemNavigator.pop(); // Cleanly exit the app
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MyCashBook', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  backgroundImage: authProvider.profilePhotoPath != null 
                    ? FileImage(File(authProvider.profilePhotoPath!)) 
                    : null,
                  child: authProvider.profilePhotoPath == null 
                    ? const Icon(Icons.person_outline, color: Colors.orange, size: 22)
                    : null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authProvider.logout();
                Fluttertoast.showToast(
                  msg: "Successfully Logged Out",
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                );
                Navigator.pushAndRemoveUntil(
                  context, 
                  SoothingPageTransition(page: const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => bookProvider.fetchBooks(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.orange.withOpacity(0.3), width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text('Your Books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // Books Grid
                Expanded(
                  child: RepaintBoundary(
                    child: bookProvider.isLoading
                        ? _buildShimmerLoading()
                        : filteredBooks.isEmpty
                            ? const Center(child: Text('No books found.'))
                            : GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.9,
                                ),
                                itemCount: filteredBooks.length,
                                itemBuilder: (context, index) {
                                  final book = filteredBooks[index];
                                  return BookCard(
                                    book: book,
                                    onTap: () => Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id))
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(context: context, builder: (_) => const AddBookDialog());
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
