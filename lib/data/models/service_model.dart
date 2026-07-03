/// Model Service (Layanan) — merepresentasikan data layanan laundry.
class ServiceModel {
  final int? id;
  final String namaLayanan;
  final String kategori;
  final double? hargaPerKg;
  final double? hargaSatuan;
  final String estimasiWaktu;
  final String? deskripsi;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    this.id,
    required this.namaLayanan,
    required this.kategori,
    this.hargaPerKg,
    this.hargaSatuan,
    required this.estimasiWaktu,
    this.deskripsi,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk parsing JSON dari API
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int?,
      namaLayanan: json['nama_layanan'] as String,
      kategori: json['kategori'] as String,
      hargaPerKg: json['harga_per_kg'] != null
          ? double.parse(json['harga_per_kg'].toString())
          : null,
      hargaSatuan: json['harga_satuan'] != null
          ? double.parse(json['harga_satuan'].toString())
          : null,
      estimasiWaktu: json['estimasi_waktu'] as String,
      deskripsi: json['deskripsi'] as String?,
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
      'nama_layanan': namaLayanan,
      'kategori': kategori,
      if (hargaPerKg != null) 'harga_per_kg': hargaPerKg,
      if (hargaSatuan != null) 'harga_satuan': hargaSatuan,
      'estimasi_waktu': estimasiWaktu,
      if (deskripsi != null) 'deskripsi': deskripsi,
    };
  }

  /// Mendapatkan harga tampilan
  String get displayPrice {
    if (hargaPerKg != null) {
      return 'Rp ${_formatNumber(hargaPerKg!)}/kg';
    } else if (hargaSatuan != null) {
      return 'Rp ${_formatNumber(hargaSatuan!)}/pcs';
    }
    return '-';
  }

  /// Mendapatkan nilai harga (untuk kalkulasi)
  double get effectivePrice => hargaPerKg ?? hargaSatuan ?? 0;

  /// Cek apakah menggunakan harga per kg
  bool get isPerKg => hargaPerKg != null;

  /// Format angka dengan pemisah ribuan
  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Mendapatkan icon berdasarkan kategori
  String get categoryIcon {
    switch (kategori.toLowerCase()) {
      case 'cuci_kering':
        return '🧺';
      case 'cuci_setrika':
        return '👔';
      case 'cuci_sepatu':
        return '👟';
      case 'cuci_reguler':
        return '🫧';
      case 'setrika_saja':
        return '🔥';
      case 'cuci_express':
        return '⚡';
      default:
        return '🧹';
    }
  }

  /// Mendapatkan label kategori yang readable
  String get categoryLabel {
    switch (kategori.toLowerCase()) {
      case 'cuci_kering':
        return 'Cuci Kering';
      case 'cuci_setrika':
        return 'Cuci & Setrika';
      case 'cuci_sepatu':
        return 'Cuci Sepatu';
      case 'cuci_reguler':
        return 'Cuci Reguler';
      case 'setrika_saja':
        return 'Setrika Saja';
      case 'cuci_express':
        return 'Cuci Express';
      default:
        return kategori;
    }
  }

  ServiceModel copyWith({
    int? id,
    String? namaLayanan,
    String? kategori,
    double? hargaPerKg,
    double? hargaSatuan,
    String? estimasiWaktu,
    String? deskripsi,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      namaLayanan: namaLayanan ?? this.namaLayanan,
      kategori: kategori ?? this.kategori,
      hargaPerKg: hargaPerKg ?? this.hargaPerKg,
      hargaSatuan: hargaSatuan ?? this.hargaSatuan,
      estimasiWaktu: estimasiWaktu ?? this.estimasiWaktu,
      deskripsi: deskripsi ?? this.deskripsi,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Daftar kategori yang tersedia
class ServiceCategories {
  static const List<Map<String, String>> categories = [
    {'value': 'cuci_reguler', 'label': 'Cuci Reguler', 'icon': '🫧'},
    {'value': 'cuci_kering', 'label': 'Cuci Kering', 'icon': '🧺'},
    {'value': 'cuci_setrika', 'label': 'Cuci & Setrika', 'icon': '👔'},
    {'value': 'cuci_sepatu', 'label': 'Cuci Sepatu', 'icon': '👟'},
    {'value': 'setrika_saja', 'label': 'Setrika Saja', 'icon': '🔥'},
    {'value': 'cuci_express', 'label': 'Cuci Express', 'icon': '⚡'},
  ];
}
