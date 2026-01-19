import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseTextFieldCubit extends Cubit<bool> {
  final TextEditingController controller;

  BaseTextFieldCubit({
    bool initialObscureText = false,
    String? initialText,
  })  : controller = TextEditingController(text: initialText),
        super(initialObscureText);

  void toggleObscureText() => emit(!state);

  static String? defaultValidator(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }


  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}
