import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  late Dio dio;
  final storage = const FlutterSecureStorage();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, attempt refresh
          final refreshToken = await storage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              final response = await Dio().post(
                "${ApiEndpoints.baseUrl}${ApiEndpoints.refresh}",
                data: {'refresh': refreshToken},
              );
              final newToken = response.data['access'];
              await storage.write(key: 'access_token', value: newToken);
              
              // Retry the original request
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final retryResponse = await dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            } catch (refreshError) {
              // Refresh failed, logout
              await storage.deleteAll();
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
