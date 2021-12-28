import "package:flutter/material.dart";

class TextFieldW extends StatelessWidget {
  const TextFieldW({
    Key? key,
    this.label,
    this.value,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.onChanged,
  }) : super(key: key);

  final Text? label;
  final String? value;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Icon? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    assert(value == null || controller == null);
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        label: label,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
      ),
      controller: controller ?? TextEditingController(text: value),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
