import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_boost_app/features/auth/bloc/auth_bloc.dart';

class AuthenticatedWidget extends StatelessWidget {
  final String phoneNumber;
  const AuthenticatedWidget({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Successfully authenticated!'),
          Text('Phone: $phoneNumber'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 