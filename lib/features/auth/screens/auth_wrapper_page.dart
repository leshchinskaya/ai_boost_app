// lib/features/auth/screens/auth_wrapper_page.dart
import 'package:ai_boost_app/features/auth/widgets/error_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_boost_app/features/auth/bloc/auth_bloc.dart';
import 'package:ai_boost_app/features/auth/widgets/phone_input_widget.dart';
import 'package:ai_boost_app/features/auth/widgets/otp_input_widget.dart';
import 'package:ai_boost_app/features/auth/widgets/loading_indicator_widget.dart';
import 'package:ai_boost_app/features/auth/widgets/authenticated_widget.dart';

class AuthWrapperPage extends StatelessWidget {
  const AuthWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Authentication')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial) {
            return const PhoneInputWidget();
          } else if (state is AuthCodeSending) {
            return const LoadingIndicatorWidget(message: 'Sending OTP...');
          } else if (state is AuthOtpInputRequired) {
            return OtpInputWidget(
              phoneNumber: state.phoneNumber,
              attempts: state.attempts,
            );
          } else if (state is AuthOtpVerifying) {
            return const LoadingIndicatorWidget(message: 'Verifying OTP...');
          } else if (state is AuthSuccess) {
            return AuthenticatedWidget(phoneNumber: state.phoneNumber);
          } else if (state is AuthFailure) {
            return ErrorDisplayWidget(
              errorMessage: state.message,
              onRetryPhone: state.canRetrySubmitPhone
                  ? () {
                      // This implies PhoneInputWidget should be shown again,
                      // or AuthInitial should be re-triggered.
                      // For simplicity, we can dispatch LogoutEvent to go to AuthInitial.
                      // Or, ErrorDisplayWidget could include a phone field.
                      // For now, let's assume retry phone means going back to phone input.
                      context.read<AuthBloc>().add(LogoutEvent()); // To reset to AuthInitial
                    }
                  : null,
              onResendCode: state.canResendCode ? () => context.read<AuthBloc>().add(ResendCodeEvent()) : null,
              onRetryOtp: state.canRetrySubmitOtp ? () {
                // This implies OtpInputWidget should be shown again.
                // The BLoC should re-emit AuthOtpInputRequired if this path is taken.
                // For now, ErrorDisplayWidget will just show message. User can trigger resend.
              } : null, // OtpInputWidget handles its own retry via resend or new OTP submission
            );
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
} 