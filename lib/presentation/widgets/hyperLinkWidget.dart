import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_constants.dart';

class HyperLinkWidget extends StatelessWidget {
  final String textKey;
  final String textValue;
  final String? urlLink;
  final TextStyle? keyStyle;
  final TextStyle? valueStyle;

  const HyperLinkWidget(
    this.textKey,
    this.textValue, {
    this.urlLink,
    this.keyStyle,
    this.valueStyle,
    super.key,
  });

  TextStyle get _keyStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color.fromARGB(255, 68, 64, 64),
      );

  TextStyle get _valueStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      );

  Future<void> _launchUrl(String value) async {
    Uri uri;

    if (value.startsWith("http")) {
      uri = Uri.parse(value); // Website
    } else if (value.contains("@")) {
      uri = Uri(scheme: "mailto", path: value); // Email
    } else if (RegExp(RegexConstants.PHONE_NUMBER_PATTERN).hasMatch(value)) {
      String cleanedNumber = value.replaceAll(RegExp(r'\s+|-'), '');
      uri = Uri(scheme: "tel", path: cleanedNumber); // Phone
    } else {
      uri = Uri.parse(value);
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $uri");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isClickable = urlLink != null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.getPercentHeight(2),
        vertical: context.getPercentHeight(1),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$textKey:  ",
                style: keyStyle ?? _keyStyle,
              ),
              TextSpan(
                text: textValue,
                style: isClickable
                    ? (valueStyle ??
                        _valueStyle.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ))
                    : (valueStyle ?? _valueStyle),
                recognizer: isClickable
                    ? (TapGestureRecognizer()
                      ..onTap = () => _launchUrl(urlLink!))
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
