import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_constants.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../router/route_name.dart';
import '../components/allFields.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _pswdController = TextEditingController();
  final _cnfmPswdController = TextEditingController();

  bool _canProceed = false;
  final pswdRegex = RegExp(RegexConstants.PASSWORD_PATTERN);

  @override
  void initState() {
    super.initState();
    _pswdController.addListener(_validateForm);
    _cnfmPswdController.addListener(_validateForm);
  }

  void _validateForm() {
    final enabled =
        pswdRegex.hasMatch(_pswdController.text.trim()) &&
        _pswdController.text.trim() == _cnfmPswdController.text.trim();

    if (enabled != _canProceed) {
      setState(() => _canProceed = enabled);
    }
  }

  @override
  void dispose() {
    _pswdController.dispose();
    _cnfmPswdController.dispose();
    super.dispose();
  }

  String? passwordError(String password) {
    final value = password.trim();
    if (value.isEmpty) return null;
    if (value.length < 8) return 'Minimum 8 characters required';
    if (!pswdRegex.hasMatch(value)) return 'Invalid password format';
    return null;
  }

  String? confirmPasswordError(String p, String cp) {
    if (cp.isEmpty) return null;
    if (p != cp) return 'Passwords do not match';
    return null;
  }

  Future<void> _updatePassword(BuildContext context) async {
    final cubit = context.read<AuthCubit>();
    final newPassword = _pswdController.text.trim();

    context.showLoader(text: "Updating password...");

    final error = await cubit.updatePassword(newPassword: newPassword);

    context.hideLoader(context);

    if (error != null) {
      context.showCustomDialog(description: error);
      return;
    }

    context.showCustomDialog(
      description: "Password updated successfully",
      onPressed: () => context.goTo(RouteName.dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Set New Password'),
      body: context.gradientScreen(
        child: Column(
          children: [
            /// ✅ SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.getPercentHeight(2)),

                    const Text(
                      AppConstants.Password_rule,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),

                    SizedBox(height: context.getPercentHeight(4)),

                    PasswordTextField(
                      controller: _pswdController,
                      labelText: "New Password",
                      hintText: "Enter new password",
                      errorText: passwordError(_pswdController.text),
                    ),

                    SizedBox(height: context.getPercentHeight(4)),

                    PasswordTextField(
                      controller: _cnfmPswdController,
                      labelText: "Confirm Password",
                      hintText: "Re-enter password",
                      errorText: confirmPasswordError(
                        _pswdController.text,
                        _cnfmPswdController.text,
                      ),
                    ),

                    SizedBox(height: context.getPercentHeight(4)),
                  ],
                ),
              ),
            ),

            /// ✅ STICKY BOTTOM BUTTON
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: context.getPercentHeight(2)),

                  context.navigationButton(
                    text: "Update Password",
                    height: 6,
                    width: 100,
                    canNavigate: _canProceed,
                    onBtnPress: () => _updatePassword(context),
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