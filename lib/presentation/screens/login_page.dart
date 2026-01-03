import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/logic/auth/auth_cubit.dart';
import 'package:expense_tracker/logic/auth/auth_state.dart';
import 'package:expense_tracker/presentation/components/allFields.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_constants.dart';


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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            context.imageContainer(
              imagePath: ImagePathConstants.techWall,
              height: context.getPercentHeight(100)
            ),
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  context.pushNamedUnAuthenticated(RouteName.dashboard);
                }
    
                if(state is AuthError) {
                  context.showCustomDialog(description: 'Something went wrong');
                }
              },
              builder: (context, state) {
                return SafeArea(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: context.getPercentHeight(100),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: context.getPercentWidth(8)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: context.getPercentWidth(20)),
                              child: context.header(title: "Welcome Back", color: Colors.cyan),
                            ),
                            SizedBox(height: context.getPercentHeight(2)),
                            const Text(
                              "Login to manage your expenses",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                              ),
                            ),
    
                            SizedBox(height: context.getPercentHeight(5)),
    
                            EmailTextField(
                              controller: emailController,
                              hintText: "Enter your username",
                              labelStyle: const TextStyle(color: Colors.white),
                              onChanged: (_) => setState(() {}),
                            ),
    
                            SizedBox(height: context.getPercentHeight(5)),
    
                            PasswordTextField(
                              controller: passwordController,
                              hintText: "Enter your password",
                              labelStyle: const TextStyle(color: Colors.white),
                              onChanged: (_) => setState(() {}),
                            ),
    
                            SizedBox(height: context.getPercentHeight(5)),
    
                            Padding(
                              padding: EdgeInsets.only(right: context.getPercentWidth(11)),
                              child: context.navigationButton(
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
                            ),
    
                            SizedBox(height: context.getPercentHeight(5)),
    
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(right: context.getPercentWidth(10)),
                                child: context.textedButton(
                                  text: "Don’t have an account? Register",
                                  onButtonPress: () => context.pushNamedUnAuthenticated(RouteName.name),
                                  // onButtonPress: () => context.pushNamedUnAuthenticated(RouteName.dashboard),
                                ),
                              ),
                            ),
    
                            SizedBox(height: context.getPercentHeight(5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
    
              },
            ),
          ],
        ),
      ),
    );
  }
}