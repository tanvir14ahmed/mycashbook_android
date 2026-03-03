import 'package:flutter/material.dart';
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
        Navigator.of(context).pop(); // Actually pop if within 2s
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MyCashBook', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.orange),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text('Your Books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // Books Grid
                Expanded(
                  child: bookProvider.isLoading
                      ? _buildShimmerLoading()
                      : filteredBooks.isEmpty
                          ? const Center(child: Text('No books found.'))
                          : GridView.builder(
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
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(context: context, builder: (_) => const AddBookDialog()),
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
