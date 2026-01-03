import 'package:flutter/material.dart';
import 'colors.dart';

class CustomTextStyle extends TextStyle {
  final Color color;
  final FontWeight fontWeight;
  final double? fontSize;
  final String fontFamily;
  final FontStyle fontStyle;
  final double letterSpacing;

  const CustomTextStyle(
    {this.fontSize,
    this.color = WidgetColors.black,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = 'Montserrat',
    this.fontStyle = FontStyle.normal,
    this.letterSpacing = 0.0})
    : super(
          color: color,
          fontWeight: fontWeight,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          );
}


class AppStyles {

  static TextStyle inputTextStyle() {
    return const CustomTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w900,
      color: Colors.black,
    );
  }

  static TextStyle labelStyle() {
    return const CustomTextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w900,
      color: Colors.white
    );
  }

  static TextStyle hintStyle() {
    return const CustomTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.grey
    );
  }
 
  static TextStyle errorStyle() {
    return const CustomTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      color: Colors.red
    );
  }

  static TextStyle headerStyle() {
    return const CustomTextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w900,
      color: Colors.black
    );
  }

  static TextStyle subHeaderStyle() {
    return const CustomTextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: Colors.black
    );
  }

}