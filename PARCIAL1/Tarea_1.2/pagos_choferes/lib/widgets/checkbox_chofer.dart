import 'package:flutter/material.dart';

class CheckBoxChofer extends StatelessWidget {

  final bool value;
  final String texto;
  final Function(bool?) onChanged;

  const CheckBoxChofer({
    required this.value,
    required this.texto,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      title: Text(texto),
      onChanged: onChanged,
    );
  }
}