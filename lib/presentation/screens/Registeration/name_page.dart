import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_constants.dart';
import '../../../data/cubit/userCubit.dart';
import '../../../router/route_name.dart';
import '../../../util/colors.dart';
import '../../components/BaseField/baseTextField.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_onTextChanged);
    _lastNameController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool get canNavigate {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    return firstName.isNotEmpty && lastName.isNotEmpty;
  }

  void onProceed() {
    context.read<UserCubit>().setName(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
    context.pushNamedUnAuthenticated(RouteName.email);
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

                    SizedBox(height: context.getPercentHeight(1)),

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

                    SizedBox(height: context.getPercentHeight(4)),

                    BaseTextField(
                      controller: _firstNameController,
                      labelText: "First name",
                      hintText: "Enter your first name",
                      onChanged: (_) => setState(() {}),
                      rightGapWidth: 0
                    ),

                    SizedBox(height: context.getPercentHeight(4)),

                    BaseTextField(
                      controller: _lastNameController,
                      labelText: "Last name",
                      hintText: "Enter your last name",
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
