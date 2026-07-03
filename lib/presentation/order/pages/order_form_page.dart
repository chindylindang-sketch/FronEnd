import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../data/services/api_client.dart';
import '../bloc/order_bloc.dart';

/// Order Form Page — form tambah/edit pesanan.
/// Dropdown layanan auto-fill harga, input berat/jumlah, total harga otomatis.
class OrderFormPage extends StatefulWidget {
  final OrderModel? order; // null = tambah, ada isi = edit

  const OrderFormPage({super.key, this.order});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaPelangganController = TextEditingController();
  final _noHpController = TextEditingController();
  final _beratController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();

  List<ServiceModel> _services = [];
  bool _loadingServices = true;
  ServiceModel? _selectedService;
  DateTime _tanggalMasuk = DateTime.now();
  DateTime? _estimasiSelesai;
  double _totalHarga = 0;

  bool get isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    _loadServices();

    if (isEditing) {
      _namaPelangganController.text = widget.order!.namaPelanggan;
      _noHpController.text = widget.order!.noHp;
      if (widget.order!.beratKg != null) {
        _beratController.text = widget.order!.beratKg!.toStringAsFixed(1);
      }
      if (widget.order!.jumlah != null) {
        _jumlahController.text = widget.order!.jumlah.toString();
      }
      _catatanController.text = widget.order!.catatan ?? '';
      _tanggalMasuk = widget.order!.tanggalMasuk;
      _estimasiSelesai = widget.order!.estimasiSelesai;
      _totalHarga = widget.order!.totalHarga;
    }
  }

  Future<void> _loadServices() async {
    try {
      final repo = ServiceRepository(apiClient: context.read<ApiClient>());
      final services = await repo.getServices();
      setState(() {
        _services = services;
        _loadingServices = false;
        if (isEditing && services.isNotEmpty) {
          _selectedService = services.firstWhere(
            (s) => s.id == widget.order!.layananId,
            orElse: () => services.first,
          );
        }
      });
    } catch (e) {
      setState(() => _loadingServices = false);
    }
  }

  void _calculateTotal() {
    if (_selectedService == null) return;

    double total = 0;
    if (_selectedService!.isPerKg) {
      final berat = double.tryParse(_beratController.text) ?? 0;
      total = berat * _selectedService!.effectivePrice;
    } else {
      final jumlah = int.tryParse(_jumlahController.text) ?? 0;
      total = jumlah * _selectedService!.effectivePrice;
    }
    setState(() => _totalHarga = total);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == null) return;

    final order = OrderModel(
      layananId: _selectedService!.id!,
      namaPelanggan: _namaPelangganController.text.trim(),
      noHp: _noHpController.text.trim(),
      beratKg: _selectedService!.isPerKg
          ? double.tryParse(_beratController.text)
          : null,
      jumlah: !_selectedService!.isPerKg
          ? int.tryParse(_jumlahController.text)
          : null,
      totalHarga: _totalHarga,
      status: isEditing ? widget.order!.status : 'diterima',
      tanggalMasuk: _tanggalMasuk,
      estimasiSelesai: _estimasiSelesai,
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
    );

    if (isEditing) {
      context.read<OrderBloc>().add(
            OrderUpdateRequested(id: widget.order!.id!, order: order),
          );
    } else {
      context.read<OrderBloc>().add(OrderCreateRequested(order: order));
    }

    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context, bool isEstimasi) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEstimasi
          ? (_estimasiSelesai ?? DateTime.now().add(const Duration(days: 2)))
          : _tanggalMasuk,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isEstimasi) {
          _estimasiSelesai = picked;
        } else {
          _tanggalMasuk = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _namaPelangganController.dispose();
    _noHpController.dispose();
    _beratController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Pesanan' : 'Pesanan Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== Data Pelanggan =====
              _buildSectionTitle('Data Pelanggan'),
              const SizedBox(height: 12),
              _buildLabel('Nama Pelanggan'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaPelangganController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama pelanggan',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama pelanggan wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('No. Telepon'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noHpController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'No. telepon wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // ===== Detail Pesanan =====
              _buildSectionTitle('Detail Pesanan'),
              const SizedBox(height: 12),

              // Pilih Layanan
              _buildLabel('Layanan'),
              const SizedBox(height: 8),
              _loadingServices
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<ServiceModel>(
                      value: _selectedService,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Pilih layanan',
                        prefixIcon: Icon(Icons.local_laundry_service_outlined, size: 20),
                      ),
                      items: _services.map((service) {
                        return DropdownMenuItem<ServiceModel>(
                          value: service,
                          child: Text(
                            '${service.categoryIcon} ${service.namaLayanan} — ${service.displayPrice}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (service) {
                        setState(() {
                          _selectedService = service;
                          _beratController.clear();
                          _jumlahController.clear();
                          _totalHarga = 0;
                        });
                      },
                      validator: (v) => v == null ? 'Pilih layanan' : null,
                    ),
              const SizedBox(height: 16),

              // Berat / Jumlah (berdasarkan tipe harga service)
              if (_selectedService != null) ...[
                _buildLabel(
                  _selectedService!.isPerKg ? 'Berat (Kg)' : 'Jumlah (Pcs)',
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _selectedService!.isPerKg
                      ? _beratController
                      : _jumlahController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: _selectedService!.isPerKg
                        ? 'Contoh: 3.5'
                        : 'Contoh: 2',
                    prefixIcon: Icon(
                      _selectedService!.isPerKg
                          ? Icons.scale_rounded
                          : Icons.numbers_rounded,
                      size: 20,
                    ),
                  ),
                  onChanged: (_) => _calculateTotal(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (double.tryParse(v) == null) return 'Masukkan angka valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Total Harga (otomatis)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Harga',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Rp ${_totalHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // ===== Tanggal =====
              _buildSectionTitle('Jadwal'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Tanggal Masuk',
                      date: _tanggalMasuk,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'Estimasi Selesai',
                      date: _estimasiSelesai,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Catatan
              _buildLabel('Catatan (opsional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Catatan khusus untuk pesanan ini...',
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Simpan Perubahan' : 'Buat Pesanan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  date != null
                      ? '${date!.day} ${months[date!.month]} ${date!.year}'
                      : 'Pilih tanggal',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
