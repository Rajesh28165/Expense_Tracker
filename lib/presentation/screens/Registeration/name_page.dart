import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../router/route_name.dart';
import '../../components/BaseField/baseTextField.dart';
import '../../components/allFields.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get canRegister {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    return name.isNotEmpty && phone.length == 10;
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
                          controller: _nameController,
                          labelText: "Name",
                          hintText: "Enter your full name",
                          onChanged: (_) => setState(() {}),
                        ),

                        SizedBox(height: context.getPercentHeight(4)),

                        PhoneNumberTextField(
                          controller: _phoneController,
                          onChanged: (_) => setState(() {}),
                        ),

                        SizedBox(height: context.getPercentHeight(5)),

                        Padding(
                          padding: EdgeInsets.only(right: context.getPercentWidth(11)),
                          child: context.navigationButton(
                            text: "Proceed",
                            canNavigate: canRegister,
                            height: 6,
                            width: 100,
                            onBtnPress: () => context.pushNamedUnAuthenticated(RouteName.otp),
                          ),
                        ),

                        SizedBox(height: context.getPercentHeight(4)),

                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: context.getPercentWidth(10)),
                            child: context.textedButton(
                              text: "Already have an account? Login",
                              onButtonPress: () => context.pushNamedUnAuthenticated(RouteName.login),
                            ),
                          ),
                        ),

                        SizedBox(height: context.getPercentHeight(5)),
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
