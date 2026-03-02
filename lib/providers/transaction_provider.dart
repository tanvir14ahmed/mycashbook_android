import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchTransactions(int bookId) async {
    _setLoading(true);
    try {
      final response = await _apiClient.get(ApiEndpoints.transactions(bookId));
      _transactions = (response.data as List).map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      _transactions = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTransaction({
    required int bookId,
    required double amount,
    required String type,
    required String note,
    required String createdAt,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.transactions(bookId),
        data: {
          'amount': amount,
          'type': type,
          'note': note,
          'created_at': createdAt,
        },
      );
      await fetchTransactions(bookId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTransaction(int bookId, int transactionId) async {
    try {
      await _apiClient.delete(ApiEndpoints.deleteTransaction(transactionId));
      await fetchTransactions(bookId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> validateBid(String bid) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.validateBid,
        queryParameters: {'bid': bid},
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<bool> transferFunds({
    required int senderBookId,
    required String recipientBid,
    required double amount,
    required String note,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.transfer,
        data: {
          'sender_book_id': senderBookId,
          'recipient_bid': recipientBid,
          'amount': amount,
          'note': note,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
