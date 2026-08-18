import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';

// --- Auth Events ---
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? role;
  LoginRequested(this.email, this.password, {this.role});
}

class TwoFactorCodeSubmitted extends AuthEvent {
  final String pendingToken;
  final String code;
  TwoFactorCodeSubmitted({required this.pendingToken, required this.code});
}

class ReactivateAccountRequested extends AuthEvent {
  final String email;
  final String password;
  ReactivateAccountRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? phone;
  
  RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone,
  });
}

class CheckAuthStatus extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

// --- Auth States ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class TwoFactorRequired extends AuthState {
  final String pendingToken;
  TwoFactorRequired({required this.pendingToken});
}

class Authenticated extends AuthState {
  final AuthUser user;
  
  Authenticated({required this.user});

  String get role => user.role;
  String get userEmail => user.email;
  String get userName => user.name;
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- Auth BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<TwoFactorCodeSubmitted>(_onTwoFactorCodeSubmitted);
    on<ReactivateAccountRequested>(_onReactivateAccountRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.getStoredUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _repository.login(
        email: event.email,
        password: event.password,
        role: event.role,
      );
      final pendingToken = result.pendingTwoFactorToken;
      if (pendingToken != null && pendingToken.isNotEmpty) {
        emit(TwoFactorRequired(pendingToken: pendingToken));
      } else if (result.user != null) {
        emit(Authenticated(user: result.user!));
      } else {
        emit(AuthError('Unexpected login response. Please try again.'));
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> _onTwoFactorCodeSubmitted(TwoFactorCodeSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.completeTwoFactor(
        pendingToken: event.pendingToken,
        code: event.code,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> _onReactivateAccountRequested(ReactivateAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.reactivateAccount(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
        phone: event.phone,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(msg));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _repository.logout();
    emit(Unauthenticated());
  }
}
