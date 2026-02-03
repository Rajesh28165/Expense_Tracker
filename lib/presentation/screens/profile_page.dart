import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_cubit.dart';
import '../../router/route_name.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 🔐 Change Password
          // ListTile(
          //   leading: const Icon(Icons.lock_outline),
          //   title: const Text('Change / Update Password'),
          //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //   onTap: () {
          //     context.pushNamedAuthenticated(RouteName.changePassword);
          //   },
          // ),

          // const Divider(),

          // /// 🛡 Security Questions
          // ListTile(
          //   leading: const Icon(Icons.security),
          //   title: const Text('Change / Update Security Questions'),
          //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //   onTap: () {
          //     context.pushNamedAuthenticated(RouteName.securityQuestions);
          //   },
          // ),

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
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);

              /// 🔥 AUTH LOGOUT
              await context.read<AuthCubit>().logout();

              /// 🔁 Go to unauth flow
              // ignore: use_build_context_synchronously
              context.pushNamedUnAuthenticated(RouteName.login);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
