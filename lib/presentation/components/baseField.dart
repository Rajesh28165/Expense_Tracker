import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_constants.dart';
import '../../constants/extension.dart';
import '../../util/styles.dart';

class BaseTextField extends StatefulWidget {
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

  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;

  final Color? cursorColor;
  final EdgeInsetsGeometry? contentPadding;
  final AutovalidateMode autovalidateMode;

  final IconData? icon;

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
    this.icon,
    this.contentPadding,
    this.cursorColor,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.isEnabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.obscuringCharacter = '*',
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<BaseTextField> createState() => _BaseTextFieldState();
}


class _BaseTextFieldState extends State<BaseTextField> {
  late bool _isObscured;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _toggleObscureText() {
    setState(() => _isObscured = !_isObscured);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: widget.labelStyle ?? AppStyles.labelStyle(),
          ),
          SizedBox(height: context.getPercentHeight(0)),
        ],
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          enabled: widget.isEnabled,
          autofocus: widget.autofocus,
          cursorColor: widget.cursorColor ?? Colors.cyanAccent,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxInputLength,
          obscureText: widget.obscureText ? _isObscured : false,
          obscuringCharacter: widget.obscuringCharacter,
          style: widget.inputTextStyle ?? AppStyles.inputTextStyle(),
          autovalidateMode: widget.autovalidateMode,
          validator: (value) {
            if (widget.errorText != null && widget.errorText!.isNotEmpty) {
              return widget.errorText;
            }
            return widget.validator?.call(value) ?? _defaultValidator(value);
          },
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters ??
            [
              FilteringTextInputFormatter.allow(
                RegExp(widget.allowedExpression ?? RegexConstants.ANY_CHARACTER),
              ),
              if (widget.deniedExpression != null)
                FilteringTextInputFormatter.deny(RegExp(widget.deniedExpression!)),
              if (widget.maxInputLength != null)
                LengthLimitingTextInputFormatter(widget.maxInputLength),
            ],
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Enter details',
            hintStyle: widget.hintStyle ?? AppStyles.hintStyle(),
            errorStyle: widget.errorStyle ?? AppStyles.errorStyle(),

            suffixIcon: widget.icon == null
              ? null
              : IconButton(
                  icon: Center(
                    child: Icon(
                      widget.obscureText
                          ? (_isObscured
                              ? Icons.visibility
                              : Icons.visibility_off)
                          : widget.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: widget.obscureText ? _toggleObscureText : null,
                ),

            suffixIconConstraints: const BoxConstraints(
              minHeight: 20,
              minWidth: 20,
              maxHeight: 30,
              maxWidth: 30,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 0,
            ),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent, width: 1.5)),
            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            counterText: '',
          ),
        ),
      ],
    );
  }

  static String? _defaultValidator(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }
}
