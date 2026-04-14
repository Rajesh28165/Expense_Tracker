// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:kharchasutra/util/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../constants/app_constants.dart';
import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import '../../../router/route_name.dart';
import '../../components/baseField.dart';

class VerifySecurityQuestionPage extends StatefulWidget {
  final String purpose;
  final int count;

  const VerifySecurityQuestionPage({
    super.key,
    required this.purpose,
    required this.count,
  });

  @override
  State<VerifySecurityQuestionPage> createState() => _VerifySecurityQuestionPageState();
}

class _VerifySecurityQuestionPageState extends State<VerifySecurityQuestionPage> {

  final TextEditingController _answerController = TextEditingController();

  String _selectedQuestion = 'Select Anyone Question';
  bool _canVerify = false;

  @override
  void initState() {
    super.initState();
    _answerController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
      _selectedQuestion != 'Select Anyone Question' &&
      _answerController.text.trim().isNotEmpty;
    if (isValid != _canVerify) setState(() => _canVerify = isValid);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  int get _selectedIndex => AppConstants.listOfSecurityQuestions.indexOf(_selectedQuestion);

  Future<void> _verify() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      context.showCustomDialog(description: 'User not logged in');
      return;
    }

    context.showLoader(text: 'Verifying...');

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data == null) {
        context.hideLoader(context);
        context.showCustomDialog(description: 'User data not found');
        return;
      }

      final savedIndex  = data['securityQuestionIndex'] as int?;
      final savedHash   = data['securityAnswerHash'] as String?;
      final enteredHash = _answerController.text.trim().hashCode.toString();

      final questionMatches = savedIndex == _selectedIndex;
      final answerMatches   = savedHash == enteredHash;

      context.hideLoader(context);

      if (questionMatches && answerMatches) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.purpose == AppConstants.purposeUpdatePassword) {
            context.pushTo(RouteName.resetPassword);
          } else if (widget.purpose == AppConstants.purposeUpdateSecurityQA) {
            context.pushTo(RouteName.security);
          }
        });
      } else {
        final hintIndex  = savedIndex ?? _selectedIndex;
        final hint = hintIndex < AppConstants.listOfSecurityHints.length
          ? AppConstants.listOfSecurityHints[hintIndex]
          : null;
        final hintToShow = hint != null ? '\n\nHint: $hint' : '';
        context.showCustomDialog(
          description: 'Incorrect question or answer.$hintToShow',
        );
      }
    } catch (e) {
      context.hideLoader(context);
      context.showCustomDialog(description: e.toString());
    }
  }

  void _forgotSecurityQuestion(BuildContext context) {
    if (widget.count >= 2) {
      context.showCustomDialog(
        description: '${AppConstants.Password_reset_link_header}\n\n${AppConstants.Password_reset_link_warning}\n\n${AppConstants.Password_rule}\n\n${AppConstants.Password_note}',
        onPressed: () => CommonMethods.handleFullForgot(context),
        paddingValue: 4,
        showIcon: false,
        buttonText: 'Proceed'
      );
    } else {
      context.pushTo(
        RouteName.verifyPassword, 
        extra: {
          'purpose': widget.purpose,
          'count': widget.count + 1,
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Verify Identity'),
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
                    const Text(
                      'Select the security question you set up and provide the correct answer to verify your identity.',
                      style: TextStyle(color: AppConstants.commonTextColor),
                    ),
                    SizedBox(height: context.getPercentHeight(5)),
                    Text('Security question', style: AppStyles.labelStyle()),
                    SizedBox(height: context.getPercentHeight(1)),
                    GestureDetector(
                      onTap: () {
                        context.showSecurityQuestionPicker(
                          context,
                          AppConstants.listOfSecurityQuestions,
                          (selected) {
                            setState(() => _selectedQuestion = selected);
                            _validateForm();
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.getPercentWidth(3),
                          vertical:   context.getPercentHeight(1.5),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppConstants.commonTextColor,
                          ),
                          borderRadius: BorderRadius.circular(
                            context.getPercentWidth(3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedQuestion,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.inputTextStyle(),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppConstants.commonTextColor,
                              size: context.getPercentWidth(7.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.getPercentHeight(4)),
                    
                    
                    BaseTextField(
                      labelText: 'Security answer',
                      controller: _answerController,
                      hintText: 'Enter your security answer',
                      maxInputLength: 100,
                    ),
                    SizedBox(height: context.getPercentHeight(2)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: context.textedButton(
                        text: 'Forgot Security Question & Answer',
                        textUnderline: true,
                        onButtonPress: () =>_forgotSecurityQuestion(context),
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
                  SizedBox(height: context.getPercentHeight(1)),
                  context.navigationButton(
                    text: 'Verify',
                    canNavigate: _canVerify,
                    onBtnPress: _verify,
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