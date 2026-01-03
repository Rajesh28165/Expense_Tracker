import '../../util/colors.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomCheckBox extends StatefulWidget {
  final String labelText;
  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final double? fontSize;
  final Color? color;

  const CustomCheckBox({
    super.key,
    required this.labelText,
    this.initialValue = false,
    required this.onChanged,
    this.fontSize = 14,
    this.color = WidgetColors.gray_86,
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  void _toggleCheckbox() {
    setState(() {
      _isChecked = !_isChecked;
      widget.onChanged(_isChecked);
    });
  }

 @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _isChecked,
            checkColor: Colors.white,
            activeColor: WidgetColors.activeCta,
            onChanged: (_) => _toggleCheckbox(),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: GestureDetector(
            onTap: _toggleCheckbox,
            child: AutoSizeText(
              widget.labelText,
              maxLines: 4,
              minFontSize: 10,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

}
