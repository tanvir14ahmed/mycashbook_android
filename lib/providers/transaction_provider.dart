import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/transaction_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';

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

  Future<bool> updateTransaction({
    required int bookId,
    required int transactionId,
    required double amount,
    required String type,
    required String note,
  }) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.deleteTransaction(transactionId),
        data: {
          'amount': amount,
          'type': type,
          'note': note,
        },
      );
      await fetchTransactions(bookId);
      return true;
    } catch (e) {
      debugPrint('updateTransaction error: $e');
      return false;
    }
  }

  Future<String?> downloadReport(int bookId, String bookName) async {
    _setLoading(true);
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        if (!(await Permission.storage.request().isGranted) && 
            !(await Permission.manageExternalStorage.request().isGranted)) {
          // Note: On Android 13+, storage permission might be different, 
          // but for PDF downloading to downloads folder, path_provider usually suffice or we need specific permissions.
        }
      }

      final directory = await getExternalStorageDirectory();
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final path = downloadsDir.existsSync() 
          ? '${downloadsDir.path}/${bookName}_report.pdf'
          : '${directory!.path}/${bookName}_report.pdf';

      final response = await _apiClient.dio.download(
        '${ApiEndpoints.baseUrl}/books/$bookId/report/',
        path,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _apiClient.storage.read(key: 'access_token')}',
          },
        ),
      );

      if (response.statusCode == 200) {
        await OpenFilex.open(path);
        return null; // Success
      }
      return "Failed to download report";
    } catch (e) {
      return "Download error: $e";
    } finally {
      _setLoading(false);
    }
  }
}
