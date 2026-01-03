import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:expense_tracker/util/styles.dart';

class CodeInputController {
  final int length;
  final List<FocusNode> focusNodes;
  final List<TextEditingController> textControllers;
  final List<String> pin;

  CodeInputController(this.length) : 
    focusNodes = List.generate(length, (_) => FocusNode()),
    textControllers = List.generate(length, (_) => TextEditingController()),
    pin = List.generate(length, (_) => '');

  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    for (var controller in textControllers) {
      controller.dispose();
    }
  }

  void setInitialValue(String? value) {
    if (value == null || value.length != length) return;
    for (int i = 0; i < length; i++) {
      textControllers[i].text = value[i];
      pin[i] = value[i];
    }
  }

  String getPin() => pin.join();

  void updatePinAt(int index, String value) {
    pin[index] = value;
  }

  void handlePaste(String str) {
    str = str.substring(0, str.length > length ? length : str.length);
    for (int i = 0; i < str.length; i++) {
      textControllers[i].text = str[i];
      pin[i] = str[i];
    }
  }

  void handleChange({
    required BuildContext context,
    required int index,
    required String str,
    required VoidCallback onUpdateUI,
  }) {
    if (str.length > 1) {
      handlePaste(str);
      onUpdateUI();
      return;
    }

    updatePinAt(index, str);
    onUpdateUI();

    // Handle backspace
    if (str.isEmpty && index > 0) {
      focusNodes[index].unfocus();
      focusNodes[index - 1].requestFocus();
      textControllers[index - 1].selection = TextSelection.collapsed(
        offset: textControllers[index - 1].text.length,
      );
    } else if (str.isNotEmpty && index + 1 < length) {
      // Move focus to next field automatically
      focusNodes[index + 1].requestFocus();
      textControllers[index + 1].selection = TextSelection.collapsed(
        offset: textControllers[index + 1].text.length,
      );
    } else if (index + 1 == length) {
      // Last field: unfocus keyboard
      FocusScope.of(context).unfocus();
    }
  }
}

// ------------------------------------------------------------------------------------------------------------------------------------------

class CodeInputField extends StatefulWidget {
  final int length;
  final void Function(String)? onChanged;
  final String? labelText, textHint, errorText;
  final TextStyle? labelStyle, inputStyle, errorStyle;
  final bool textHidden;
  final double? fieldHeight, perFieldWidth;
  final double? verticalTextGap, digitSpacing;
  final TextInputType? keyboardType;
  final String? value;
  final Widget? suffixWidget;

  const CodeInputField({
    Key? key,
    this.length = 4,
    this.onChanged,
    this.labelText,
    this.textHint,
    this.labelStyle,
    this.inputStyle,
    this.errorStyle,
    this.textHidden = false,
    this.fieldHeight,
    this.perFieldWidth,
    this.verticalTextGap,
    this.digitSpacing,
    this.keyboardType,
    this.value,
    this.errorText,
    this.suffixWidget,
  }) : super(key: key);

  @override
  State<CodeInputField> createState() => _CodeInputFieldState();
}

class _CodeInputFieldState extends State<CodeInputField> {
  late CodeInputController _controller;
  int get reqLength => widget.length;

  double heightPer(double height) => context.getPercentHeight(height) * 0.01;
  double widthPer(double width) => context.getPercentWidth(width) * 0.01;

  @override
  void initState() {
    super.initState();
    _controller = CodeInputController(reqLength);
    _controller.setInitialValue(widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFieldChange(String str, int index) {
    _controller.handleChange(
      context: context,
      index: index,
      str: str,
      onUpdateUI: () => setState(() {}),
    );
    widget.onChanged?.call( _controller.getPin());
  }

  Widget _buildLabel() {
    if ((widget.labelText ?? '').isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.labelText ?? '',
          style: widget.labelStyle ?? _labelStyle(),
        ),
        if (widget.suffixWidget != null) ...[
          const SizedBox(width: 4),
          widget.suffixWidget!,
        ]
      ],
    );
  }

  Widget _buildTextField(int index) {
    return Container(
      width: (context.getWidth()*0.25)/4,
      margin: EdgeInsets.only(right: widget.digitSpacing ?? 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 3)),
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controller.textControllers[index].text.isEmpty) {
            if (index > 0) {
              _controller.focusNodes[index].unfocus();
              _controller.focusNodes[index - 1].requestFocus();
              _controller.textControllers[index - 1].selection = TextSelection.collapsed(
                    offset:_controller.textControllers[index - 1].text.length
                  );
            }
            setState(() {});
            widget.onChanged?.call(_controller.getPin());
          }
        },
        child: TextField(
          controller: _controller.textControllers[index],
          autofocus: true,
          keyboardType: widget.keyboardType ?? TextInputType.number,
          textAlign: TextAlign.center,
          style: widget.inputStyle ?? _inputStyle(),
          focusNode: _controller.focusNodes[index],
          obscureText: widget.textHidden,
          obscuringCharacter: '*',
          cursorColor: Colors.black,
          maxLength: 1,
          decoration: const InputDecoration(
            isDense: true,
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (str) => _handleFieldChange(str, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        SizedBox(height: context.getHeight()*0.025,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(reqLength, (i) => _buildTextField(i)),
        ),
        if ((widget.errorText ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              widget.errorText!,
              style: widget.errorStyle ?? _errorStyle(),
            ),
          ),
      ],
    );
  }


  TextStyle _inputStyle() => AppStyles.inputTextStyle();

  TextStyle _labelStyle() => AppStyles.labelStyle();

  TextStyle _errorStyle() => AppStyles.errorStyle();

}
