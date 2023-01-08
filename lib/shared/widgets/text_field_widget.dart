import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;

  const TextFieldInput({
    Key? key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.textInputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
    );

    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        border: border,
        fillColor: Colors.white,
        focusedBorder: border,
        enabledBorder: border,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
