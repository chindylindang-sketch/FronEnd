import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/repositories/dashboard_repository.dart';

// ==================== STATES ====================

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardModel stats;
  const DashboardLoaded({required this.stats});
  @override
  List<Object?> get props => [stats];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ==================== CUBIT ====================

/// DashboardCubit — mengelola state statistik dashboard.
/// Menggunakan Cubit (bukan Bloc) karena hanya ada satu operasi (load stats).
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardCubit({required DashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository,
        super(DashboardInitial());

  /// Muat statistik dashboard
  Future<void> loadStats() async {
    emit(DashboardLoading());
    try {
      final stats = await _dashboardRepository.getStats();
      emit(DashboardLoaded(stats: stats));
    } catch (e) {
      emit(DashboardError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
