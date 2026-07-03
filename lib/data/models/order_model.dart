import 'service_model.dart';

/// Model Order (Pesanan) — merepresentasikan data transaksi pelanggan.
class OrderModel {
  final int? id;
  final int? userId;
  final int layananId;
  final String namaPelanggan;
  final String noHp;
  final double? beratKg;
  final int? jumlah;
  final double totalHarga;
  final String status;
  final DateTime tanggalMasuk;
  final DateTime? estimasiSelesai;
  final String? catatan;
  final ServiceModel? layanan; // Relasi ke Service
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    this.id,
    this.userId,
    required this.layananId,
    required this.namaPelanggan,
    required this.noHp,
    this.beratKg,
    this.jumlah,
    required this.totalHarga,
    required this.status,
    required this.tanggalMasuk,
    this.estimasiSelesai,
    this.catatan,
    this.layanan,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk parsing JSON dari API
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      layananId: json['layanan_id'] as int,
      namaPelanggan: json['nama_pelanggan'] as String,
      noHp: json['no_hp'] as String,
      beratKg: json['berat_kg'] != null
          ? double.parse(json['berat_kg'].toString())
          : null,
      jumlah: json['jumlah'] as int?,
      totalHarga: double.parse(json['total_harga'].toString()),
      status: json['status'] as String,
      tanggalMasuk: DateTime.parse(json['tanggal_masuk'] as String),
      estimasiSelesai: json['estimasi_selesai'] != null
          ? DateTime.parse(json['estimasi_selesai'] as String)
          : null,
      catatan: json['catatan'] as String?,
      layanan: json['layanan'] != null
          ? ServiceModel.fromJson(json['layanan'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Konversi ke JSON untuk kirim ke API
  Map<String, dynamic> toJson() {
    return {
      'layanan_id': layananId,
      'nama_pelanggan': namaPelanggan,
      'no_hp': noHp,
      if (beratKg != null) 'berat_kg': beratKg,
      if (jumlah != null) 'jumlah': jumlah,
      'tanggal_masuk': tanggalMasuk.toIso8601String().split('T')[0],
      if (estimasiSelesai != null)
        'estimasi_selesai': estimasiSelesai!.toIso8601String().split('T')[0],
      if (catatan != null && catatan!.isNotEmpty) 'catatan': catatan,
    };
  }

  /// Format total harga
  String get formattedTotal {
    return 'Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Format tanggal masuk
  String get formattedDate {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${tanggalMasuk.day} ${months[tanggalMasuk.month]} ${tanggalMasuk.year}';
  }

  /// Format estimasi selesai
  String get formattedEstimasi {
    if (estimasiSelesai == null) return '-';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${estimasiSelesai!.day} ${months[estimasiSelesai!.month]} ${estimasiSelesai!.year}';
  }

  /// Mendapatkan display quantity
  String get displayQuantity {
    if (beratKg != null) return '${beratKg!.toStringAsFixed(1)} kg';
    if (jumlah != null) return '$jumlah pcs';
    return '-';
  }

  OrderModel copyWith({
    int? id,
    int? userId,
    int? layananId,
    String? namaPelanggan,
    String? noHp,
    double? beratKg,
    int? jumlah,
    double? totalHarga,
    String? status,
    DateTime? tanggalMasuk,
    DateTime? estimasiSelesai,
    String? catatan,
    ServiceModel? layanan,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      layananId: layananId ?? this.layananId,
      namaPelanggan: namaPelanggan ?? this.namaPelanggan,
      noHp: noHp ?? this.noHp,
      beratKg: beratKg ?? this.beratKg,
      jumlah: jumlah ?? this.jumlah,
      totalHarga: totalHarga ?? this.totalHarga,
      status: status ?? this.status,
      tanggalMasuk: tanggalMasuk ?? this.tanggalMasuk,
      estimasiSelesai: estimasiSelesai ?? this.estimasiSelesai,
      catatan: catatan ?? this.catatan,
      layanan: layanan ?? this.layanan,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Status pesanan yang tersedia
class OrderStatuses {
  static const String diterima = 'diterima';
  static const String diproses = 'diproses';
  static const String selesai = 'selesai';
  static const String diambil = 'diambil';

  static const List<String> all = [diterima, diproses, selesai, diambil];

  static String getLabel(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return 'Diterima';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'diambil':
        return 'Diambil';
      default:
        return status;
    }
  }
}
