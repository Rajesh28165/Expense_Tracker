import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_constants.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../util/colors.dart';
import '../components/allFields.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import '../../router/route_name.dart';

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
      setState(() {}); // rebuild on text change
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Future<void> _submit() async {
  //   final email = _emailController.text.trim();

  //   if (email.isEmpty) {
  //     _showMessage('Please enter email');
  //     return;
  //   }

  //   setState(() => _loading = true);

  //   final error = await context.read<AuthCubit>().sendPasswordResetEmail(email);

  //   if (!mounted) return;
  //   setState(() => _loading = false);

  //   if (error != null) {
  //     _showMessage(error);
  //   } else {
  //     _showMessage(
  //       'A password reset link is sent to $email',
  //       onOk: () {
  //         context.goTo(RouteName.login); // ✅ correct with GoRouter
  //       },
  //     );
  //   }
  // }


  Future<void> _submit() async {
  final email = _emailController.text.trim().toLowerCase();

  log.d('🟡 [UI] Forgot password submit clicked');
  log.d('🟡 [UI] Email entered: $email');

  if (email.isEmpty) {
    log.w('⚠️ [UI] Email is empty');
    _showMessage('Please enter email');
    return;
  }

  setState(() => _loading = true);

  final error =
      await context.read<AuthCubit>().sendPasswordResetEmail(email);

  if (!mounted) return;

  setState(() => _loading = false);

  if (error != null) {
    log.e('❌ [UI] Reset failed: $error');
    _showMessage(error);
  } else {
    log.d('✅ [UI] Reset flow completed');

    _showMessage(
      'If an account exists for this email, a password reset link has been sent.',
      onOk: () => context.goTo(RouteName.login),
    );
  }
}




  void _showMessage(String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      useRootNavigator: true, // ✅ important for GoRouter safety
      builder: (_) => AlertDialog(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(); // dialog only
              onOk?.call();
            },
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
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
                        text: "Reset your ",
                        style: TextStyle(
                          fontSize: 30,
                          color: AppConstants.commonTextColor,
                          fontFamily: AppConstants.PlayfairDisplay,
                        ),
                        children: [
                          TextSpan(
                            text: "Password",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.getPercentHeight(1)),

                    const Text(
                      "We’ll send you a reset link on your registered email",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: AppConstants.OpenSans,
                        color: WidgetColors.activeCta,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: context.getPercentHeight(5)),

                    EmailTextField(
                      controller: _emailController,
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
                    text: _loading ? "Sending..." : "Send Reset Link",
                    height: 6,
                    width: 100,
                    canNavigate: canSubmit,
                    onBtnPress: canSubmit ? _submit : null,
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
