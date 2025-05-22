import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetryPhone;
  final VoidCallback? onResendCode;
  final VoidCallback? onRetryOtp; // This might be less used if OTP input is shown again

  const ErrorDisplayWidget({
    super.key,
    required this.errorMessage,
    this.onRetryPhone,
    this.onResendCode,
    this.onRetryOtp,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (onRetryPhone != null)
              ElevatedButton(onPressed: onRetryPhone, child: const Text('Enter Phone Again')),
            if (onResendCode != null)
              ElevatedButton(onPressed: onResendCode, child: const Text('Resend Code')),
            // Retry OTP might involve showing the OTP screen again, handled by AuthWrapperPage or specific OTP widget
            // if (onRetryOtp != null) ElevatedButton(onPressed: onRetryOtp, child: const Text('Retry OTP')),
          ],
        ),
      ),
    );
  }
} 