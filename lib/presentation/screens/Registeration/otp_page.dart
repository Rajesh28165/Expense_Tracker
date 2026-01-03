import 'package:expense_tracker/presentation/components/codeInputField.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/presentation/widgets/generalComponents.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.customAppBar(title: 'Registeration'),
      body: Stack(
        children: [
          context.imageContainer(
            imagePath: ImagePathConstants.space,
            height: context.getPercentHeight(100),
          ),
          Column(
            children: [
              CodeInputField(
                length: 4,
              )
            ],
          )
        ],
      )
    );
  }
}