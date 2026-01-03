import 'package:expense_tracker/constants/entension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_constants.dart';
import 'BaseField/baseTextField.dart';

// All Fields
// 1) Email Text Field
// 2) Phone Number Field
// 3) Password Field

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText, hintText, errorText;
  final TextStyle? labelStyle, hintStyle, errorStyle;
  final String? allowedExpression, deniedExpression;
  final int? maxInputLength;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final bool? obscureText;
  final bool? autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;

  const EmailTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.validator,
    this.inputFormatters,
    this.contentPadding,
    this.obscureText,
    this.autofocus,
    this.onChanged,
    this.allowedExpression,
    this.deniedExpression,
    this.maxInputLength
  });

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      labelText: labelText ?? "E-mail Id",
      hintText: hintText ?? "Please enter your e-mail",
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      errorStyle: errorStyle,
      validator: validator ?? validateEmail,
      controller: controller,
      obscureText: obscureText ?? false,
      errorText: null,
      onChanged: onChanged,
      autofocus: autofocus ?? false,
      keyboardType: TextInputType.emailAddress,
      deniedExpression: RegexConstants.FORWARD_BACKWARD_SLASH,
      maxInputLength: 50,
    );
  }

  String? validateEmail(String? value) {
    final regex = RegExp(RegexConstants.EMAIL_ADDRESS_PATTERN);    
    final trimmedValue = value?.trim();
    final error = errorText?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) {
      return 'Please enter your e-mail';
    } else if (!regex.hasMatch(trimmedValue)) {
      return 'Please enter a valid e-mail address';
    } else if(error != null && error.isNotEmpty) {
      return error;
    }
    return null;
  }
}


// ---------------------------------------------------------------------------------------------------------------------------------

class PhoneNumberTextField extends StatelessWidget {
  final String? labelText, hintText;
  final int? maxInputLength;
  final bool? autofocus;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  const PhoneNumberTextField({
    super.key,
    required this.controller,
    this.labelText, 
    this.hintText,
    this.autofocus,
    this.validator,
    this.onChanged,
    this.maxInputLength,
    this.keyboardType, 
  });

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      controller: controller,
      labelText: labelText ?? 'Phone Number',
      hintText: hintText ?? 'Enter your phone number',
      autofocus: autofocus ?? false,
      keyboardType: keyboardType ?? TextInputType.number,
      maxInputLength: maxInputLength ?? 10,
      validator: validator ?? _validatePhoneNumber,
      allowedExpression: RegexConstants.DIGIT,
    );
  }

  // ================= VALIDATION =================

  static String? _validatePhoneNumber(String? value) {
    final digits = value
        ?.replaceAll(RegExp(RegexConstants.NON_NUMERIC), '');

    if (digits == null || digits.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }

    if (digits.startsWith('0')) {
      return 'Phone number cannot start with 0';
    }

    return null;
  }
}



// ---------------------------------------------------------------------------------------------------------------------------------


class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? errorText, labelText, hintText;
  final TextStyle? errorStyle, labelStyle, hintStyle;
  final String? allowedExpression, deniedExpression;
  final int? maxInputLength;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText, isEnabled, autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffixIcon;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.obscureText,
    this.onChanged,
    this.errorText = "",
    this.labelText,
    this.hintText,
    this.errorStyle,
    this.labelStyle,
    this.hintStyle,
    this.validator,
    this.inputFormatters,
    this.isEnabled,
    this.contentPadding,
    this.suffixIcon,
    this.autofocus,
    this.allowedExpression,
    this.deniedExpression,
    this.maxInputLength,
  });

  String? _validatePassword(String? value) {
    final RegExp regex = RegExp(RegexConstants.PASSWORD_PATTERN);
    final trimmedValue = value?.trim();

    if (errorText != "") {
      return errorText;
    }
    if (trimmedValue == null || trimmedValue.isEmpty) {
      return '';
    } else if (!regex.hasMatch(trimmedValue)) {
      return ErrorMsg.pswdError;
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      labelText: labelText ?? "Password",
      hintText: hintText ?? "Enter your password",
      errorText: errorText,
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      errorStyle: errorStyle,
      validator: validator ?? _validatePassword,
      autofocus: autofocus ?? false,
      controller: controller,
      onChanged: onChanged,
      maxInputLength: maxInputLength,
      obscureText: obscureText ?? true,
      keyboardType: TextInputType.text,
      isEnabled: isEnabled ?? true,
      inputFormatters: inputFormatters,
      suffixIcon: suffixIcon,
    );
  }
}

