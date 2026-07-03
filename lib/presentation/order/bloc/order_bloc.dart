import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

// ==================== EVENTS ====================

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

/// Event: muat pesanan (dengan filter opsional)
class OrderLoadRequested extends OrderEvent {
  final String? status;
  final String? search;
  const OrderLoadRequested({this.status, this.search});
  @override
  List<Object?> get props => [status, search];
}

/// Event: buat pesanan baru
class OrderCreateRequested extends OrderEvent {
  final OrderModel order;
  const OrderCreateRequested({required this.order});
  @override
  List<Object?> get props => [order];
}

/// Event: update pesanan
class OrderUpdateRequested extends OrderEvent {
  final int id;
  final OrderModel order;
  const OrderUpdateRequested({required this.id, required this.order});
  @override
  List<Object?> get props => [id, order];
}

/// Event: update status pesanan
class OrderStatusUpdateRequested extends OrderEvent {
  final int id;
  final String status;
  const OrderStatusUpdateRequested({required this.id, required this.status});
  @override
  List<Object?> get props => [id, status];
}

/// Event: hapus pesanan
class OrderDeleteRequested extends OrderEvent {
  final int id;
  const OrderDeleteRequested({required this.id});
  @override
  List<Object?> get props => [id];
}

// ==================== STATES ====================

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;
  const OrderLoaded({required this.orders});
  @override
  List<Object?> get props => [orders];
}

class OrderActionSuccess extends OrderState {
  final String message;
  const OrderActionSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class OrderError extends OrderState {
  final String message;
  const OrderError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

/// OrderBloc — mengelola state CRUD pesanan pelanggan.
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  // Simpan filter terakhir agar bisa reload setelah CRUD
  String? _lastStatus;
  String? _lastSearch;

  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrderInitial()) {
    on<OrderLoadRequested>(_onLoadRequested);
    on<OrderCreateRequested>(_onCreateRequested);
    on<OrderUpdateRequested>(_onUpdateRequested);
    on<OrderStatusUpdateRequested>(_onStatusUpdateRequested);
    on<OrderDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    OrderLoadRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    _lastStatus = event.status;
    _lastSearch = event.search;
    try {
      final orders = await _orderRepository.getOrders(
        status: event.status,
        search: event.search,
      );
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCreateRequested(
    OrderCreateRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await _orderRepository.createOrder(event.order);
      emit(const OrderActionSuccess(message: 'Pesanan berhasil dibuat'));
      final orders = await _orderRepository.getOrders(
        status: _lastStatus,
        search: _lastSearch,
      );
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateRequested(
    OrderUpdateRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await _orderRepository.updateOrder(event.id, event.order);
      emit(const OrderActionSuccess(message: 'Pesanan berhasil diperbarui'));
      final orders = await _orderRepository.getOrders(
        status: _lastStatus,
        search: _lastSearch,
      );
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onStatusUpdateRequested(
    OrderStatusUpdateRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await _orderRepository.updateStatus(event.id, event.status);
      emit(OrderActionSuccess(
        message: 'Status berhasil diubah ke ${event.status}',
      ));
      final orders = await _orderRepository.getOrders(
        status: _lastStatus,
        search: _lastSearch,
      );
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteRequested(
    OrderDeleteRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await _orderRepository.deleteOrder(event.id);
      emit(const OrderActionSuccess(message: 'Pesanan berhasil dihapus'));
      final orders = await _orderRepository.getOrders(
        status: _lastStatus,
        search: _lastSearch,
      );
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
