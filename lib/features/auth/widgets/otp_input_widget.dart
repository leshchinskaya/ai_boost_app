// lib/features/auth/widgets/otp_input_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_boost_app/features/auth/bloc/auth_bloc.dart';
import 'package:ai_boost_app/core/utils/validators.dart';

class OtpInputWidget extends StatefulWidget {
  final String phoneNumber;
  final int attempts;

  const OtpInputWidget({super.key, required this.phoneNumber, required this.attempts});

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String? _errorMessage;

  void _submitOtp() {
    setState(() {
      _errorMessage = null; // Clear previous error
    });
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SubmitOtpEvent(_otpController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter OTP sent to ${widget.phoneNumber}'),
            if (widget.attempts > 0) Text('Attempts: ${widget.attempts}', style: TextStyle(color: Colors.orange)),
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'OTP Code'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter OTP';
                }
                if (!Validators.isValidOtpFormat(value)) {
                  return 'OTP must be 4-8 digits';
                }
                return null;
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submitOtp, child: const Text('Verify OTP')),
            TextButton(
              onPressed: () => context.read<AuthBloc>().add(ResendCodeEvent()),
              child: const Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
} 