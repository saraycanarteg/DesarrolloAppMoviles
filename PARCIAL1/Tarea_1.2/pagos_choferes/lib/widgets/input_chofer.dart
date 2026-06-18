import 'package:flutter/material.dart';

class InputChofer extends StatelessWidget {

  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const InputChofer({
    required this.controller,
    required this.label,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}