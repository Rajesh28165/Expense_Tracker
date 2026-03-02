import 'package:flutter/material.dart';

class WidgetColors {
  static const borderBlueCard = Color(0xff0060EB);
  static const greyBorder = Color(0x70707027);
  static const greyResetPassword = Color(0xff585858);
  static const darkRed = Color(0xffAF1D28);
  static const nobel = Color(0xff9B9B9B);
  static const shadowBlack_19 = Color(0x19000000);
  static const cyanBlue = Color(0xff092D74);
  static const silver = Color(0xffBEBBBB);
  static const blue = Color(0xff2A7DBB);
  static const orange = Color.fromRGBO(226, 140, 11, 1);
  static const radicalRed = Color(0xffFF4856);
  static const darkPink = Color(0xffBB0439);
  static const dimGray = Color(0xff626262);
  static const whiteSmoke = Color(0xffF4F4F4);
  static const geminiGray = Color(0xff707070);
  static const grey = Color(0xff888888);
  static const gray_86 = Color(0xff868686);
  static const gray_91 = Color(0xffE8E8E8);
  static const gray_93 = Color(0xffEDEDED);
  static const gray_94 = Color(0xfff0f0f0);
  static const red = Color(0xffB42826);
  static const textBlack = Color(0xff2F2F2F);
  static const white = Color(0xffffffff);
  static const black = Color(0xff000000);
  static const activeCta = Color(0xff08B578);
  static const checkBoxTextColor = Color(0xff484848);
  static const ellipseActive = Color(0x00000000);
  static const ellipseDeactive = Color(0x00a0a0a0);
  static const greyCurrentPhoneNumberText = Color(0xff918E8E);
  static const greyDisabledTextColor = Color(0xff9a9a9a);
  static const greyShadow = Color(0x00000019);


  //rediness card colors
  static const greenColorCard = Color(0xff64b472);
  static const redColorCard = Color(0xffC76B6B);
  static const blueGradientColor = Color(0xff092C74);
  static const boxGradientColor = Color(0X00000029);
}

class CategoryColorHelper {
  static Color getColor(String category) {
    switch (category.toLowerCase()) {

      /// ===== EXPENSE COLORS =====
      case 'food':
        return WidgetColors.orange;

      case 'transport':
        return WidgetColors.blue;

      case 'shopping':
        return WidgetColors.darkPink;

      case 'entertainment':
        return WidgetColors.radicalRed;

      case 'bills':
        return WidgetColors.borderBlueCard;

      case 'health':
        return WidgetColors.greenColorCard;

      /// ===== INCOME COLORS =====

      case 'salary':
        return Colors.green.shade600;

      case 'freelance':
        return Colors.teal;

      case 'business':
        return Colors.indigo;

      case 'investment':
        return Colors.deepPurple;

      case 'gift':
        return Colors.pink;

      case 'bonus':
        return Colors.amber.shade700;

      /// ===== COMMON =====
      case 'other':
      default:
        return WidgetColors.grey;
    }
  }
}

