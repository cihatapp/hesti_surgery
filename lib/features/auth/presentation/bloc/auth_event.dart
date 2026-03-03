import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String? name;

  const RegisterEvent({
    required this.email,
    required this.password,
    this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class ClinicCodeLoginEvent extends AuthEvent {
  final String clinicCode;

  const ClinicCodeLoginEvent({required this.clinicCode});

  @override
  List<Object?> get props => [clinicCode];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
