import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Klinik kodu → Supabase test hesap bilgileri
const _clinicCredentials = {
  'HESTI2024': (
    email: 'test@hesti.app',
    password: 'Hesti2024Test!',
    name: 'Dr. Test Kullanıcı',
  ),
};

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.getCurrentUser,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<ClinicCodeLoginEvent>(_onClinicCodeLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUser(const NoParams());

    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUser(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerUser(RegisterParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onClinicCodeLogin(
    ClinicCodeLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final code = event.clinicCode.trim().toUpperCase();
    final creds = _clinicCredentials[code];

    if (creds == null) {
      emit(const AuthError('Geçersiz klinik kodu'));
      return;
    }

    // Önce giriş dene
    final loginResult = await loginUser(LoginParams(
      email: creds.email,
      password: creds.password,
    ));

    final user = loginResult.fold(
      (failure) => null,
      (user) => user,
    );

    if (user != null) {
      emit(Authenticated(user));
      return;
    }

    // Giriş başarısız → kullanıcı henüz yok, kayıt ol
    final registerResult = await registerUser(RegisterParams(
      email: creds.email,
      password: creds.password,
      name: creds.name,
    ));

    registerResult.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUser(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }
}
