import 'package:expense_tracker/data/cubit/userCubit.dart';
import 'package:expense_tracker/util/colors.dart';
import 'package:expense_tracker/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../router/route_name.dart';
import '../../components/BaseField/baseTextField.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

import '../../components/allFields.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _pswdController = TextEditingController();
  final TextEditingController _cnfmPswdController = TextEditingController();
  final pswdRegex = RegExp(RegexConstants.PASSWORD_PATTERN);

  @override
  void initState() {
    super.initState();
    _pswdController.addListener(_onTextChanged);
    _cnfmPswdController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _pswdController.dispose();
    _cnfmPswdController.dispose();
    super.dispose();
  }

  bool get canRegister {
    final pswd = _pswdController.text.trim();
    final cnfmPswd = _cnfmPswdController.text.trim();
    return pswdRegex.hasMatch(pswd) && pswd == cnfmPswd;
  }

  String passwordError(password) {
    final value = password.trim();
    if (value!="" && value!=null) {
      if (value.length < 8){
        return 'Minimum 8 characters are required.';
      }
      if (!pswdRegex.hasMatch(value)){
        return 'Please enter valid password';
      }
      return "";
    }
    return "";
  }

  
  String cnfmPasswordError(password, confirmPassword) {
    final pswd = password.trim();
    final cnfmPswd = confirmPassword.trim();
    if (cnfmPswd!="" && cnfmPswd!=null) {
      if (pswd=="" || pswd==null || !pswdRegex.hasMatch(pswd)) {
        return "Please enter the valid password above first";
      }
      if (pswd != cnfmPswd) {
        return "The 2 entered password are not matching";
      }
      return "";
    }
    return "";
  }

  void onProceed() {
    final password = _pswdController.text.trim();
    context.read<UserCubit>().settempPassword(password);
    final storedPassword = context.read<UserCubit>().state.tempPassword;
    log.d('stored password is $storedPassword');
    context.pushNamedUnAuthenticated(RouteName.security);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Registeration'),
      body: context.gradientScreen(
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
                    SizedBox(height: context.getPercentHeight(2)),

                    const Text(AppConstants.Password_rule),

                    SizedBox(height: context.getPercentHeight(4)),

                    PasswordTextField(
                      controller: _pswdController,
                      hintText: "Enter password",
                      errorText: passwordError(_pswdController.text),
                      onChanged: (_) => setState(() {}),
                    ),
                    
                    SizedBox(height: context.getPercentHeight(4)),
                    
                    PasswordTextField(
                      controller: _cnfmPswdController,
                      labelText: "Confirm password",
                      hintText: "Re-enter password",
                      errorText: cnfmPasswordError(_pswdController.text, _cnfmPswdController.text),
                      onChanged: (_) => setState(() {}),
                    ),

                    SizedBox(height: context.getPercentHeight(5)),

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
                    canNavigate: canRegister,
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
