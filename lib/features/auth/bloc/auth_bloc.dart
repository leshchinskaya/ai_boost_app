// lib/features/auth/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ai_boost_app/core/utils/validators.dart';
import 'package:ai_boost_app/features/auth/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  String _phoneNumber = '';
  String _otp = '';
  int _attempts = 0;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<SubmitPhoneEvent>(_onSubmitPhone);
    on<SubmitOtpEvent>(_onSubmitOtp);
    on<ResendCodeEvent>(_onResendCode);
    on<LogoutEvent>(_onLogout);
    on<_CodeSentEvent>(_onCodeSent);
    on<_CodeSendingFailedEvent>(_onCodeSendingFailed);
    on<_OtpVerifiedEvent>(_onOtpVerified);
    on<_OtpVerificationFailedEvent>(_onOtpVerificationFailed);
  }

  Future<void> _onSubmitPhone(SubmitPhoneEvent event, Emitter<AuthState> emit) async {
    if (Validators.isValidPhoneNumber(event.phone)) {
      _phoneNumber = event.phone;
      // _attempts = 0; // Reset attempts for new phone number if needed by specific logic
      emit(AuthCodeSending(phoneNumber: _phoneNumber));
      try {
        await _authService.sendOtp(_phoneNumber);
        add(_CodeSentEvent());
      } catch (e) {
        add(_CodeSendingFailedEvent(e.toString()));
      }
    } else {
      emit(AuthFailure(
        message: 'Неверный формат номера телефона.',
        phoneNumber: event.phone, // Keep current phone for context if needed
        canRetrySubmitPhone: true,
        canResendCode: false,
        canRetrySubmitOtp: false,
      ));
    }
  }

  void _onCodeSent(_CodeSentEvent event, Emitter<AuthState> emit) {
    emit(AuthOtpInputRequired(phoneNumber: _phoneNumber, attempts: _attempts));
  }

  void _onCodeSendingFailed(_CodeSendingFailedEvent event, Emitter<AuthState> emit) {
    emit(AuthFailure(
      message: event.error,
      phoneNumber: _phoneNumber,
      canRetrySubmitPhone: true,
      canResendCode: true, // Allow resend for the same number
      canRetrySubmitOtp: false,
    ));
  }

  Future<void> _onSubmitOtp(SubmitOtpEvent event, Emitter<AuthState> emit) async {
    if (Validators.isValidOtpFormat(event.otp)) {
      _otp = event.otp;
      emit(AuthOtpVerifying(phoneNumber: _phoneNumber, otp: _otp));
      try {
        await _authService.verifyOtp(_phoneNumber, _otp);
        add(_OtpVerifiedEvent());
      } catch (e) {
        add(_OtpVerificationFailedEvent(e.toString()));
      }
    } else {
      emit(AuthFailure(
        message: 'Неверный формат кода',
        phoneNumber: _phoneNumber,
        canRetrySubmitPhone: false,
        canResendCode: true,
        canRetrySubmitOtp: true,
      ));
    }
  }

  void _onOtpVerified(_OtpVerifiedEvent event, Emitter<AuthState> emit) {
    _attempts = 0; // Reset attempts on success
    emit(AuthSuccess(phoneNumber: _phoneNumber));
  }

  void _onOtpVerificationFailed(_OtpVerificationFailedEvent event, Emitter<AuthState> emit) {
    _attempts++;
    emit(AuthFailure(
      message: event.error,
      phoneNumber: _phoneNumber,
      canRetrySubmitPhone: false,
      canResendCode: true,
      canRetrySubmitOtp: true,
      attempts: _attempts,
    ));
  }

  Future<void> _onResendCode(ResendCodeEvent event, Emitter<AuthState> emit) async {
    // This event can be triggered from AuthOtpInputRequired or AuthFailure states
    if (_phoneNumber.isNotEmpty) {
      emit(AuthCodeSending(phoneNumber: _phoneNumber));
      try {
        await _authService.sendOtp(_phoneNumber);
        add(_CodeSentEvent());
      } catch (e) {
        add(_CodeSendingFailedEvent(e.toString()));
      }
    } else {
      // Should not happen if UI logic is correct, but as a fallback:
      emit(AuthInitial()); // Go back to phone input if phone number is lost
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) {
    _phoneNumber = '';
    _otp = '';
    _attempts = 0;
    emit(AuthInitial());
  }
}

// Internal events for service call results
class _CodeSentEvent extends AuthEvent {}

class _CodeSendingFailedEvent extends AuthEvent {
  final String error;
  const _CodeSendingFailedEvent(this.error);
  @override
  List<Object> get props => [error];
}

class _OtpVerifiedEvent extends AuthEvent {}

class _OtpVerificationFailedEvent extends AuthEvent {
  final String error;
  const _OtpVerificationFailedEvent(this.error);
  @override
  List<Object> get props => [error];
} 