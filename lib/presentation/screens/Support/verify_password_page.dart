// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../router/route_name.dart';
import '../../components/allFields.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';

class VerifyPasswordPage extends StatefulWidget {
  final String purpose;
  final int count;
  const VerifyPasswordPage({
    super.key,
    required this.purpose,
    required this.count,
  });

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

    if (widget.purpose == AppConstants.purposeUpdatePassword) {
      context.pushTo(RouteName.resetPassword);
    } else if (widget.purpose == AppConstants.purposeUpdateSecurityQA) {
      context.pushTo(RouteName.security);
    }
  }

  void _forgotPassword(BuildContext context) {
    if (widget.count >= 2) {
      context.showCustomDialog(
        description: '${AppConstants.Password_reset_link_header}\n\n${AppConstants.Password_reset_link_warning}\n\n${AppConstants.Password_rule}\n\n${AppConstants.Password_note}',
        onPressed: () => CommonMethods.handleFullForgot(context),
        paddingValue: 4,
        showIcon: false,
        buttonText: 'Proceed'
      );
    } else {
      context.pushTo(RouteName.verifySecurityQuestion, extra: {
        'purpose': widget.purpose,
        'count': widget.count + 1,
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: "Verify Password"),
      body: context.gradientScreen(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.getPercentHeight(1)),

                    const Text(
                      "Please verify your current password to continue",
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

                    SizedBox(height: context.getPercentHeight(1)),

                    Align(
                      alignment: Alignment.centerRight,
                      child: context.textedButton(
                        text: 'Forgot Password',
                        textUnderline: true,
                        onButtonPress: () => _forgotPassword(context),
                      ),
                    ),
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
                    onBtnPress: () => _verifyPassword(context),
                  ),

                  SizedBox(height: context.getPercentHeight(1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
