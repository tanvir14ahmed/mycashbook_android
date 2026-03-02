import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    _setLoading(true);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );
      
      final access = response.data['access'];
      final refresh = response.data['refresh'];
      
      await _apiClient.storage.write(key: 'access_token', value: access);
      await _apiClient.storage.write(key: 'refresh_token', value: refresh);
      
      await getProfile();
      return null; // Null means success
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data['detail'] ?? "Invalid credentials";
      }
      return "Connection error. Please check your internet.";
    } catch (e) {
      return "An unexpected error occurred.";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
    required String timezone,
  }) async {
    _setLoading(true);
    try {
      await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'display_name': displayName,
          'timezone': timezone,
        },
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      
      final access = response.data['access'];
      final refresh = response.data['refresh'];
      
      await _apiClient.storage.write(key: 'access_token', value: access);
      await _apiClient.storage.write(key: 'refresh_token', value: refresh);
      
      _user = UserModel.fromJson(response.data['user']);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      _user = UserModel.fromJson(response.data);
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await _apiClient.storage.deleteAll();
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _apiClient.storage.read(key: 'access_token');
    if (token == null) return false;
    await getProfile();
    return isAuthenticated;
  }
}
