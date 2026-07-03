import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';

/// ApiClient — konfigurasi Dio dengan JWT interceptor.
///
/// Interceptor otomatis menyisipkan token Authorization di setiap request,
/// dan menangani refresh token / logout saat token kedaluwarsa (401).
class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  // Callback untuk logout otomatis saat token benar-benar expired
  Function? onForceLogout;

  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor untuk JWT token & error handling
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  /// Menyisipkan JWT token ke header setiap request
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Menangani error response, terutama 401 (Unauthorized)
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Coba refresh token
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry request asli dengan token baru
        final token = await _storage.read(key: 'access_token');
        err.requestOptions.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Token benar-benar expired, paksa logout
        await _storage.deleteAll();
        onForceLogout?.call();
      }
    }
    handler.next(err);
  }

  /// Mencoba refresh token JWT
  Future<bool> _tryRefreshToken() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return false;

      // Gunakan Dio baru tanpa interceptor untuk menghindari loop
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final response = await refreshDio.post(ApiConstants.refresh);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newToken = response.data['data']['access_token'] as String;
        await _storage.write(key: 'access_token', value: newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Menyimpan token setelah login/register
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  /// Menghapus token saat logout
  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }

  /// Cek apakah ada token tersimpan
  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  /// Mendapatkan token yang tersimpan
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }
}
