import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/services/api_client.dart';
import '../../home/pages/home_page.dart';
import '../bloc/dashboard_cubit.dart';

/// Dashboard Page — halaman utama setelah login.
/// Menampilkan statistik ringkas dan navigasi cepat ke fitur utama.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        dashboardRepository: DashboardRepository(
          apiClient: context.read<ApiClient>(),
        ),
      )..loadStats(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().loadStats(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ringkasan bisnis laundry Anda',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const ShimmerLoading(itemCount: 3, height: 100);
                }
                if (state is DashboardError) {
                  return ErrorStateWidget(
                    message: state.message,
                    onRetry: () => context.read<DashboardCubit>().loadStats(),
                  );
                }
                if (state is DashboardLoaded) {
                  final stats = state.stats;
                  return Column(
                    children: [
                      // Row 1: Pendapatan
                      _StatCard(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: AppColors.success,
                        iconBgColor: AppColors.success.withValues(alpha: 0.1),
                        title: 'Total Pendapatan',
                        value: stats.formattedPendapatan,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      // Row 2: Pesanan stats
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.receipt_long_rounded,
                              iconColor: AppColors.primary,
                              iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                              title: 'Total Pesanan',
                              value: stats.totalPesanan.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.today_rounded,
                              iconColor: AppColors.secondary,
                              iconBgColor: AppColors.secondary.withValues(alpha: 0.1),
                              title: 'Hari Ini',
                              value: stats.pesananHariIni.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 3: Belum selesai
                      _StatCard(
                        icon: Icons.pending_actions_rounded,
                        iconColor: AppColors.statusDiproses,
                        iconBgColor: AppColors.statusDiproses.withValues(alpha: 0.1),
                        title: 'Belum Selesai',
                        value: stats.pesananBelumSelesai.toString(),
                        subtitle: 'pesanan masih diproses',
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 20),
                      // Status breakdown
                      _StatusBreakdown(statusMap: stats.pesananPerStatus),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 28),

            // Quick Actions
            Text(
              'Menu Cepat',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.local_laundry_service_rounded,
                    label: 'Layanan',
                    color: AppColors.primary,
                    onTap: () {
                      // Navigate via BottomNav (index 1)
                      _switchTab(context, 1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.receipt_long_rounded,
                    label: 'Pesanan',
                    color: AppColors.secondary,
                    onTap: () {
                      _switchTab(context, 2);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.person_rounded,
                    label: 'Profil',
                    color: const Color(0xFF7C4DFF),
                    onTap: () {
                      _switchTab(context, 3);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _switchTab(BuildContext context, int index) {
    // Cari HomePageState untuk switch tab
    final homeState = context.findAncestorStateOfType<HomePageState>();
    homeState?.switchTab(index);
  }
}

/// Card statistik
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;
  final String? subtitle;
  final bool isFullWidth;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
    this.subtitle,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Breakdown status pesanan
class _StatusBreakdown extends StatelessWidget {
  final Map<String, int> statusMap;
  const _StatusBreakdown({required this.statusMap});

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
          Text(
            'Status Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow('Diterima', statusMap['diterima'] ?? 0, AppColors.statusDiterima),
          const SizedBox(height: 10),
          _buildStatusRow('Diproses', statusMap['diproses'] ?? 0, AppColors.statusDiproses),
          const SizedBox(height: 10),
          _buildStatusRow('Selesai', statusMap['selesai'] ?? 0, AppColors.statusSelesai),
          const SizedBox(height: 10),
          _buildStatusRow('Diambil', statusMap['diambil'] ?? 0, AppColors.statusDiambil),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Quick action card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


