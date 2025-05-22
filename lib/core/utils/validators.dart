// lib/core/utils/validators.dart

class Validators {
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+\d{10,15}$').hasMatch(phone);
  }

  static bool isValidOtpFormat(String otp) {
    return RegExp(r'^\d{4,8}$').hasMatch(otp);
  }
} 