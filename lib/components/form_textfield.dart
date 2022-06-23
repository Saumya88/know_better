import 'package:flutter/material.dart';
import 'package:know_better/utilities/styles/size_config.dart';
import 'package:know_better/utilities/styles/styling.dart';

class FormTextField extends StatelessWidget {
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool isPassword;
  final String hintText;
  final TextEditingController? controller;
  final bool readOnly;

  const FormTextField({
    this.readOnly = false,
    this.controller,
    this.inputType = TextInputType.text,
    this.validator,
    this.isPassword = false,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      child: TextFormField(
        readOnly: readOnly,
        controller: controller,
        onChanged: onChanged,
        decoration: kInputDecoration.copyWith(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: SizeConfig.textMultiplier * 4,
            color: Colors.black45,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
        ),
        style: TextStyle(
          fontSize: SizeConfig.textMultiplier * 4,
          color: Colors.black45,
          fontWeight: FontWeight.w400,
          fontFamily: 'Inter',
        ),
        keyboardType: inputType,
        textAlign: TextAlign.left,
        validator: validator,
        obscureText: isPassword,
      ),
    );
  }
}

class UpdateFormField extends StatelessWidget {
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Icon prefixIcon;
  final bool isPassword;
  final String hintText;
  final String initialValue;
  final int maxLines;
  final int minLines;

  const UpdateFormField({
    this.inputType = TextInputType.text,
    this.validator,
    this.initialValue = '',
    required this.prefixIcon,
    this.isPassword = false,
    this.maxLines = 1,
    this.minLines = 1,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      initialValue: initialValue,
      decoration: kInputDecoration.copyWith(
        prefixIcon: prefixIcon,
        hintText: hintText,
      ),
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: inputType,
      textAlign: TextAlign.left,
      validator: validator,
      obscureText: isPassword,
    );
  }
}
