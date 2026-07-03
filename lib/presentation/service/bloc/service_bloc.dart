import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';

// ==================== EVENTS ====================

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();
  @override
  List<Object?> get props => [];
}

/// Event: muat semua layanan
class ServiceLoadRequested extends ServiceEvent {}

/// Event: tambah layanan baru
class ServiceCreateRequested extends ServiceEvent {
  final ServiceModel service;
  const ServiceCreateRequested({required this.service});
  @override
  List<Object?> get props => [service];
}

/// Event: update layanan
class ServiceUpdateRequested extends ServiceEvent {
  final int id;
  final ServiceModel service;
  const ServiceUpdateRequested({required this.id, required this.service});
  @override
  List<Object?> get props => [id, service];
}

/// Event: hapus layanan
class ServiceDeleteRequested extends ServiceEvent {
  final int id;
  const ServiceDeleteRequested({required this.id});
  @override
  List<Object?> get props => [id];
}

// ==================== STATES ====================

abstract class ServiceState extends Equatable {
  const ServiceState();
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

/// State: layanan berhasil dimuat
class ServiceLoaded extends ServiceState {
  final List<ServiceModel> services;
  const ServiceLoaded({required this.services});
  @override
  List<Object?> get props => [services];
}

/// State: operasi CRUD berhasil (create/update/delete)
class ServiceActionSuccess extends ServiceState {
  final String message;
  const ServiceActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class ServiceError extends ServiceState {
  final String message;
  const ServiceError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

/// ServiceBloc — mengelola state CRUD layanan laundry.
class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository _serviceRepository;

  ServiceBloc({required ServiceRepository serviceRepository})
      : _serviceRepository = serviceRepository,
        super(ServiceInitial()) {
    on<ServiceLoadRequested>(_onLoadRequested);
    on<ServiceCreateRequested>(_onCreateRequested);
    on<ServiceUpdateRequested>(_onUpdateRequested);
    on<ServiceDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    ServiceLoadRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    try {
      final services = await _serviceRepository.getServices();
      emit(ServiceLoaded(services: services));
    } catch (e) {
      emit(ServiceError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCreateRequested(
    ServiceCreateRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    try {
      await _serviceRepository.createService(event.service);
      emit(const ServiceActionSuccess(message: 'Layanan berhasil ditambahkan'));
      // Reload data setelah create
      final services = await _serviceRepository.getServices();
      emit(ServiceLoaded(services: services));
    } catch (e) {
      emit(ServiceError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateRequested(
    ServiceUpdateRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    try {
      await _serviceRepository.updateService(event.id, event.service);
      emit(const ServiceActionSuccess(message: 'Layanan berhasil diperbarui'));
      final services = await _serviceRepository.getServices();
      emit(ServiceLoaded(services: services));
    } catch (e) {
      emit(ServiceError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteRequested(
    ServiceDeleteRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    try {
      await _serviceRepository.deleteService(event.id);
      emit(const ServiceActionSuccess(message: 'Layanan berhasil dihapus'));
      final services = await _serviceRepository.getServices();
      emit(ServiceLoaded(services: services));
    } catch (e) {
      emit(ServiceError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
