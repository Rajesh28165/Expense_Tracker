import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants/app_constants.dart';
import '../../../constants/entension.dart';
import '../../../util/styles.dart';
import 'baseTextFieldCubit.dart';

class BaseTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? errorText;

  final TextStyle? inputTextStyle;
  final FormFieldValidator<String>? validator;
  final int? maxInputLength;

  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;

  final bool isEnabled;
  final bool obscureText;
  final bool autofocus;

  final String obscuringCharacter;

  final String? allowedExpression;
  final String? deniedExpression;

  final int maxLines;
  final double rightGapWidth;

  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  final Color? fillColor;
  final Color? cursorColor;

  final EdgeInsetsGeometry? contentPadding;
  final AutovalidateMode autovalidateMode;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const BaseTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.errorText,
    this.inputTextStyle,
    this.validator,
    this.maxInputLength,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.allowedExpression,
    this.deniedExpression,
    this.inputFormatters,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.fillColor,
    this.cursorColor,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.maxLines = 1,
    this.rightGapWidth = 10,
    this.keyboardType = TextInputType.text,
    this.isEnabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.obscuringCharacter = '*',
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BaseTextFieldCubit(
        initialObscureText: obscureText,
      ),
      child: Padding(
        padding: EdgeInsets.only(right: context.getPercentWidth(rightGapWidth)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (labelText != null) ...[
              Text(
                labelText!,
                style: labelStyle ?? AppStyles.labelStyle(),
              ),
              SizedBox(height: context.getPercentHeight(1)),
            ],
            BlocBuilder<BaseTextFieldCubit, bool>(
              builder: (context, isObscured) {
                final cubit = context.read<BaseTextFieldCubit>();

                return TextFormField(
                  controller: controller ?? cubit.controller,
                  focusNode: focusNode,
                  enabled: isEnabled,
                  
                  autofocus: autofocus,
                  cursorColor: cursorColor ?? Colors.black,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  maxLength: maxInputLength,
                  obscureText: obscureText ? isObscured : false,
                  obscuringCharacter: obscuringCharacter,
                  style: inputTextStyle ?? AppStyles.inputTextStyle(),
                  autovalidateMode: autovalidateMode,
                  validator: validator ?? BaseTextFieldCubit.defaultValidator,
                  onTap: onTap,
                  onChanged: onChanged,
                  inputFormatters: inputFormatters ??
                    [
                      FilteringTextInputFormatter.allow(
                        RegExp(allowedExpression ?? RegexConstants.ANY_CHARACTER),
                      ),
                      if (deniedExpression != null)
                        FilteringTextInputFormatter.deny(RegExp(deniedExpression!)),
                      if (maxInputLength != null)
                        LengthLimitingTextInputFormatter( maxInputLength),
                    ],
                  decoration: InputDecoration(
                    hintText: hintText ?? 'Enter details',
                    hintStyle: hintStyle ?? AppStyles.hintStyle(),
                    errorText: errorText,
                    errorStyle: errorStyle ?? AppStyles.errorStyle(),
                    prefixIcon: prefixIcon,
                    suffixIcon: suffixIcon ??
                      (obscureText
                        ? IconButton(
                            icon: Icon(
                              isObscured ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black54,
                            ),
                            onPressed: cubit.toggleObscureText,
                          )
                        : null),
                    filled: true,
                    fillColor: fillColor ?? const Color(0xFFF5F5F5),
                    isDense: true,
                    contentPadding: contentPadding ?? const EdgeInsets.symmetric( horizontal: 14, vertical: 16),
                    enabledBorder: _border(Colors.grey),
                    focusedBorder: _border(Colors.black, width: 1.5),
                    errorBorder: _border(Colors.black),
                    focusedErrorBorder:_border(Colors.black, width: 1.5),
                    counterText: '',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
