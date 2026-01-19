import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/util/colors.dart';
import 'package:expense_tracker/util/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../data/cubit/userCubit.dart';
import '../../../router/route_name.dart';
import '../../components/BaseField/baseTextField.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

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
    _securityAnsController.addListener(_onTextChanged);
    super.initState();
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _securityAnsController.dispose();
    super.dispose();
  }


  bool get canRegister {
    bool answerSelected  = _securityAnsController.text.trim().isNotEmpty;
    bool questionSelected = selectedQuestion != 'Select Anyone Question';
    return questionSelected && answerSelected;
  }

  int get selectedQuestionIndex => AppConstants.listOfSecurityQuestions.indexOf(selectedQuestion);


  void onProceed() async {
    context.showLoader(text: 'Registering');
    final userCubit = context.read<UserCubit>();
    userCubit.setSecurityInfo(
      securityQuestionIndex: selectedQuestionIndex,
      securityAnswer: _securityAnsController.text
    );

    final userState = userCubit.state;

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userState.email!, 
        password: userState.tempPassword!
      );

      final uid = credential.user!.uid;

      userCubit.setUid(uid);

      await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
          'firstName': userState.firstName,
          'lastName': userState.lastName,
          'email': userState.email,
          'securityQuestionIndex': userState.securityQuestionIndex,
          'hashedSecurityAnswer': userState.securityAnswer,
          'createdAt': FieldValue.serverTimestamp()
        });

      userCubit.clearSensitiveData();
      context.hideLoader();      
      context.pushNamedUnAuthenticated(RouteName.dashboard);
    } catch(err) {
      context.hideLoader();   
      log.d('error while registering: $err');
      context.showCustomDialog(description: err.toString());
    }
    
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

                    const Text(AppConstants.SecurityQuestionRule),

                    SizedBox(height: context.getPercentHeight(5)),

                    Text(
                      'Security question',
                      style: AppStyles.labelStyle(),
                    ),
                    SizedBox(height: context.getPercentHeight(1)),
                    GestureDetector(
                      onTap: () {
                        context.showSecurityQuestionPicker(
                          context,
                          AppConstants.listOfSecurityQuestions,
                          (selected) {
                            setState(() {
                              selectedQuestion = selected;
                            });
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: WidgetColors.black),
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
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.getPercentHeight(5)),
                    BaseTextField(
                      labelText: "Security answer",
                      controller: _securityAnsController,
                      rightGapWidth:0,
                      hintText: "Enter security answer",
                      maxLines: 3,
                      maxInputLength: 100,
                    )
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
