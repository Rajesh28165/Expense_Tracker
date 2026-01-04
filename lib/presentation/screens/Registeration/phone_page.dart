import 'package:expense_tracker/constants/app_constants.dart';
import 'package:expense_tracker/util/colors.dart';
import 'package:flutter/material.dart';
import '../../../router/route_name.dart';
import '../../components/allFields.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get canRegister {
    final phone = _phoneController.text.trim();
    return phone.length == 10;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // appBar: context.customAppBar(
        //   title: 'Registeration',
        //   showBackButton: false,
        // ),
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

                      // context.header(
                      //   title: "Know where your money goes",
                      // ),

                      RichText(
                        text: const TextSpan(
                          text: "Welcome to ",
                          style: TextStyle(
                            fontSize: 30,
                            color: WidgetColors.black,
                            fontFamily: AppConstants.PlayfairDisplay
                          ),
                          children: [
                            TextSpan(
                              text: AppConstants.appName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold)
                            )
                          ]
                        )
                      ),


                      SizedBox(height: context.getPercentHeight(4)),

                      const Text(
                        "Know where your money goes",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: AppConstants.OpenSans,
                          color: WidgetColors.cyanBlue,
                          fontWeight: FontWeight.w800
                        ),
                      ),

                      SizedBox(height: context.getPercentHeight(5)),

                      PhoneNumberTextField(
                        labelText: "Register your phone number",
                        controller: _phoneController,
                        onChanged: (_) => setState(() {}),
                        rightGapWidth: 0
                      ),

                    ],
                  ),
                ),
              ),

              /// -------- FIXED PROCEED BUTTON --------
              SafeArea(
                child: Column(
                  children: [
                    context.textedButton(
                      text: "Already have an account? Login",
                      onButtonPress: () => context.pushNamedUnAuthenticated(RouteName.login),
                    ),
                    SizedBox(height: context.getPercentHeight(1)),
                    context.navigationButton(
                      text: "Proceed",
                      canNavigate: canRegister,
                      height: 6,
                      width: 100,
                      onBtnPress: () => context.pushNamedUnAuthenticated(
                        RouteName.otp,
                        arguments: _phoneController.text,
                      ),
                    ),
                    SizedBox(height: context.getPercentHeight(2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
