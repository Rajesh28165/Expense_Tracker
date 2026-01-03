import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../util/styles.dart';

class CountdownTimer extends StatefulWidget {
  final int timerInSeconds;
  final String startingText;
  final String endingText;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final TextStyle? timerStyle;
  final VoidCallback? onTimerComplete;
  
  const CountdownTimer({
    Key? key,
    required this.timerInSeconds,
    this.startingText = 'Your home screen will load in ',
    this.endingText = ' seconds',
    this.textAlign = TextAlign.center,
    this.textStyle,
    this.timerStyle,
    this.onTimerComplete,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timerInSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();  
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining == 1) {
        timer.cancel();
        widget.onTimerComplete?.call();
      }
      setState(() => _remaining--);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutoSizeText.rich(
      TextSpan(
        text: widget.startingText,
        style: widget.textStyle ?? const CustomTextStyle(fontSize: 14),
        children: [
          TextSpan(
            text: '$_remaining',
            style: widget.timerStyle ?? const CustomTextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: widget.endingText,
            style: widget.textStyle ?? const CustomTextStyle(fontSize: 14),
          ),
        ],
      ),
      textAlign: widget.textAlign,
      maxLines: 2,
    );
  }

}