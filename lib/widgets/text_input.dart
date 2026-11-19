import 'package:flutter/material.dart';
import 'package:dr_drugs/utils/colors.dart';

class PrimaryTextInput extends StatelessWidget {
  const PrimaryTextInput({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        fillColor: primaryTextFieldColor,
        filled: true,
        hintText: hintText,
        // labelText: hintText,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: primaryFocusedTextFieldBorderColor,
            width: 2,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: primaryTextFieldBorderColor,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}

class SecondaryTextInput extends StatelessWidget {
  const SecondaryTextInput({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        fillColor: secondaryTextFieldColor,
        filled: true,
        hintText: hintText,
        // labelText: hintText,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: secondaryFocusedTextFieldBorderColor,
            width: 2,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: secondaryTextFieldBorderColor,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}