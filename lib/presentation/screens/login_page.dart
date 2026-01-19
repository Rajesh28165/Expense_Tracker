import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../util/colors.dart';
import 'package:expense_tracker/constants/entension.dart';
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

  @override
  void initState() {
    super.initState();

    emailController.addListener(_onTextChanged);
    passwordController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get canNavigate {
    final RegExp emailRegex = RegExp(RegexConstants.EMAIL_ADDRESS_PATTERN);
    final RegExp pswdRegex = RegExp(RegexConstants.PASSWORD_PATTERN);
    var email = emailController.text.trim();
    var password = passwordController.text.trim();
    return emailRegex.hasMatch(email) && pswdRegex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: context.customAppBar(title: 'Login'),
      body: context.gradientScreen(
        child: Column(
          children: [
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  context.pushNamedUnAuthenticated(RouteName.dashboard);
                }
    
                if(state is AuthError) {
                  log.d(' Error is $AuthError');
                  context.showCustomDialog(description: 'Something went wrong');
                }
              },
              builder: (context, state) {
                return Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.getPercentHeight(1)),
                        const Text(
                          "Welcome Back! ",
                          style: TextStyle(
                            fontSize: 30,
                            color: WidgetColors.black,
                            fontFamily: AppConstants.PlayfairDisplay
                          )
                        ),
                        SizedBox(height: context.getPercentHeight(1)),
                        const Text(
                          "Login to manage your expenses",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: AppConstants.OpenSans,
                            color: WidgetColors.cyanBlue,
                            fontWeight: FontWeight.w800
                          ),
                        ),
                        SizedBox(height: context.getPercentHeight(8)),
                        EmailTextField(
                          controller: emailController,
                          labelText: "User Id",
                          hintText: "Enter your username",
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: context.getPercentHeight(5)),
                        PasswordTextField(
                          controller: passwordController,
                          hintText: "Enter your password",
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: context.getPercentHeight(5)),
                      ],
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: context.getPercentHeight(1)),
                  context.navigationButton(
                    height: 6,
                    width: 100,
                    text: "Login",
                    canNavigate: canNavigate,
                    onBtnPress: () {
                      context.read<AuthCubit>().login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                    },
                  ),
                  SizedBox(height: context.getPercentHeight(2)),
                ],
              ),
            ),
            Center(
              child: context.textedButton(
                text: "Don’t have an account? Register",
                textUnderline: true,
                onButtonPress: () => context.pushNamedUnAuthenticated(RouteName.name),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
