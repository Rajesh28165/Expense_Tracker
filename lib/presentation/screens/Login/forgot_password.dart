import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants/app_constants.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../util/colors.dart';
import '../../components/allFields.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import '../../../router/route_name.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      context.showCustomDialog(description: 'Please enter email');
      return;
    }

    setState(() => _loading = true);

    final error = await context.read<AuthCubit>().sendPasswordResetEmail(email);

    if (!mounted) return;

    setState(() => _loading = false);

    if (error != null) {
      context.showCustomDialog(description: error);
    } else {
      context.showCustomDialog(
        description: 'If an account exists for this email, a password reset link has been sent. Please check your inbox and spam folder.',
        onPressed: () {
          Navigator.of(context).pop();
          context.goTo(RouteName.login);
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final canSubmit = !_loading && _emailController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: context.customAppBar(title: 'Forgot Password'),
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
                    SizedBox(height: context.getPercentHeight(2)),

                    RichText(
                      text: const TextSpan(
                        text: "Enter your registered ",
                        style: TextStyle(
                          fontSize: 25,
                          color: AppConstants.commonTextColor,
                          fontFamily: AppConstants.PlayfairDisplay,
                        ),
                        children: [
                          TextSpan(
                            text: "E-mail",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.getPercentHeight(1)),

                    const Text(
                      "We’ll send you a password reset link on your registered email",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: AppConstants.OpenSans,
                        color: WidgetColors.activeGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: context.getPercentHeight(5)),

                    RichText(
                      text: const TextSpan(
                        text: "Important note:",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppConstants.commonTextColor,                        
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline
                        ),
                        children: [
                          TextSpan(
                            text: ' \n${AppConstants.Password_reset_link_warning}\n\n${AppConstants.Password_rule}\n\n${AppConstants.Password_note}',
                            style: TextStyle( 
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.commonTextColor,
                              decoration: TextDecoration.none
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.getPercentHeight(4)),

                    EmailTextField(
                      controller: _emailController
                    ),

                    SizedBox(height: context.getPercentHeight(4)),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: context.getPercentHeight(2)),
                  context.navigationButton(
                    text: _loading ? "Sending..." : "Send Password Reset Link",
                    canNavigate: canSubmit,
                    onBtnPress: _submit,
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
