import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_boost_app/features/auth/bloc/auth_bloc.dart';
import 'package:ai_boost_app/core/utils/validators.dart';

class PhoneInputWidget extends StatefulWidget {
  const PhoneInputWidget({super.key});

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _errorMessage;

  void _submitPhoneNumber() {
    setState(() {
      _errorMessage = null; // Clear previous error
    });
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SubmitPhoneEvent(_phoneController.text));
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
            const Text('Enter your phone number to begin:'),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number (e.g., +1234567890)'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!Validators.isValidPhoneNumber(value)) {
                  return 'Invalid phone number format (e.g., +1234567890)';
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
            ElevatedButton(onPressed: _submitPhoneNumber, child: const Text('Send OTP')),
          ],
        ),
      ),
    );
  }
} 