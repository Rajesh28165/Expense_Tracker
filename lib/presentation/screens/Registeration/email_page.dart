import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants/app_constants.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../router/route_name.dart';
import '../../components/allFields.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final TextEditingController _emailController = TextEditingController();


    @override
  void initState() {
    super.initState();
    _emailController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  bool get canNavigate {
    final emailRegex = RegExp(RegexConstants.EMAIL_ADDRESS_PATTERN);
    final email = _emailController.text.trim();

    return emailRegex.hasMatch(email);
  }

  void onProceed() {
    context.pushNamedUnAuthenticated(RouteName.password);
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
                        
                        SizedBox(height: context.getPercentHeight(20)),
                        
                        Center(
                          child: context.navigationButton(
                            text: "Proceed",
                            canNavigate: canNavigate,
                            height: 6,
                            width: 75,
                            onBtnPress: () {},
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
