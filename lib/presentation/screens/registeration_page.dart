import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/app_constants.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/auth/auth_state.dart';
import '../../router/route_name.dart';
import '../../util/colors.dart';
import '../components/allFields.dart';
import '../components/baseField.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

class RegisterationPage extends StatefulWidget {
  const RegisterationPage({super.key});

  @override
  State<RegisterationPage> createState() => _RegisterationPageState();
}

class _RegisterationPageState extends State<RegisterationPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pswdController = TextEditingController();
  final _cnfmPswdController = TextEditingController();

  final emailRegex = RegExp(RegexConstants.EMAIL_ADDRESS_PATTERN);
  final pswdRegex = RegExp(RegexConstants.PASSWORD_PATTERN);

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.signOut(); // ensure clean session
    _nameController.addListener(_rebuild);
    _emailController.addListener(_rebuild);
    _pswdController.addListener(_rebuild);
    _cnfmPswdController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pswdController.dispose();
    _cnfmPswdController.dispose();
    super.dispose();
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
    return _nameController.text.trim().isNotEmpty &&
      emailRegex.hasMatch(_emailController.text.trim()) &&
      pswdRegex.hasMatch(_pswdController.text.trim()) &&
      _pswdController.text.trim() == _cnfmPswdController.text.trim();
  }

  void onRegister() {
    context.read<AuthCubit>().register(
      _emailController.text.trim(),
      _pswdController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Registration'),
      body: context.gradientScreen(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              if (state.securityQuestionSelected) {
                context.pushNamedAuthenticated(RouteName.navigation);
              } else {
                context.pushNamedUnAuthenticated(RouteName.security);
              }
            }

            if (state is AuthError) {
              context.showCustomDialog(description: state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

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

                            RichText(
                              text: const TextSpan(
                                text: "Welcome to ",
                                style: TextStyle(
                                  fontSize: 30,
                                  color:AppConstants.commonTextColor,
                                  fontFamily: AppConstants.PlayfairDisplay,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppConstants.appName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),

                            SizedBox(height: context.getPercentHeight(1)),

                            const Text(
                              "Know where your money goes",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: AppConstants.OpenSans,
                                color: WidgetColors.activeCta,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            SizedBox(height: context.getPercentHeight(4)),

                            BaseTextField(
                              controller: _nameController,
                              labelText: "Full name",
                              hintText: "Enter your full name",
                            ),

                            SizedBox(height: context.getPercentHeight(4)),

                            EmailTextField(controller: _emailController),

                            SizedBox(height: context.getPercentHeight(4)),

                            PasswordTextField(
                              controller: _pswdController,
                              hintText: "Enter password",
                              errorText: passwordError(_pswdController.text),
                            ),

                            SizedBox(height: context.getPercentHeight(4)),

                            PasswordTextField(
                              controller: _cnfmPswdController,
                              labelText: "Confirm password",
                              hintText: "Re-enter password",
                              errorText: confirmPasswordError(
                                _pswdController.text,
                                _cnfmPswdController.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Column(
                        children: [
                          context.navigationButton(
                            text: "Register",
                            height: 6,
                            width: 100,
                            canNavigate:
                                canNavigate && !isLoading,
                            onBtnPress: onRegister,
                          ),
                          SizedBox(height: context.getPercentHeight(1)),
                        ],
                      ),
                    ),
                  ],
                ),

                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
