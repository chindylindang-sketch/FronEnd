import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../models/order_model.dart';
import '../services/api_client.dart';

/// Repository Order — mengelola komunikasi API untuk CRUD pesanan.
class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Ambil semua pesanan (dengan filter opsional)
  Future<List<OrderModel>> getOrders({
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.dio.get(
        ApiConstants.orders,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal memuat pesanan');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Ambil detail pesanan berdasarkan ID
  Future<OrderModel> getOrder(int id) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.orders}/$id');

      if (response.data['success'] == true) {
        return OrderModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal memuat detail pesanan');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Buat pesanan baru
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.orders,
        data: order.toJson(),
      );

      if (response.data['success'] == true) {
        return OrderModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal membuat pesanan');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update pesanan
  Future<OrderModel> updateOrder(int id, OrderModel order) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.orders}/$id',
        data: order.toJson(),
      );

      if (response.data['success'] == true) {
        return OrderModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal memperbarui pesanan');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update status pesanan
  Future<OrderModel> updateStatus(int id, String status) async {
    try {
      final response = await _apiClient.dio.patch(
        '${ApiConstants.orders}/$id/status',
        data: {'status': status},
      );

      if (response.data['success'] == true) {
        return OrderModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['message'] ?? 'Gagal mengubah status');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Hapus pesanan
  Future<void> deleteOrder(int id) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.orders}/$id',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal menghapus pesanan');
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
