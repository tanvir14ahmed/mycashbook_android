import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/book_model.dart';
import '../models/transaction_model.dart';

class BookProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<BookModel> _books = [];
  bool _isLoading = false;

  List<BookModel> get books => _books;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchBooks() async {
    _setLoading(true);
    try {
      final response = await _apiClient.get(ApiEndpoints.books);
      _books = (response.data as List).map((e) => BookModel.fromJson(e)).toList();
    } catch (e) {
      _books = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBook(String name, String description) async {
    try {
      await _apiClient.post(
        ApiEndpoints.books,
        data: {'name': name, 'description': description},
      );
      await fetchBooks();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBook(int id) async {
    try {
      await _apiClient.delete("${ApiEndpoints.books}$id/");
      await fetchBooks();
      return true;
    } catch (e) {
      return false;
    }
  }
}
