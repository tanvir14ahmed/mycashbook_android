import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  UserModel? _user;
  String? _profilePhotoPath;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get profilePhotoPath => _profilePhotoPath;
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
      return null; 
    } on DioException catch (e) {
      if (e.response != null) {
        // Detailed error from server (e.g., "No active account found")
        final detail = e.response?.data['detail'];
        if (detail != null) return detail.toString();
        
        final errors = e.response?.data;
        if (errors is Map) {
           return errors.values.firstWhere((e) => true, orElse: () => "Invalid credentials").toString();
        }
        return "Invalid credentials";
      }
      return "Connection error: ${e.message}";
    } catch (e) {
      return "An unexpected error occurred.";
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> forgotPassword(String email) async {
    _setLoading(true);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      return null;
    } on DioException catch (e) {
      return e.response?.data['error'] ?? e.response?.data['message'] ?? "Failed to send OTP";
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        },
      );
      return null;
    } on DioException catch (e) {
      return e.response?.data['error'] ?? e.response?.data['message'] ?? "Failed to reset password";
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> register({
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
          'email': email,
          'password': password,
          'display_name': displayName,
          'timezone': timezone,
        },
      );
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        // Collect all error messages from the backend
        return data.values.map((v) => v is List ? v.first : v).join("\n");
      }
      return "Connection error: ${e.message}";
    } catch (e) {
      return "An unexpected error occurred.";
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
      // Load local profile photo path
      _profilePhotoPath = await _apiClient.storage.read(key: 'profile_photo_${_user!.id}');
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> updateProfilePhoto(String path) async {
    if (_user == null) return;
    _profilePhotoPath = path;
    await _apiClient.storage.write(key: 'profile_photo_${_user!.id}', value: path);
    notifyListeners();
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
