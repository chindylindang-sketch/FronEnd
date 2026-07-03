import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

// ==================== EVENTS ====================

/// Base class untuk semua Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Event: cek apakah user sudah login (saat app start)
class AuthCheckRequested extends AuthEvent {}

/// Event: login user
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event: register user baru
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

/// Event: logout user
class AuthLogoutRequested extends AuthEvent {}

/// Event: ambil profil user
class AuthProfileRequested extends AuthEvent {}

// ==================== STATES ====================

/// Base class untuk semua Auth states
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// State: belum diketahui status login
class AuthInitial extends AuthState {}

/// State: sedang loading (login/register/check)
class AuthLoading extends AuthState {}

/// State: user sudah login (authenticated)
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State: user belum login (unauthenticated)
class AuthUnauthenticated extends AuthState {}

/// State: error saat proses auth
class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

/// AuthBloc — mengelola state autentikasi user.
///
/// Alur:
/// 1. App start → AuthCheckRequested → cek token → Authenticated/Unauthenticated
/// 2. Login → AuthLoginRequested → API call → Authenticated/Error
/// 3. Register → AuthRegisterRequested → API call → Authenticated/Error
/// 4. Logout → AuthLogoutRequested → clear token → Unauthenticated
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthProfileRequested>(_onProfileRequested);
  }

  /// Cek status login saat app mulai
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getProfile();
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Proses login
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: result['user'] as UserModel));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Proses register
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      emit(AuthAuthenticated(user: result['user'] as UserModel));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Proses logout
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  /// Ambil profil user
  Future<void> _onProfileRequested(
    AuthProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRepository.getProfile();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
