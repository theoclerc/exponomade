import 'package:flutter/material.dart';
import '../utils/constants.dart';

// This custom widget represents a stylized text input field.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String labelText;
  final String hintText;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool obscureText;

  // Constructor to initialize the custom text field.
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.icon,
    required this.labelText,
    required this.hintText,
    this.validator,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        color: neutral,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          icon: Icon(icon),
          labelText: labelText,
          hintText: hintText,
          border: InputBorder.none,
          counterText: '', // Hide the character counter.
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est obligatoire';
              }
              return null;
            },
      ),
    );
  }
}
