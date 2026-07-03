import 'package:flutter/material.dart';

/// Palet warna aplikasi LaundriGo.
/// Menggunakan nuansa teal/cyan sebagai warna utama dengan aksen oranye.
class AppColors {
  // Primary — Teal/Cyan
  static const Color primary = Color(0xFF0097A7);
  static const Color primaryLight = Color(0xFF4DD0E1);
  static const Color primaryDark = Color(0xFF00796B);

  // Secondary — Warm Orange (untuk tombol CTA & aksen)
  static const Color secondary = Color(0xFFFF8F00);
  static const Color secondaryLight = Color(0xFFFFB74D);

  // Background & Surface
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);

  // Text
  static const Color textPrimary = Color(0xFF1A2138);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Status badge colors
  static const Color statusDiterima = Color(0xFF2196F3); // Biru
  static const Color statusDiproses = Color(0xFFFFC107); // Kuning/Amber
  static const Color statusSelesai = Color(0xFF4CAF50); // Hijau
  static const Color statusDiambil = Color(0xFF9E9E9E); // Abu-abu

  // Utility
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color divider = Color(0xFFE5E7EB);

  /// Mendapatkan warna berdasarkan status pesanan
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return statusDiterima;
      case 'diproses':
        return statusDiproses;
      case 'selesai':
        return statusSelesai;
      case 'diambil':
        return statusDiambil;
      default:
        return textSecondary;
    }
  }

  /// Mendapatkan warna background badge berdasarkan status
  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return statusDiterima.withValues(alpha: 0.12);
      case 'diproses':
        return statusDiproses.withValues(alpha: 0.12);
      case 'selesai':
        return statusSelesai.withValues(alpha: 0.12);
      case 'diambil':
        return statusDiambil.withValues(alpha: 0.12);
      default:
        return textSecondary.withValues(alpha: 0.12);
    }
  }
}
