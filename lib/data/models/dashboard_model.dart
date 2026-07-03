/// Model Dashboard — merepresentasikan data statistik untuk halaman dashboard.
class DashboardModel {
  final int totalPesanan;
  final double totalPendapatan;
  final int pesananHariIni;
  final Map<String, int> pesananPerStatus;

  DashboardModel({
    required this.totalPesanan,
    required this.totalPendapatan,
    required this.pesananHariIni,
    required this.pesananPerStatus,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalPesanan: json['total_pesanan'] as int? ?? 0,
      totalPendapatan: double.parse(
        (json['total_pendapatan'] ?? 0).toString(),
      ),
      pesananHariIni: json['pesanan_hari_ini'] as int? ?? 0,
      pesananPerStatus: Map<String, int>.from(
        json['pesanan_per_status'] as Map? ?? {},
      ),
    );
  }

  /// Format total pendapatan ke Rupiah
  String get formattedPendapatan {
    return 'Rp ${totalPendapatan.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Mendapatkan jumlah pesanan belum selesai
  int get pesananBelumSelesai {
    return (pesananPerStatus['diterima'] ?? 0) +
        (pesananPerStatus['diproses'] ?? 0);
  }
}
