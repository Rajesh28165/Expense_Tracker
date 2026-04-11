import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../router/route_name.dart';
import '../../../util/colors.dart';
import '../../components/allFields.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';

class RegisterationPage extends StatefulWidget {
  const RegisterationPage({super.key});

  @override
  State<RegisterationPage> createState() => _RegisterationPageState();
}

class _RegisterationPageState extends State<RegisterationPage> {
  final _emailController = TextEditingController();
  final _pswdController = TextEditingController();
  final _cnfmPswdController = TextEditingController();

  final emailRegex = RegExp(RegexConstants.EMAIL_ADDRESS_PATTERN);
  final pswdRegex = RegExp(RegexConstants.PASSWORD_PATTERN);

  bool _isButtonEnabled = false;
  bool _isLoaderShowing = false;

  void _showLoader(BuildContext context, String text) {
    if (_isLoaderShowing) return;
    _isLoaderShowing = true;
    context.showLoader(text: text);
  }

  void _hideLoader(BuildContext context) {
    if (!_isLoaderShowing) return;
    _isLoaderShowing = false;
    context.hideLoader(context);
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _pswdController.addListener(_validateForm);
    _cnfmPswdController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
      emailRegex.hasMatch(_emailController.text.trim()) &&
      pswdRegex.hasMatch(_pswdController.text.trim()) &&
      _pswdController.text.trim() == _cnfmPswdController.text.trim();

    if (isValid != _isButtonEnabled) {
      setState(() => _isButtonEnabled = isValid);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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

  String? confirmPasswordError(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return null;
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  void onRegister() {
    context.read<AuthCubit>().register(
      email: _emailController.text.trim().toLowerCase(),
      password: _pswdController.text.trim(),
    );
  }

  Widget _buildFieldHint({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(icon, size: 13, color: Colors.white54),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Registration'),
      body: context.gradientScreen(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (!context.isOn(RouteName.registeration)) return;

            if (state is RegisterLoading) {
              _showLoader(context, 'Creating account...');
              return;
            }

            if (state is RegisterError) {
              _hideLoader(context);
              context.showCustomDialog(
                description: state.message,
                onPressed: () => context.read<AuthCubit>().resetState(),
              );
              return;
            }

            if (state is RegisterSuccess) {
              _hideLoader(context);
              context.pushTo(
                RouteName.emailVerification,
                extra: state.email,
              );
              return;
            }

            if (state is AuthAuthenticated) {
              return;
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

                            // Header
                            RichText(
                              text: const TextSpan(
                                text: "Welcome to ",
                                style: TextStyle(
                                  fontSize: 30,
                                  color: AppConstants.commonTextColor,
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
                            SizedBox(height: context.getPercentHeight(0.6)),
                            const Text(
                              "Know where your money goes",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: AppConstants.OpenSans,
                                color: WidgetColors.activeGreen,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            SizedBox(height: context.getPercentHeight(5)),

                            // Email field
                            _buildFieldHint(
                              icon: Icons.mail_outline_rounded,
                              text: 'A verification link will be sent to this address.',
                            ),
                            SizedBox(height: context.getPercentHeight(1.2)),
                            EmailTextField(controller: _emailController),

                            SizedBox(height: context.getPercentHeight(4)),

                            // Password field
                            _buildFieldHint(
                              icon: Icons.lock_outline_rounded,
                              text: 'Use 8–20 characters with uppercase, lowercase, number & special character'
                            ),
                            SizedBox(height: context.getPercentHeight(1.2)),
                            PasswordTextField(
                              controller: _pswdController,
                              hintText: "Enter password",
                              errorText: passwordError(_pswdController.text),
                            ),

                            SizedBox(height: context.getPercentHeight(3)),

                            // Confirm password field
                            PasswordTextField(
                              controller: _cnfmPswdController,
                              labelText: "Confirm password",
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
                    SafeArea(
                      child: Column(
                        children: [
                          SizedBox(height: context.getPercentHeight(2)),
                          context.navigationButton(
                            text: "Register",
                            canNavigate: _isButtonEnabled,
                            onBtnPress: onRegister,
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