part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SubmitPhoneEvent extends AuthEvent {
  final String phone;
  const SubmitPhoneEvent(this.phone);
  @override
  List<Object> get props => [phone];
}

class SubmitOtpEvent extends AuthEvent {
  final String otp;
  const SubmitOtpEvent(this.otp);
  @override
  List<Object> get props => [otp];
}

class ResendCodeEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

// Note: Internal events like _CodeSentEvent are defined in auth_bloc.dart
// to avoid circular dependencies if they needed to carry state data,
// or simply for better encapsulation if they don't. 