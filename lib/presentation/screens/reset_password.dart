import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_constants.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/auth/auth_state.dart';
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
  Map<String, dynamic>? userData;
  String email = '';

  final _oldPswdController = TextEditingController();
  final _pswdController = TextEditingController();
  final _cnfmPswdController = TextEditingController();

  final emailRegex = RegExp(RegexConstants.EMAIL_ADDRESS_PATTERN);
  final pswdRegex = RegExp(RegexConstants.PASSWORD_PATTERN);

  @override
  void initState() {
    super.initState();
    _loadUser();
    _oldPswdController.addListener(_rebuild);
    _pswdController.addListener(_rebuild);
    _cnfmPswdController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _oldPswdController.dispose();
    _pswdController.dispose();
    _cnfmPswdController.dispose();
    super.dispose();
  }

    Future<void> _loadUser() async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() => userData = doc.data());
      }
    }

  // ---------- VALIDATION ----------

  String? passwordError(String password) {
    final value = password.trim();
    if (value.isEmpty) return null;
    if (value.length < 8) return 'Minimum 8 characters required';
    if (!pswdRegex.hasMatch(value)) return 'Invalid password format';
    return null;
  }

  String? confirmPasswordError(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return null;
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  bool get canNavigate {
    return 
      pswdRegex.hasMatch(_pswdController.text.trim()) &&
      _pswdController.text.trim() == _cnfmPswdController.text.trim();
  }

  void onReset() {
    final oldPswd = _oldPswdController.text.trim();
    final newPswd = _pswdController.text.trim();
    if(email.isEmpty) return;
    log.d('email is $email, old password is ${_oldPswdController.text} and new password is ${_pswdController.text}');

    if (oldPswd.toLowerCase() == newPswd.toLowerCase()) {
      context.showCustomDialog(description: 'New password cannot be the same to old password');
      return;
    }

    context.read<AuthCubit>().updatePassword(
      newPassword: newPswd,
    );
  }

  @override
  Widget build(BuildContext context) {
    email = userData?['email'] ?? '';
    return Scaffold(
      appBar: context.customAppBar(title: 'Reset Password'),
      body: context.gradientScreen(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              context.showLoader(text: 'Reseting Password...');
            }

            if (state is AuthAuthenticated) {
              context.hideLoader(context);
              context.showCustomDialog(
                description: 'Password updated successfully',
                onPressed: () => context.goTo(RouteName.dashboard),
              );
            }


            if (state is AuthError) {
              context.showCustomDialog(description: state.message);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Column(
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
                              AppConstants.Password_rule,
                              style: TextStyle(color: Colors.white,fontSize: 15),
                            ),

                            SizedBox(height: context.getPercentHeight(4)),

                            PasswordTextField(
                              controller: _oldPswdController,
                              labelText: "Old password",
                              hintText: "Enter old password",
                              errorText: passwordError(_oldPswdController.text),
                            ),

                            SizedBox(height: context.getPercentHeight(4)),

                            PasswordTextField(
                              controller: _pswdController,
                              labelText: "New password",
                              hintText: "Enter new password",
                              errorText: passwordError(_pswdController.text),
                            ),

                            SizedBox(height: context.getPercentHeight(4)),

                            PasswordTextField(
                              controller: _cnfmPswdController,
                              labelText: "Confirm new password",
                              hintText: "Re-enter new password",
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

                    SafeArea(
                      child: Column(
                        children: [
                          SizedBox(height: context.getPercentHeight(2)),
                          context.navigationButton(
                            text: "Proceed",
                            height: 6,
                            width: 100,
                            canNavigate: canNavigate,
                            onBtnPress: onReset,
                          ),
                          SizedBox(height: context.getPercentHeight(1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
