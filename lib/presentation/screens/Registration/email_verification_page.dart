// ignore_for_file: use_build_context_synchronously

import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../router/route_name.dart';


class EmailVerificationPage extends StatefulWidget {
  final String email;
  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {

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

  Future<void> _resendLink(BuildContext context) async {
    _showLoader(context, 'Sending verification email...');
    final error = await context.read<AuthCubit>().resendVerificationEmail();
    _hideLoader(context);
    if (error != null) {
      context.showCustomDialog(description: error);
    } else {
      context.showCustomDialog(description: 'Verification email resent. Please check your inbox and spam folder.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is VerifyLoading) {
          _showLoader(context, 'Verification in progress...');
          return;
        }

        if (state is VerifyEmailUnverified) {
          _hideLoader(context);
          context.showCustomDialog(description: 'Please verify your email before continuing.');
          return;
        }

        if (state is VerifyError) {
          _hideLoader(context);
          context.showCustomDialog(description: state.message);
          return;
        }

        if (state is VerifySuccess) {
          _hideLoader(context);
          state.securityQuestionSelected
              ? context.goTo(RouteName.dashboard)
              : context.goTo(RouteName.security);
          return;
        }

        if (state is AuthUnauthenticated) {
          if (_isLoaderShowing) return; 
          context.goTo(RouteName.login);
          return;
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          await context.read<AuthCubit>().logout();
          context.goTo(RouteName.login);
          return false;
        },
        child: Scaffold(
          appBar: context.customAppBar(
            title: 'Verify Email',
            onBackPressed: () async {
              await context.read<AuthCubit>().logout();
              context.goTo(RouteName.login);
            }
          ),
          body: context.gradientScreen(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 64, 
                        color: Colors.white
                      ),
                      SizedBox(height: context.getPercentHeight(3)),
                      const Text(
                        'Check your inbox',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.getPercentHeight(2)),
                      Text(
                        'We’ve sent a verification link to ${widget.email}.\n\nPlease check your inbox (and spam folder) and click the link to continue.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70, 
                          fontSize: 15
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      context.navigationButton(
                        text: "I’ve completed verification",
                        canNavigate: true,
                        onBtnPress: () => context.read<AuthCubit>().checkEmailVerified(),
                      ),
                      context.textedButton(
                        text: "Resend verification email",
                        textColor: Colors.white,
                        textUnderline: true,
                        onButtonPress: () => _resendLink(context)
                      ),
                      SizedBox(height: context.getPercentHeight(2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}