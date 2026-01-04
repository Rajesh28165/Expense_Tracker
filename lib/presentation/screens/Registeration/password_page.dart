import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants/app_constants.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../router/route_name.dart';
import '../../components/BaseField/baseTextField.dart';
import '../../components/allFields.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pswdController = TextEditingController();
  final TextEditingController _cnfmPswdController = TextEditingController();

    @override
  void initState() {
    super.initState();
    _emailController.addListener(_onTextChanged);
    _pswdController.addListener(_onTextChanged);
    _cnfmPswdController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _emailController.dispose();
    _pswdController.dispose();
    _cnfmPswdController.dispose();
    super.dispose();
  }

  bool get canRegister {
    final emailRegex = RegExp(RegexConstants.EMAIL_ADDRESS_PATTERN);
    final pswdRegex = RegExp(RegexConstants.PASSWORD_PATTERN);

    final email = _emailController.text.trim();
    final pswd = _pswdController.text.trim();
    final cnfmPswd = _cnfmPswdController.text.trim();

    return emailRegex.hasMatch(email) && pswdRegex.hasMatch(pswd) && pswd == cnfmPswd;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: "Registeration"),
      body: context.gradientScreen(
        child: Stack(
          children: [
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  context.pushNamedUnAuthenticated(RouteName.dashboard);
                }
      
                if (state is AuthError) {
                  context.showCustomDialog(description: state.message);
                }
              },
              builder: (context, state) {
                return SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        
                        SizedBox(height: context.getPercentHeight(5)),

                        EmailTextField(
                          controller: _emailController,
                          labelStyle: const TextStyle(color: Colors.black),
                          onChanged: (_) => setState(() {}),
                        ),
                        
                        SizedBox(height: context.getPercentHeight(4)),
                        
                        PasswordTextField(
                          controller: _pswdController,
                          hintText: "Enter password",
                          labelStyle: const TextStyle(color: Colors.black),
                          onChanged: (_) => setState(() {}),
                        ),
                        
                        SizedBox(height: context.getPercentHeight(4)),
                        
                        PasswordTextField(
                          controller: _cnfmPswdController,
                          labelText: "Confirm password",
                          hintText: "Re-enter password",
                          labelStyle: const TextStyle(color: Colors.black),
                          onChanged: (_) => setState(() {}),
                        ),
                        
                        SizedBox(height: context.getPercentHeight(20)),
                        
                        Center(
                          child: context.navigationButton(
                            text: "Register",
                            canNavigate: canRegister,
                            height: 6,
                            width: 75,
                            onBtnPress: () {
                              context.read<AuthCubit>().register(
                                _emailController.text.trim(),
                                _pswdController.text.trim(),
                              );
                            },
                          ),
                        ),
                        
                        SizedBox(height: context.getPercentHeight(4)),
                        
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: context.getPercentWidth(10),
                            ),
                            child: context.textedButton(
                              text: "Already have an account? Login",
                              onButtonPress: () => context.pushNamedUnAuthenticated(RouteName.login),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: context.getPercentHeight(5)),
                      ],
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
