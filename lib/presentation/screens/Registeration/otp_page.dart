import 'package:expense_tracker/presentation/widgets/countDownTimer.dart';
import 'package:expense_tracker/router/route_name.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

class OtpPage extends StatefulWidget {
  final String mobNumber;
  const OtpPage({
    required this.mobNumber,
    super.key
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool resendCode = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Widget resendOtp() {
    if (resendCode) {
      return context.textedButton(
        text: 'Resend Code',
        textStyle: const TextStyle(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline
        ),
        onButtonPress: () {
          setState(() => resendCode = false);
        } 
      );
    }
    return  CountdownTimer(
      timerInSeconds: 5,
      startingText: "You can request code after ",
      onTimerComplete: () => setState(() {
        resendCode = true;
      }),
    );
  }

  bool get otpValidated {
    return _otpController.text.length == 6;
  }

  void onProceed() {
    context.pushNamedUnAuthenticated(RouteName.name);
  }

  String phoneNumber(){
    final phone = widget.mobNumber.trim();
    final start = phone.substring(0, 4);
    final mid = phone.substring(4,7);
    final end = phone.substring(7);
    return '(+91) $start $mid $end';
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: context.customAppBar(title: 'Registration'),
  //     body: context.gradientScreen(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           SizedBox(height: context.getPercentHeight(4)),
  //           Center(child: context.header(title: 'Verification')),
  //           SizedBox(height: context.getPercentHeight(4)),
  //           const Text('Enter 6 digits verification code sent to your number'),
  //           SizedBox(height: context.getPercentHeight(1)),
  //           Center(
  //             child: Text(
  //               phoneNumber(), 
  //               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
  //             )
  //           ),
  //           SizedBox(height: context.getPercentHeight(4)),
  //           Center(
  //             child: Column(
  //               children: [
  //                 context.OtpField(
  //                   context: context, 
  //                   otpController: _otpController, 
  //                   otpLength: 6
  //                 ),
  //                 SizedBox(height: context.getPercentHeight(2)),
  //                 resendOtp(),
                  
  //               ],
  //             )
  //           ),

  //           SizedBox(height: context.getPercentHeight(40)),
  //           context.navigationButton(
  //             text: 'Proceed',
  //             canNavigate: otpValidated,
  //             onBtnPress: onProceed,
  //           )
            
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: context.customAppBar(title: 'Registration'),
    body: context.gradientScreen(
      child: Column(
        children: [
          /// ----------- SCROLLABLE CONTENT -----------
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.getPercentHeight(4)),

                  Center(child: context.header(title: 'Verification')),

                  SizedBox(height: context.getPercentHeight(4)),

                  const Text(
                    'Enter 6 digits verification code sent to your number',
                  ),

                  SizedBox(height: context.getPercentHeight(1)),

                  Center(
                    child: Text(
                      phoneNumber(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: context.getPercentHeight(4)),

                  Center(
                    child: Column(
                      children: [
                        context.OtpField(
                          context: context,
                          otpController: _otpController,
                          otpLength: 6,
                        ),

                        SizedBox(height: context.getPercentHeight(2)),

                        resendOtp(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ----------- FIXED PROCEED BUTTON -----------
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.getPercentWidth(6),
                vertical: context.getPercentHeight(2),
              ),
              child: context.navigationButton(
                text: 'Proceed',
                canNavigate: otpValidated,
                onBtnPress: onProceed,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
