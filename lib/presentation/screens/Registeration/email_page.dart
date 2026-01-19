import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../data/cubit/userCubit.dart';
import '../../../router/route_name.dart';
import '../../../util/colors.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import '../../components/allFields.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isChecking = false;

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
    return emailRegex.hasMatch(email) && !_isChecking;
  }



  // void onProceed() async {
  //   final email = _emailController.text.trim();

  //   setState(() => _isChecking = true);
  //   context.showLoader(text: 'Verifying email');

  //   final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
  //   log.d('method is $methods');
  //   if (!mounted) return;

  //   if (methods.isNotEmpty) {
  //     context.hideLoader();
  //     setState(() => _isChecking = false);

  //     context.showCustomDialog(description: 'This email is already registered');
  //     return;
  //   }

  //   context.read<UserCubit>().setEmail(email);

  //   final storedEmail = context.read<UserCubit>().state.email;
  //   log.d('stored email is $storedEmail');

  //   context.hideLoader();
  //   setState(() => _isChecking = false);

  //   context.pushNamedUnAuthenticated(RouteName.password);
  // }

  
  void onProceed() async {
    final email = _emailController.text.trim();

    setState(() => _isChecking = true);
    context.showLoader(text: 'Verifying email');
    log.d('log 1');

    try {
      log.d('log 2');
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      log.d('log 3');
      if (!mounted) return;

      if (methods.isNotEmpty) {
        context.hideLoader();
        context.showCustomDialog(
          description: 'This email is already registered',
        );
        return;
      }
      log.d('log 4');
      context.hideLoader();
      context.read<UserCubit>().setEmail(email);
      context.pushNamedUnAuthenticated(RouteName.password);

    } on FirebaseAuthException catch (e) {
      log.d('log 5');
      context.hideLoader();
      context.showCustomDialog(
        description: e.message ?? 'Unable to verify email',
      );
    } catch (_) {
      log.d('log 6');
      context.hideLoader();
      context.showCustomDialog(
        description: 'Something went wrong. Please try again.',
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Registeration'),
      body: context.gradientScreen(
        child: Column(
          children: [
            /// -------- SCROLLABLE CONTENT --------
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: context.getPercentHeight(4)),
                    
                    EmailTextField(
                      controller: _emailController,
                      onChanged: (_) => setState(() {}),
                    ), 

                  ],
                ),
              ),
            ),

            /// -------- FIXED PROCEED BUTTON --------

            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: context.getPercentHeight(1)),
                  context.navigationButton(
                    text: "Proceed",
                    canNavigate: canNavigate,
                    height: 6,
                    width: 100,
                    onBtnPress: onProceed,
                  ),
                  SizedBox(height: context.getPercentHeight(2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
