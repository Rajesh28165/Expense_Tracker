import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../util/colors.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../router/route_name.dart';
import '../../components/allFields.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
        emailRegex.hasMatch(emailController.text.trim()) &&
        pswdRegex.hasMatch(passwordController.text.trim());

    if (isValid != _isButtonEnabled) {
      setState(() => _isButtonEnabled = isValid);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        appBar: context.customAppBar(title: 'Login', showBackButton: false),
        body: context.gradientScreen(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              log.d('State on login page: $state');
              if (!context.isOn(RouteName.login)) return;

              // if  (
              //       state is VerifyLoading || 
              //       state is VerifySuccess || 
              //       state is VerifyEmailUnverified || 
              //       state is VerifyError ||
              //       state is RegisterLoading ||
              //       state is RegisterSuccess ||
              //       state is RegisterError
              //     ) return;

              if (state is LoginLoading || state is GoogleSignInLoading) {
                _showLoader(context, 'Signing you in...');
                return;
              }

              if (state is AuthAuthenticated) {
                _hideLoader(context);
                state.securityQuestionSelected
                  ? context.goTo(RouteName.dashboard)
                  : context.goTo(RouteName.security);
                return;
              }

              if (state is AuthEmailUnverified) {
                _hideLoader(context);
                context.pushTo(RouteName.emailVerification, extra: state.email);
                return;
              }

              if (state is LoginError) {
                _hideLoader(context);
                context.showCustomDialog(description: state.message);
                context.read<AuthCubit>().resetState();
                return;
              }

              if (state is GoogleSignInError) {
                _hideLoader(context);
                context.showCustomDialog(description: state.message);
                context.read<AuthCubit>().resetState();
                return;
              }

              if (state is AuthError) {
                _hideLoader(context);
                context.showCustomDialog(description: state.message);
                context.read<AuthCubit>().resetState();
                return;
              }

              if (state is! AuthLoading) {
                _hideLoader(context);
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
                              const Text(
                                "Welcome Back!",
                                style: TextStyle(
                                  fontSize: 30,
                                  color: AppConstants.commonTextColor,
                                  fontFamily: AppConstants.PlayfairDisplay,
                                ),
                              ),
                              SizedBox(height: context.getPercentHeight(1)),
                              const Text(
                                "Login to manage your expenses",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: AppConstants.Roboto,
                                  color: WidgetColors.activeGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: context.getPercentHeight(6)),
                              EmailTextField(
                                controller: emailController,
                                labelText: "Email",
                                hintText: "Enter your email",
                              ),
                              SizedBox(height: context.getPercentHeight(4)),
                              PasswordTextField(
                                controller: passwordController,
                                hintText: "Enter your password",
                              ),
                              SizedBox(height: context.getPercentHeight(0.5)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  context.textedButton(
                                    text: "Forgot password",
                                    onButtonPress: () => context.pushTo(RouteName.forgotPassword),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          children: [
                            SizedBox(height: context.getPercentHeight(1)),
                            context.navigationButton(
                              text: "Signin with Google",
                              activeTextColor: Colors.black,
                              activeBgColor: Colors.white,
                              borderColor: Colors.black,
                              canNavigate: true,
                              onBtnPress: context.read<AuthCubit>().signInWithGoogle,
                              iconWidget: SizedBox(
                                width: context.getPercentWidth(8),
                                height: context.getPercentHeight(2.5),
                                child: Image.asset(
                                  ImagePathConstants.googleIcon,
                                  fit: BoxFit.cover
                                ),
                              ),
                            ),
                            context.navigationButton(
                              text: "Login",
                              canNavigate: _isButtonEnabled,
                              onBtnPress: () {
                                context.read<AuthCubit>().login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              },
                            ),
                            context.textedButton(
                              text: "Don’t have an account? Register",
                              textUnderline: true,
                              onButtonPress: () => context.pushTo(RouteName.registeration),
                            )
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
      ),
    );
  }
}
