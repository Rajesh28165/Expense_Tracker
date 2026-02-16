import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_cubit.dart';
import '../../logic/auth/auth_state.dart';
import '../../router/route_name.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.goTo(RouteName.login);
        }
      },
      child: Scaffold(
        appBar: context.customAppBar(title: 'Profile'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// 🔐 Change Password
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change / Update Password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.pushTo(RouteName.resetPassword),
            ),

            const Divider(),

            /// 🛡 Security Questions
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Change / Update Security Questions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.pushTo(RouteName.security),
            ),

            const Divider(),
            const SizedBox(height: 40),

            /// 🚪 Sign Out
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _showSignOutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () async {
                  context.back();
                  await context.read<AuthCubit>().logout();
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
