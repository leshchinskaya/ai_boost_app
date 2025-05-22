// lib/features/auth/bloc/auth_state.dart
part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {} // Corresponds to enterPhone

class AuthCodeSending extends AuthState {
  final String phoneNumber;
  const AuthCodeSending({required this.phoneNumber});
  @override
  List<Object> get props => [phoneNumber];
}

class AuthOtpInputRequired extends AuthState {
  final String phoneNumber;
  final int attempts; // To display or use in logic if needed
  const AuthOtpInputRequired({required this.phoneNumber, required this.attempts});
  @override
  List<Object> get props => [phoneNumber, attempts];
}

class AuthOtpVerifying extends AuthState {
  final String phoneNumber;
  final String otp;
  const AuthOtpVerifying({required this.phoneNumber, required this.otp});
  @override
  List<Object> get props => [phoneNumber, otp];
}

class AuthSuccess extends AuthState {
  final String phoneNumber; // Or user profile, token, etc.
  const AuthSuccess({required this.phoneNumber});
  @override
  List<Object> get props => [phoneNumber];
}

class AuthFailure extends AuthState {
  final String message;
  final String? phoneNumber; // Phone number context for retries
  final int? attempts; // Current attempts if error is related to OTP verification
  final bool canRetrySubmitPhone;
  final bool canResendCode;
  final bool canRetrySubmitOtp;

  const AuthFailure({
    required this.message,
    this.phoneNumber,
    this.attempts,
    this.canRetrySubmitPhone = false,
    this.canResendCode = false,
    this.canRetrySubmitOtp = false,
  });

  @override
  List<Object?> get props => [
        message,
        phoneNumber,
        attempts,
        canRetrySubmitPhone,
        canResendCode,
        canRetrySubmitOtp,
      ];
} 