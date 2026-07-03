import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../models/service_model.dart';
import '../services/api_client.dart';

/// Repository Service — mengelola komunikasi API untuk CRUD layanan laundry.
class ServiceRepository {
  final ApiClient _apiClient;

  ServiceRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Ambil semua layanan
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.services);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal memuat layanan');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Ambil detail layanan berdasarkan ID
  Future<ServiceModel> getService(int id) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.services}/$id');

      if (response.data['success'] == true) {
        return ServiceModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal memuat detail layanan');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Tambah layanan baru
  Future<ServiceModel> createService(ServiceModel service) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.services,
        data: service.toJson(),
      );

      if (response.data['success'] == true) {
        return ServiceModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal menambah layanan');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update layanan
  Future<ServiceModel> updateService(int id, ServiceModel service) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.services}/$id',
        data: service.toJson(),
      );

      if (response.data['success'] == true) {
        return ServiceModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal memperbarui layanan');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Hapus layanan
  Future<void> deleteService(int id) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.services}/$id',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal menghapus layanan');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return Exception(data['message']);
      }
      return Exception('Server error: ${e.response!.statusCode}');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Exception('Tidak dapat terhubung ke server.');
    }
    return Exception('Terjadi kesalahan jaringan');
  }
}
