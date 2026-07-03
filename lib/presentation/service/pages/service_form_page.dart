import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../data/models/service_model.dart';
import '../bloc/service_bloc.dart';

/// Service Form Page — form tambah/edit layanan.
class ServiceFormPage extends StatefulWidget {
  final ServiceModel? service; // null = tambah, ada isi = edit

  const ServiceFormPage({super.key, this.service});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _estimasiController;
  late TextEditingController _deskripsiController;
  String _selectedKategori = 'cuci_reguler';
  String _pricingType = 'per_kg'; // per_kg atau satuan

  bool get isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.service?.namaLayanan ?? '');
    _estimasiController = TextEditingController(text: widget.service?.estimasiWaktu ?? '');
    _deskripsiController = TextEditingController(text: widget.service?.deskripsi ?? '');

    if (isEditing) {
      _selectedKategori = widget.service!.kategori;
      if (widget.service!.hargaPerKg != null) {
        _pricingType = 'per_kg';
        _hargaController = TextEditingController(
          text: widget.service!.hargaPerKg!.toStringAsFixed(0),
        );
      } else {
        _pricingType = 'satuan';
        _hargaController = TextEditingController(
          text: widget.service!.hargaSatuan?.toStringAsFixed(0) ?? '',
        );
      }
    } else {
      _hargaController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _estimasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final harga = double.tryParse(_hargaController.text) ?? 0;
    final service = ServiceModel(
      namaLayanan: _namaController.text.trim(),
      kategori: _selectedKategori,
      hargaPerKg: _pricingType == 'per_kg' ? harga : null,
      hargaSatuan: _pricingType == 'satuan' ? harga : null,
      estimasiWaktu: _estimasiController.text.trim(),
      deskripsi: _deskripsiController.text.trim().isEmpty
          ? null
          : _deskripsiController.text.trim(),
    );

    if (isEditing) {
      context.read<ServiceBloc>().add(
            ServiceUpdateRequested(id: widget.service!.id!, service: service),
          );
    } else {
      context.read<ServiceBloc>().add(ServiceCreateRequested(service: service));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Layanan' : 'Tambah Layanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Layanan
              _buildLabel('Nama Layanan'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Cuci Reguler 2 Hari',
                  prefixIcon: Icon(Icons.label_outline_rounded, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama layanan wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // Kategori
              _buildLabel('Kategori'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                ),
                items: ServiceCategories.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['value'],
                    child: Text('${cat['icon']} ${cat['label']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedKategori = value);
                },
              ),
              const SizedBox(height: 20),

              // Tipe Harga
              _buildLabel('Tipe Harga'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _PricingTypeChip(
                      label: 'Per Kilogram',
                      isSelected: _pricingType == 'per_kg',
                      onTap: () => setState(() => _pricingType = 'per_kg'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PricingTypeChip(
                      label: 'Per Satuan',
                      isSelected: _pricingType == 'satuan',
                      onTap: () => setState(() => _pricingType = 'satuan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Harga
              _buildLabel(
                _pricingType == 'per_kg' ? 'Harga per Kg (Rp)' : 'Harga Satuan (Rp)',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 7000',
                  prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                  suffixText: _pricingType == 'per_kg' ? '/kg' : '/pcs',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Harga wajib diisi';
                  if (double.tryParse(v) == null) return 'Harga harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Estimasi Waktu
              _buildLabel('Estimasi Waktu'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _estimasiController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 2 hari',
                  prefixIcon: Icon(Icons.schedule_rounded, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Estimasi waktu wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // Deskripsi
              _buildLabel('Deskripsi (opsional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Deskripsi layanan...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.description_outlined, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Layanan'),
              ),
            ],
          ),
        ),
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

class _PricingTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
