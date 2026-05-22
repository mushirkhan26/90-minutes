import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String? action; // 'login' | 'verify' | 'signup'
  const AuthLoading({this.action});

  @override
  List<Object?> get props => [action];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String mobile;

  const AuthOtpSent(this.mobile);

  @override
  List<Object?> get props => [mobile];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];

}
