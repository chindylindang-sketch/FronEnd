import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../data/models/order_model.dart';
import '../bloc/order_bloc.dart';
import 'order_form_page.dart';
import 'order_detail_page.dart';

/// Order List Page — menampilkan daftar pesanan pelanggan.
/// Dengan fitur search dan filter status.
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<OrderBloc>().state;
      if (state is OrderInitial) {
        context.read<OrderBloc>().add(const OrderLoadRequested());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    context.read<OrderBloc>().add(OrderLoadRequested(
          status: _selectedStatus,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
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
                        'Pesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Kelola pesanan pelanggan',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
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

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _applyFilter(),
                decoration: InputDecoration(
                  hintText: 'Cari nama pelanggan...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilter();
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: _selectedStatus == null,
                    onTap: () {
                      setState(() => _selectedStatus = null);
                      _applyFilter();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...OrderStatuses.all.map((status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: OrderStatuses.getLabel(status),
                          isSelected: _selectedStatus == status,
                          color: AppColors.getStatusColor(status),
                          onTap: () {
                            setState(() => _selectedStatus = status);
                            _applyFilter();
                          },
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Expanded(
              child: BlocConsumer<OrderBloc, OrderState>(
                listener: (context, state) {
                  if (state is OrderActionSuccess) {
                    showCustomSnackbar(context, message: state.message);
                  } else if (state is OrderError) {
                    showCustomSnackbar(context, message: state.message, isError: true);
                  }
                },
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const ShimmerLoading(itemCount: 5, height: 110);
                  }
                  if (state is OrderError) {
                    return ErrorStateWidget(
                      message: state.message,
                      onRetry: () => context.read<OrderBloc>().add(
                            const OrderLoadRequested(),
                          ),
                    );
                  }
                  if (state is OrderLoaded) {
                    if (state.orders.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.receipt_long_rounded,
                        title: 'Belum Ada Pesanan',
                        subtitle: _selectedStatus != null
                            ? 'Tidak ada pesanan dengan status ini'
                            : 'Buat pesanan baru untuk pelanggan Anda',
                        buttonLabel:
                            _selectedStatus == null ? 'Buat Pesanan' : null,
                        onButtonPressed:
                            _selectedStatus == null ? () => _navigateToForm(context) : null,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<OrderBloc>().add(OrderLoadRequested(
                              status: _selectedStatus,
                              search: _searchController.text.trim().isEmpty
                                  ? null
                                  : _searchController.text.trim(),
                            ));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: state.orders.length,
                        itemBuilder: (context, index) {
                          return _OrderCard(
                            order: state.orders[index],
                            onTap: () => _navigateToDetail(context, state.orders[index]),
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

  void _navigateToForm(BuildContext context, {OrderModel? order}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrderBloc>(),
          child: OrderFormPage(order: order),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrderBloc>(),
          child: OrderDetailPage(order: order),
        ),
      ),
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.12) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? activeColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Order card widget — menampilkan info pesanan dalam card
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Customer avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          order.namaPelanggan.isNotEmpty
                              ? order.namaPelanggan[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name & service
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.namaPelanggan,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.layanan?.namaLayanan ?? '-',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    StatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom row: price & date
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(
                      order.formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      order.formattedTotal,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
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
