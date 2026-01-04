import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../router/route_name.dart';
import '../../components/BaseField/baseTextField.dart';

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

  bool get canRegister {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    return firstName.isNotEmpty && lastName.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: context.customAppBar(title: 'Registeration', showBackButton: false),
        body: Stack(
          children: [
            context.imageContainer(
              imagePath: ImagePathConstants.space,
              height: context.getPercentHeight(100),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: context.getPercentHeight(100),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: context.getPercentWidth(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: context.getPercentWidth(20)),
                          child: context.header(
                            title: "Create Account",
                            color: Colors.cyan,
                          ),
                        ),

                        SizedBox(height: context.getPercentHeight(2)),

                        const Text(
                          "Register and track your expenses",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                          ),
                        ),

                        SizedBox(height: context.getPercentHeight(5)),

                        BaseTextField(
                          controller: _firstNameController,
                          labelText: "First name",
                          hintText: "Enter your first name",
                          onChanged: (_) => setState(() {}),
                        ),

                        SizedBox(height: context.getPercentHeight(4)),

                        BaseTextField(
                          controller: _lastNameController,
                          labelText: "Last name",
                          hintText: "Enter your last name",
                          onChanged: (_) => setState(() {}),
                        ),

                        SizedBox(height: context.getPercentHeight(19)),

                        Padding(
                          padding: EdgeInsets.only(right: context.getPercentWidth(11)),
                          child: context.navigationButton(
                            text: "Proceed",
                            canNavigate: canRegister,
                            height: 6,
                            width: 100,
                            onBtnPress: () => context.pushNamedUnAuthenticated(RouteName.email),
                          ),
                        ),

                        // SizedBox(height: context.getPercentHeight(2)),

                        // Center(
                        //   child: Padding(
                        //     padding: EdgeInsets.only(right: context.getPercentWidth(10)),
                        //     child: context.textedButton(
                        //       text: "Already have an account? Login",
                        //       onButtonPress: () => context.pushNamedUnAuthenticated(RouteName.login),
                        //     ),
                        //   ),
                        // ),

                        SizedBox(height: context.getPercentHeight(2)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
