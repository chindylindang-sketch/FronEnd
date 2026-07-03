import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../data/models/order_model.dart';
import '../bloc/order_bloc.dart';

/// Order Detail Page — menampilkan informasi lengkap pesanan.
/// Dengan tombol untuk mengubah status pesanan.
class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Hapus Pesanan',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderActionSuccess) {
            showCustomSnackbar(context, message: state.message);
            Navigator.pop(context);
          } else if (state is OrderError) {
            showCustomSnackbar(context, message: state.message, isError: true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status & ID header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.getStatusColor(order.status),
                      AppColors.getStatusColor(order.status).withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getStatusIcon(order.status),
                      size: 44,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      OrderStatuses.getLabel(order.status),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pesanan #${order.id}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data Pelanggan
              _InfoSection(
                title: 'Data Pelanggan',
                icon: Icons.person_outline_rounded,
                items: [
                  _InfoItem(label: 'Nama', value: order.namaPelanggan),
                  _InfoItem(label: 'No. Telepon', value: order.noHp),
                ],
              ),
              const SizedBox(height: 16),

              // Detail Layanan
              _InfoSection(
                title: 'Detail Layanan',
                icon: Icons.local_laundry_service_outlined,
                items: [
                  _InfoItem(
                    label: 'Layanan',
                    value: order.layanan?.namaLayanan ?? '-',
                  ),
                  _InfoItem(
                    label: 'Kategori',
                    value: order.layanan?.categoryLabel ?? '-',
                  ),
                  _InfoItem(
                    label: order.beratKg != null ? 'Berat' : 'Jumlah',
                    value: order.displayQuantity,
                  ),
                  _InfoItem(
                    label: 'Harga Satuan',
                    value: order.layanan?.displayPrice ?? '-',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Harga
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
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      order.formattedTotal,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Jadwal
              _InfoSection(
                title: 'Jadwal',
                icon: Icons.calendar_today_rounded,
                items: [
                  _InfoItem(label: 'Tanggal Masuk', value: order.formattedDate),
                  _InfoItem(label: 'Estimasi Selesai', value: order.formattedEstimasi),
                ],
              ),

              // Catatan
              if (order.catatan != null && order.catatan!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Catatan',
                  icon: Icons.note_outlined,
                  items: [
                    _InfoItem(label: '', value: order.catatan!),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Ubah status buttons
              Text(
                'Ubah Status',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: OrderStatuses.all.map((status) {
                  final isCurrentStatus = order.status == status;
                  final color = AppColors.getStatusColor(status);
                  return GestureDetector(
                    onTap: isCurrentStatus
                        ? null
                        : () {
                            context.read<OrderBloc>().add(
                                  OrderStatusUpdateRequested(
                                    id: order.id!,
                                    status: status,
                                  ),
                                );
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCurrentStatus
                            ? color
                            : color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        OrderStatuses.getLabel(status),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isCurrentStatus ? Colors.white : color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return Icons.inbox_rounded;
      case 'diproses':
        return Icons.local_laundry_service_rounded;
      case 'selesai':
        return Icons.check_circle_rounded;
      case 'diambil':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: const Text(
          'Yakin ingin menghapus pesanan ini?\nAksi ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrderBloc>().add(
                    OrderDeleteRequested(id: order.id!),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

/// Section info dengan title dan items
class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: item.label.isEmpty
                    ? Text(
                        item.value,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textLight,
                            ),
                          ),
                          Text(
                            item.value,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
              )),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}
