/// Konstanta API untuk koneksi ke Laravel backend.
/// Ganti [baseUrl] sesuai dengan environment yang digunakan.
class ApiConstants {
  // Untuk Windows Desktop atau Browser, gunakan 127.0.0.1
  // Untuk device fisik, gunakan IP komputer di jaringan lokal
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';

  // Service endpoints
  static const String services = '/services';

  // Order endpoints
  static const String orders = '/orders';

  // Dashboard endpoints
  static const String dashboardStats = '/dashboard/stats';
}
