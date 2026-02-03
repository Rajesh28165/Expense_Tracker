// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:expense_tracker/util/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

import '../../router/route_name.dart';
import '../components/baseField.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final TextEditingController _securityAnsController = TextEditingController();
  String selectedQuestion = 'Select Anyone Question';

  @override
  void initState() {
    super.initState();
    _securityAnsController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _securityAnsController.dispose();
    super.dispose();
  }

  bool get canProceed {
    return selectedQuestion != 'Select Anyone Question' &&
        _securityAnsController.text.trim().isNotEmpty;
  }

  int get selectedQuestionIndex => AppConstants.listOfSecurityQuestions.indexOf(selectedQuestion);

  Future<void> onProceed() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    context.showCustomDialog(description: 'User not logged in');
    return;
  }

  context.showLoader(text: 'Saving security info');

  try {
    final securityAnswerHash =
        _securityAnsController.text.trim().hashCode.toString();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
          'securityQuestionIndex': selectedQuestionIndex,
          'securityAnswerHash': securityAnswerHash,
          'securityQuestionSelected': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    context.hideLoader();

    /// ✅ IMPORTANT FIX HERE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.pushNamedUnAuthenticated(
        RouteName.navigation,
      );
    });
  } catch (e) {
    context.hideLoader();
    context.showCustomDialog(description: e.toString());
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Security Setup'),
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
                      AppConstants.SecurityQuestionRule,
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
                            setState(() => selectedQuestion = selected);
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppConstants.commonTextColor,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedQuestion,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.inputTextStyle(),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppConstants.commonTextColor,
                              size: 30,
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: context.getPercentHeight(5)),

                    BaseTextField(
                      labelText: "Security answer",
                      controller: _securityAnsController,
                      hintText: "Enter security answer",
                      maxInputLength: 100,
                    ),
                  ],
                ),
              ),
            ),

            /// -------- PROCEED BUTTON --------
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: context.getPercentHeight(1)),
                  context.navigationButton(
                    text: "Proceed",
                    canNavigate: canProceed,
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
