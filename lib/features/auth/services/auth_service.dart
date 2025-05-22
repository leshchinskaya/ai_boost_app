// lib/features/auth/services/auth_service.dart
import 'dart:async';
import 'dart:math';

class AuthService {
  /// Simulates sending an OTP.
  /// In a real app, this would call a backend API.
  Future<void> sendOtp(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate success/failure (90% success rate)
    if (Random().nextDouble() < 0.9) {
      // Successfully sent OTP (mock)
      print('OTP sent to $phoneNumber');
    } else {
      throw Exception('Сервис SMS недоступен');
    }
  }

  /// Simulates verifying an OTP.
  /// In a real app, this would call a backend API.
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock verification logic (e.g., OTP ending with "42" is valid)
    if (otp.endsWith('42')) {
      print('OTP $otp for $phoneNumber verified.');
      return true;
    } else {
      throw Exception('Неверный код');
    }
  }
} 