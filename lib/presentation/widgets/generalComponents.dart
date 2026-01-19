// ignore_for_file: non_constant_identifier_names

import 'package:expense_tracker/constants/app_constants.dart';
import 'package:expense_tracker/constants/entension.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../util/colors.dart';
import '../../util/styles.dart';
import 'countDownTimer.dart';

// Components:
// 1) Gradient
// 2) AppBar
// 3) Header
// 4) Home Bottom Bar
// 5) Dropdown
// 6) Radio Button
// 7) Image Container
// 8) Shadow Box
// 9) Acknowlwdgement Screen
// 10) Dialog Box
// 11) Show/Hide Loader
// 12) Navigation Button
// 13) Texted Button

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
          colors: colors ??
          const [
            Color(0xFFF5F7FA),
            Color(0xFFE4E7EB),
            Color(0xFFCBD2D9),
          ]        
        ),
      ),
      child: content,
    );
  }

  // ------------------ AppBar ------------------
  PreferredSizeWidget customAppBar({
    required String title,
    TextStyle? titleTextStyle,
    Color? backgroundColor,
    bool centerTitle = true,
    List<Widget>? actions,
    Widget? leading,
    double? height,
    double elevation = 0,
    bool showBackButton = true,
  }) {
    final double resolvedHeight = getPercentHeight(height ?? 6);

    return PreferredSize(
      preferredSize: Size.fromHeight(resolvedHeight),
      child: AppBar(
        backgroundColor: backgroundColor ?? WidgetColors.greenColorCard,
        title: Text(
          title,
          style: titleTextStyle ?? const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: WidgetColors.black,
          ),
        ),
        centerTitle: centerTitle,
        elevation: elevation,
        actions: actions,
        leading: leading ??
          (showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: WidgetColors.black),
                onPressed: () => Navigator.of(this).pop(),
              )
            : null),
      ),
    );
  }

  // ------------------ Header ------------------
  Widget header({
    String? title,
    Color? color,
    FontWeight? fontWeight,
    TextStyle? textStyle,
  }) {
    return Text(
      title ?? "Header",
      style: textStyle ??
        TextStyle(
          fontSize: 24,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: color ?? Colors.black
        ),
    );
  }

  // ------------------ Home Bottom Bar ------------------
  Widget homeBottomBar({
    double height = 60,
    Color backgroundColor = Colors.white,
    double elevation = 8,
    IconData icon = Icons.home,
    double iconSize = 30,
    Color iconColor = Colors.blue,
    VoidCallback? onPressed,
  }) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: backgroundColor,
      elevation: elevation,
      child: SizedBox(
        height: height,
        child: Center(
          child: IconButton(
            icon: Icon(icon, size: iconSize, color: iconColor),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }


  // ------------------ Dropdown ------------------
  // Widget customDropdown<T>({
  //   required List<T> menuItems,
  //   T? value,
  //   String? labelText,
  //   String? hintText,
  //   ValueChanged<T?>? onChanged,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       if (labelText != null && labelText.isNotEmpty)
  //         Text(
  //           labelText,
  //           style: AppStyles.labelStyle(),
  //         ),
  //       const SizedBox(height: 10),
  //       FractionallySizedBox(
  //         widthFactor: 0.97,
  //         child: DropdownButtonFormField<T>(
  //           value: value,
  //           isExpanded: true,
  //           decoration: InputDecoration(
  //             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  //             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  //           ),
  //           hint: hintText != null ? Text(hintText) : null,
  //           items: menuItems .map(
  //             (item) => DropdownMenuItem<T>(
  //               value: item,
  //               child: Text(item.toString()),
  //             ),
  //           ) .toList(),
  //           onChanged: onChanged,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget customDropdown<T>({
    required List<T> menuItems,
    T? value,
    String? labelText,
    String? hintText,
    ValueChanged<T?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && labelText.isNotEmpty)
          Text(labelText, style: AppStyles.labelStyle()),

        const SizedBox(height: 10),

        FractionallySizedBox(
          widthFactor: 0.97,
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,

            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16, // 🔴 increase height
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            hint: hintText != null
                ? Text(
                    hintText,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  )
                : null,

            items: menuItems.map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  maxLines: 3,
                  softWrap: true,
                ),
              ),
            ).toList(),

            selectedItemBuilder: (context) {
              return menuItems.map(
                (item) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.toString(),
                    maxLines: 3, // 🔴 allow 2–3 lines
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ).toList();
            },

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





  // ------------------ Radio Button ------------------
  Widget RadioButton(
    BuildContext context, {
    required int groupValue,
    required int value,
    String? text,
    Widget? label,
    double? fontsize,
    FontStyle? fontStyle,
    required Function(int) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            child: Row(
              children: [
                Radio<int>(
                  activeColor: Colors.black,
                  value: value,
                  groupValue: groupValue,
                  onChanged: (val) => onChanged(val!),
                ),
                Expanded(
                  child: label ?? Text(
                    text!,
                    style: TextStyle(
                      fontSize: fontsize ?? 14,
                      fontFamily: AppConstants.Montserrat,
                      fontStyle: fontStyle ?? FontStyle.normal
                    ),
                  ),
                )
              ],
            ),
          )
        ]
      )
    );
  }


  // ------------------ Image Container ------------------
  Widget imageContainer({
    required String imagePath,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    double borderRadius = 2,
    List<BoxShadow>? boxShadow,
    VoidCallback? onTap,
  }) {
    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? defaultShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          imagePath,
          fit: fit,
        ),
      ),
    );
  }

  // ------------------ Shadow Box ------------------
  Widget shadowBox({
    required String text,
    double? width,
    double? height,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.bold,
    FontStyle fontStyle = FontStyle.italic,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    VoidCallback? onTap,
    Gradient? gradient,
    String header = ""
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: getPercentHeight(height ?? 20),
        width: getPercentWidth(width ?? 30),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: gradient,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
              offset: const Offset(5, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getPercentWidth(4),
            vertical: getPercentHeight(1),
          ),
          child: Column(
            children: [
              SizedBox(height: getPercentHeight(header == "" ? 0 : 2)),
              Center(
                child: Text(
                  header ?? "",
                  style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  fontStyle: fontStyle,
                  color: textColor,
                ),
                )
              ),
              SizedBox(height: getPercentHeight(header == "" ? 0 : 2)),
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  fontStyle: fontStyle,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ------------------ Ack Screen ------------------
  Widget ackScreen({
    String title = "",
    String? image,
    String? confirmationText,
    int timer = 5,
    VoidCallback? onTimerComplete,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// IMAGE
            if (image != null)
              Image.asset(
                image,
                height: 120,
                fit: BoxFit.contain,
              ),

            const SizedBox(height: 20),

            /// CONFIRMATION MESSAGE
            if (confirmationText != null)
              Text(
                confirmationText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const SizedBox(height: 40),

            /// COUNTDOWN TIMER
            CountdownTimer(
              timerInSeconds: timer,
              onTimerComplete: onTimerComplete ??
                  () {
                    Navigator.pushNamedAndRemoveUntil(
                      this,
                      "/home",
                      (route) => false,
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }


  // ------------------ Dialog Box ------------------
  Future<void> showCustomDialog({
    double? height,
    double? width,
    String? title,
    required String description,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: this,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            height: height ?? 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null && title.isNotEmpty) ...[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: onPressed ?? () => Navigator.of(this).pop(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(buttonText ?? "OK"),
                  ),
                ],
              ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ Hide Loader ------------------
  void hideLoader() {
    final navigator =  BuildContextExtensionFunctions.navigatorUnauthenticated.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
    }
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
    double? fontSize,
    Color? activeBgColor,
    Color? deActiveBgColor,
    Color? foregroundColor,
    Color? activeTextColor,
    Color? deActiveTextColor,
    Color? borderColor,
    FontWeight? fontWeight,
    bool canNavigate = false,
  }) {
    final Color bgColor = canNavigate ? activeBgColor ?? WidgetColors.activeCta : deActiveBgColor ?? WidgetColors.gray_86;
    final Color textColor = canNavigate ? activeTextColor ?? Colors.white : deActiveTextColor ?? Colors.white;

    return Column(
      children: [
        SizedBox(height: getPercentHeight(aboveSpace ?? 1)),
        SizedBox(
          height: getPercentHeight(height ?? 6),
          width: getPercentWidth(width ?? 80),
          child: ElevatedButton(
            onPressed: canNavigate ? onBtnPress : () {},
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(bgColor),
              foregroundColor: MaterialStateProperty.all(foregroundColor ?? WidgetColors.black),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: borderColor ?? Colors.transparent),
                ),
              ),
            ),
            child: Text(
              text,
              style: textStyle ?? TextStyle(
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
        SizedBox(height: getPercentHeight(belowSpace ?? 1)),
      ],
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
                    color: textColor ?? Color.fromARGB(255, 70, 66, 66),
                    decoration: textUnderline ? TextDecoration.underline : TextDecoration.none,
                  ),
            ),
          ),
          SizedBox(height: getPercentHeight(belowSpace ?? 1)),
        ],
      ),
    );
  }


  // -------------------------OTP Field----------------------------------

  Widget OtpField({
    required BuildContext context,
    required TextEditingController otpController,
    required int otpLength,
  }) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      controller: otpController,
      keyboardType: TextInputType.number,
      autoFocus: true,
      enableActiveFill: true,
      animationType: AnimationType.fade,

      textStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),

      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(10),
        fieldHeight: 50,
        fieldWidth: 50,
        
        activeColor: Colors.black,
        inactiveColor: Colors.black,
        selectedColor: Colors.blue[100],

        activeFillColor: Colors.brown[50],
        inactiveFillColor: Colors.white,
        selectedFillColor: Colors.white,
      ),
    );
  }


}