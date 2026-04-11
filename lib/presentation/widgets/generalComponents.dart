// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kharchasutra/constants/extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../router/route_name.dart';
import '../../util/colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

// Components:
// 1) Gradient
// 2) AppBar
// 3) Dropdown
// 4) Dialog Box
// 5) Show/Hide Loader
// 6) Navigation Button
// 7) Texted Button

extension GeneralComponents on BuildContext {

  // ------------------ General Gradient ------------------
  Widget gradientScreen({
    required Widget child,
    List<Color>? colors,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
    bool safeArea = true,
  }) {
    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ?? [Colors.black, Colors.black87, Colors.blue.shade400],
        ),
      ),
      child: content,
    );
  }


  // ------------------ AppBar ------------------
  PreferredSizeWidget customAppBar({
    required String title,
    double fontSize = 22,
    Color backgroundColor = WidgetColors.surface,
    Color titleColor = WidgetColors.ink,
    bool showBackButton = true,
    Color arrowColor = WidgetColors.ink,
    VoidCallback? onBackPressed,
    Widget? rightWidget,
    List<Widget>? actions,
  }) {
    final double appBarHeight   = getPercentHeight(8);    
    final double hPadding       = getPercentWidth(5);   
    final double vPadding       = getPercentHeight(1.3);
    final double btnSize        = getPercentWidth(9.5); 
    final double btnRadius      = getPercentWidth(2.8); 
    final double iconSize       = getPercentWidth(4);   

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: Container(
        color: backgroundColor,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: hPadding,
              vertical: vPadding,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back button — left
                if (showBackButton)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: onBackPressed ?? () => Navigator.of(this).pop(),
                      child: Container(
                        width: btnSize,
                        height: btnSize,
                        decoration: BoxDecoration(
                          color: WidgetColors.page,
                          borderRadius: BorderRadius.circular(btnRadius),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: iconSize,
                          color: arrowColor,
                        ),
                      ),
                    ),
                  ),

                // Centered title
                Center(
                  child: Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Right widget (avatar, badge, icon, etc.)
                if (rightWidget != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: rightWidget,
                  )
                else if (actions != null && actions.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ------------------ Dropdown ------------------
  Widget customDropdown<T>({
    required List<T> menuItems,
    T? value,
    String? labelText,
    String? hintText,
    TextStyle? labelStyle,
    double? borderRadius,
    ValueChanged<T?>? onChanged,
    String Function(T item)? itemLabelBuilder,
    IconData? prefixIcon,
    Color? accentColor,
  }) {
    final Color accent = accentColor ?? WidgetColors.indigo500;
    final double radius = borderRadius ?? getPercentWidth(3.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (labelText != null && labelText.isNotEmpty) ...[
          Text(
            labelText,
            style: labelStyle ??
                GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: WidgetColors.ink2,
                  letterSpacing: 0.1,
                ),
          ),
          SizedBox(height: getPercentHeight(1)),
        ],

        // Dropdown
        Container(
          decoration: BoxDecoration(
            color: WidgetColors.surface,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonFormField2<T>(
            value: value,
            isExpanded: true,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: WidgetColors.ink,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: getPercentWidth(4),
                vertical: getPercentHeight(1.8),
              ),
              filled: true,
              fillColor: Colors.transparent,
              prefixIcon: prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(
                      left: getPercentWidth(3),
                      right: getPercentWidth(1),
                    ),
                    child: Icon(prefixIcon, color: accent, size: getPercentWidth(5)),
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide.none,
              ),
            ),
            hint: hintText != null
              ? Text(
                  hintText,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: WidgetColors.ink3,
                  ),
                )
              : null,
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: WidgetColors.surface,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              offset: const Offset(0, -4),
            ),
            iconStyleData: IconStyleData(
              icon: Container(
                margin: EdgeInsets.only(right: getPercentWidth(3)),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: WidgetColors.ink3,
                  size: getPercentWidth(6),
                ),
              ),
            ),
            items: menuItems.map<DropdownMenuItem<T>>((item) {
              final label = itemLabelBuilder != null
                  ? itemLabelBuilder(item)
                  : item.toString();
              final bool isSelected = item == value;
              return DropdownMenuItem<T>(
                value: item,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getPercentWidth(2),
                    vertical: getPercentHeight(0.5),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(getPercentWidth(2)),
                  ),
                  child: Row(
                    children: [
                      if (isSelected) ...[
                        Container(
                          width: getPercentWidth(1.5),
                          height: getPercentWidth(1.5),
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: getPercentWidth(2)),
                      ],
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? accent : WidgetColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }


  void showSecurityQuestionPicker(
    BuildContext context,
    List<String> items,
    ValueChanged<String> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ...items.map(
                    (item) => ListTile(
                      title: Text(item),
                      onTap: () {
                        Navigator.pop(context);
                        onSelect(item);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------ Dialog Box ------------------
  Future<void> showCustomDialog({
    String? title,
    required String description,
    String? buttonText,
    VoidCallback? onPressed,
    IconData? icon,
    Color? iconColor,
    double paddingValue = 6,
    bool showIcon = true
  }) {
    return showDialog(
      context: this,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(getPercentWidth(5)),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(getPercentWidth(paddingValue)),
            decoration: BoxDecoration(
              color: WidgetColors.surface,
              borderRadius: BorderRadius.circular(getPercentWidth(5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                if (showIcon)
                  Container(
                    width: getPercentWidth(14),
                    height: getPercentWidth(14),
                    decoration: BoxDecoration(
                      color: (iconColor ?? WidgetColors.indigo500).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ?? Icons.info_outline_rounded,
                      color: iconColor ?? WidgetColors.indigo500,
                      size: getPercentWidth(7),
                    ),
                  ),
                SizedBox(height: getPercentHeight(2)),

                // Title
                if (title != null && title.isNotEmpty) ...[
                  Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: WidgetColors.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getPercentHeight(1)),
                ],

                // Description
                Text(
                  description,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: WidgetColors.ink2,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: getPercentHeight(3)),

                dialogContext.navigationButton(
                  text: buttonText ?? 'OK',
                  canNavigate: true,
                  aboveSpace: 0,
                  belowSpace: 0,
                  onBtnPress: () {
                    Navigator.of(dialogContext).pop();
                    onPressed?.call();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------ Show Loader ------------------
  void showLoader({String? text}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                text ?? "Loading...",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )
              )
            ]
          )
        )
      )
    );
  }

  // ------------------ Hide Loader ------------------
  void hideLoader(BuildContext context) {
    context.back();
  }

  // ------------------ Navigation Button ------------------
  Widget navigationButton({
    required String text,
    TextStyle? textStyle,
    VoidCallback? onBtnPress,
    double? height,
    double? width,
    double? aboveSpace,
    double? belowSpace,
    double? leftSpace,
    double? rightSpace,
    double? fontSize,
    Color? activeBgColor,
    Color? deActiveBgColor,
    Color? activeTextColor,
    Color? deActiveTextColor,
    Color? borderColor,
    Color? foregroundColor,
    FontWeight? fontWeight,
    bool canNavigate = false,
    Widget? iconWidget,
  }) {
    final Color bgColor   = canNavigate
        ? activeBgColor   ?? WidgetColors.darkCard
        : deActiveBgColor ?? WidgetColors.ink3;
    final Color textColor = canNavigate
        ? activeTextColor   ?? Colors.white
        : deActiveTextColor ?? Colors.black;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        getPercentWidth(leftSpace ?? 1),
        getPercentHeight(aboveSpace ?? 1),
        getPercentWidth(rightSpace ?? 1),
        getPercentHeight(belowSpace ?? 1),
      ),
      child: GestureDetector(
        onTap: canNavigate ? onBtnPress : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: width != null ? getPercentWidth(width) : double.infinity,
          padding: EdgeInsets.symmetric(vertical: getPercentHeight(height ?? 2)),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(getPercentWidth(4)),
            border: borderColor != null
              ? Border.all(color: borderColor)
              : null,
            boxShadow: canNavigate
              ? [
                  BoxShadow(
                    color: (activeBgColor ?? WidgetColors.darkCard).withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconWidget != null) ...[
                iconWidget,
                SizedBox(width: getPercentWidth(2.5)),
              ],
              Text(
                text,
                style: textStyle ??
                  GoogleFonts.sora(
                    fontSize: fontSize ?? 16,
                    fontWeight: fontWeight ?? FontWeight.w700,
                    color: textColor,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ------------------ Texted Button ------------------
  Widget textedButton({
    required String text,
    TextStyle? textStyle,
    VoidCallback? onButtonPress,
    double? fontSize,
    double? textHeight,
    double? aboveSpace,
    double? belowSpace,
    Color? textColor,
    FontWeight? fontWeight,
    bool textUnderline = false,
    double? leftPadding,
    double? rightPadding,
    double? topPadding,
    double? bottomPadding,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: getPercentWidth(leftPadding ?? 0),
        right: getPercentWidth(rightPadding ?? 0),
        top: getPercentHeight(topPadding ?? 0),
        bottom: getPercentHeight(bottomPadding ?? 0),
      ),
      child: Column(
        children: [
          SizedBox(height: getPercentHeight(aboveSpace ?? 1)),
          GestureDetector(
            onTap: onButtonPress,
            behavior: HitTestBehavior.translucent,
            child: Text(
              text,
              style: textStyle ??
                TextStyle(
                  fontSize: fontSize ?? 14,
                  fontWeight: fontWeight ?? FontWeight.w400,
                  height: textHeight,
                  color: textColor ?? WidgetColors.white,
                  decoration: textUnderline ? TextDecoration.underline : TextDecoration.none,
                ),
            ),
          ),
        ],
      ),
    );
  }

}

class CommonMethods {

  static Future<void> handleFullForgot(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    context.showLoader(text: 'Please wait...');

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'securityQuestionSelected': false});

      context.hideLoader(context);

      context.showCustomDialog(
        description: 'A password reset email has been sent to ${user.email}.\n\nPlease check your inbox and spam folder.\n\nAfter resetting your password, log in again to set up your security question.',
        onPressed: () async {
          Navigator.of(context).pop();
          await context.read<AuthCubit>().logout();
          context.goTo(RouteName.login);
        },
      );
    } catch (e) {
      context.hideLoader(context);
      context.showCustomDialog(description: e.toString());
    }
  }

  static void showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.dmSans(color: WidgetColors.ink2),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await context.read<AuthCubit>().logout();
                  context.goTo(RouteName.login);
                },
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.dmSans(
                    color: WidgetColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}