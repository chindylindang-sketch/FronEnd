import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';

/// Repository Auth — mengelola komunikasi API untuk autentikasi.
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Register user baru
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['access_token'] as String;
        await _apiClient.saveToken(token);
        final user = UserModel.fromJson(
          response.data['data']['user'] as Map<String, dynamic>,
        );
        return {'user': user, 'token': token};
      }
      throw Exception(response.data['message'] ?? 'Registrasi gagal');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['access_token'] as String;
        await _apiClient.saveToken(token);
        final user = UserModel.fromJson(
          response.data['data']['user'] as Map<String, dynamic>,
        );
        return {'user': user, 'token': token};
      }
      throw Exception(response.data['message'] ?? 'Login gagal');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logout);
    } catch (_) {
      // Tetap hapus token lokal meski API error
    } finally {
      await _apiClient.clearToken();
    }
  }

  /// Ambil profil user yang sedang login
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profile);

      if (response.data['success'] == true) {
        return UserModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception('Gagal mengambil profil');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Cek apakah user sudah login (ada token tersimpan)
  Future<bool> isLoggedIn() async {
    return await _apiClient.hasToken();
  }

  /// Handle Dio errors dengan pesan yang user-friendly
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        // Ambil pesan error dari response API
        if (data.containsKey('message')) {
          return Exception(data['message']);
        }
        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return Exception(firstError.first.toString());
          }
        }
      }
      return Exception('Server error: ${e.response!.statusCode}');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
    return Exception('Terjadi kesalahan jaringan');
  }
}
