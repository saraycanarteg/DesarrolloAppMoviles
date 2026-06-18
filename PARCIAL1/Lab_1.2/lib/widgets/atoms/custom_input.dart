import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int? maxLines;
  final TextInputType keyboardType;

  const CustomInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.number,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
