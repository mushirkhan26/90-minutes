import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String mobile;

  const LoginRequested(this.mobile);

  @override
  List<Object?> get props => [mobile];
}

class OtpVerificationRequested extends AuthEvent {
  final String mobile;
  final String otp;

  const OtpVerificationRequested(this.mobile, this.otp);

  @override
  List<Object?> get props => [mobile, otp];
}

class SignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String mobile;

  const SignupRequested({
    required this.name,
    required this.email,
    required this.mobile,
  });

  @override
  List<Object?> get props => [name, email, mobile];
}

class LogoutRequested extends AuthEvent {}
