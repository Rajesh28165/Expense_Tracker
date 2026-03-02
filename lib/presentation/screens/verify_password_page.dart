import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../router/route_name.dart';
import '../components/allFields.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

class VerifyPasswordPage extends StatefulWidget {
  const VerifyPasswordPage({super.key});

  @override
  State<VerifyPasswordPage> createState() => _VerifyPasswordPageState();
}

class _VerifyPasswordPageState extends State<VerifyPasswordPage> {
  final _passwordController = TextEditingController();
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validate);
  }

  void _validate() {
    final enabled = _passwordController.text.trim().isNotEmpty;
    if (enabled != _canProceed) {
      setState(() => _canProceed = enabled);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final password = _passwordController.text.trim();

    context.showLoader(text: "Verifying...");

    final error = await context.read<AuthCubit>().verifyPassword(
      email: email,
      password: password,
    );

    context.hideLoader(context);

    if (error != null) {
      context.showCustomDialog(description: error);
      return;
    }

    context.pushTo(RouteName.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: "Verify Password"),
      body: context.gradientScreen(
        child: Stack(
          children: [
            Column(
              children: [
                /// 🔹 SCROLLABLE CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.getPercentHeight(6)),

                        const Text(
                          "Please enter your current password to continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),

                        SizedBox(height: context.getPercentHeight(4)),

                        PasswordTextField(
                          controller: _passwordController,
                          labelText: "Current Password",
                          hintText: "Enter your current password",
                        ),

                        SizedBox(height: context.getPercentHeight(4)),
                      ],
                    ),
                  ),
                ),

                /// 🔹 BOTTOM BUTTON (STICKY)
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: context.getPercentHeight(2)),

                      context.navigationButton(
                        text: "Verify",
                        canNavigate: _canProceed,
                        height: 6,
                        width: 100,
                        onBtnPress: () => _verifyPassword(context),
                      ),

                      SizedBox(height: context.getPercentHeight(1)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}