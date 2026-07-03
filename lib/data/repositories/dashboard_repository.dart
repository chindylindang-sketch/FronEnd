import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../models/dashboard_model.dart';
import '../services/api_client.dart';

/// Repository Dashboard — mengambil data statistik untuk halaman dashboard.
class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Ambil statistik dashboard
  Future<DashboardModel> getStats() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.dashboardStats);

      if (response.data['success'] == true) {
        return DashboardModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal memuat statistik');
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
