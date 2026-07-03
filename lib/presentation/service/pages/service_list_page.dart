import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../data/models/service_model.dart';
import '../bloc/service_bloc.dart';
import 'service_form_page.dart';

/// Service List Page — menampilkan daftar layanan laundry.
class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Load data saat pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<ServiceBloc>().state;
      if (state is ServiceInitial) {
        context.read<ServiceBloc>().add(ServiceLoadRequested());
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Layanan',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Kelola jenis layanan laundry',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Add button
                  GestureDetector(
                    onTap: () => _navigateToForm(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: BlocConsumer<ServiceBloc, ServiceState>(
                listener: (context, state) {
                  if (state is ServiceActionSuccess) {
                    showCustomSnackbar(context, message: state.message);
                  } else if (state is ServiceError) {
                    showCustomSnackbar(context, message: state.message, isError: true);
                  }
                },
                builder: (context, state) {
                  if (state is ServiceLoading) {
                    return const ShimmerLoading(itemCount: 4, height: 120, isGrid: true);
                  }
                  if (state is ServiceError) {
                    return ErrorStateWidget(
                      message: state.message,
                      onRetry: () =>
                          context.read<ServiceBloc>().add(ServiceLoadRequested()),
                    );
                  }
                  if (state is ServiceLoaded) {
                    if (state.services.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.local_laundry_service_rounded,
                        title: 'Belum Ada Layanan',
                        subtitle: 'Tambahkan layanan laundry pertama Anda',
                        buttonLabel: 'Tambah Layanan',
                        onButtonPressed: () => _navigateToForm(context),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ServiceBloc>().add(ServiceLoadRequested());
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: state.services.length,
                        itemBuilder: (context, index) {
                          return _ServiceCard(
                            service: state.services[index],
                            onEdit: () =>
                                _navigateToForm(context, service: state.services[index]),
                            onDelete: () =>
                                _confirmDelete(context, state.services[index]),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, {ServiceModel? service}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ServiceBloc>(),
          child: ServiceFormPage(service: service),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Layanan'),
        content: Text(
          'Yakin ingin menghapus "${service.namaLayanan}"?\nAksi ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ServiceBloc>().add(
                    ServiceDeleteRequested(id: service.id!),
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

/// Card layanan — menampilkan info layanan dalam bentuk grid card
class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon & actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          service.categoryIcon,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Hapus', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                // Service name
                Text(
                  service.namaLayanan,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Category label
                Text(
                  service.categoryLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Price
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    service.displayPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Estimasi
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 12, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      service.estimasiWaktu,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
