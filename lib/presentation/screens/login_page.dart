import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../util/colors.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/auth/auth_state.dart';
import '../../router/route_name.dart';
import '../components/allFields.dart';

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
    return Scaffold(
      appBar: context.customAppBar(title: 'Login'),
      body: context.gradientScreen(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              context.showLoader(text: 'Signing you in...');
            } else {
              context.hideLoader(context);
            }

            if (state is AuthAuthenticated) {
              if (state.securityQuestionSelected) {
                context.goTo(RouteName.dashboard);
              } else {
                context.goTo(RouteName.security);
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
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
                                  color: WidgetColors.activeCta,
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
                                    textColor: Colors.white,
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
                              height: 6,
                              width: 100,
                              text: "Signin with Google",
                              activeBgColor: Colors.white,
                              borderColor: Colors.black,
                              canNavigate: !isLoading,
                              onBtnPress: () => context.read<AuthCubit>().signInWithGoogle(),
                              iconWidget: Image.asset(ImagePathConstants.googleIcon),
                            ),
                            SizedBox(height: context.getPercentHeight(1)),
                            context.navigationButton(
                              height: 6,
                              width: 100,
                              text: "Login",
                              canNavigate: _isButtonEnabled && !isLoading,
                              onBtnPress: () {
                                context.read<AuthCubit>().login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              },
                            ),
                            SizedBox(height: context.getPercentHeight(1)),
                            context.textedButton(
                              text: "Don’t have an account? Register",
                              textColor: Colors.white,
                              textUnderline: true,
                              onButtonPress: () => context.pushTo(RouteName.registeration),
                            )
                          ],
                        ),
                      ),
                    ],
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
